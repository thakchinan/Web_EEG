-- ===========================================
-- SmartBrain Care: RAG (Retrieval-Augmented Generation) Schema
-- ===========================================
-- ใช้ SQL นี้ใน Supabase SQL Editor เพื่อเปิดใช้งาน RAG

-- ขั้นตอนที่ 1: เปิดใช้งาน pgvector extension
-- ===========================================
CREATE EXTENSION IF NOT EXISTS vector;

-- ===========================================
-- 2. KNOWLEDGE BASE TABLE - ฐานความรู้ RAG
-- ===========================================
-- ตารางสำหรับเก็บข้อมูลความรู้พร้อม embeddings
CREATE TABLE IF NOT EXISTS knowledge_base (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,              -- หัวข้อความรู้
    content TEXT NOT NULL,                     -- เนื้อหาความรู้
    category VARCHAR(100) DEFAULT 'general',  -- หมวดหมู่: brainwave, mental_health, meditation, sleep, stress
    tags TEXT[],                               -- tags สำหรับการค้นหา
    embedding vector(1536),                    -- OpenAI text-embedding-3-small dimension
    metadata JSONB DEFAULT '{}',              -- ข้อมูลเพิ่มเติม
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index for vector similarity search
CREATE INDEX IF NOT EXISTS idx_knowledge_base_embedding ON knowledge_base 
    USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Index for category lookup
CREATE INDEX IF NOT EXISTS idx_knowledge_base_category ON knowledge_base(category);

-- Full-text search index (using 'simple' config since Thai is not supported)
CREATE INDEX IF NOT EXISTS idx_knowledge_base_content ON knowledge_base 
    USING gin(to_tsvector('simple', content));

-- ===========================================
-- 3. CHAT CONTEXT TABLE - บริบทการสนทนา
-- ===========================================
-- เก็บบริบทของการสนทนาแต่ละครั้งพร้อม embedding
CREATE TABLE IF NOT EXISTS chat_context (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_id VARCHAR(100),                   -- Session ID สำหรับแต่ละ conversation
    message TEXT NOT NULL,                     -- ข้อความ
    is_bot BOOLEAN DEFAULT FALSE,              -- เป็นข้อความจาก bot หรือไม่
    embedding vector(1536),                    -- Embedding ของข้อความ
    retrieved_knowledge_ids INTEGER[],         -- IDs ของความรู้ที่ถูกดึงมาใช้
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_chat_context_user_id ON chat_context(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_context_session_id ON chat_context(session_id);
CREATE INDEX IF NOT EXISTS idx_chat_context_embedding ON chat_context 
    USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- ===========================================
-- 4. USER KNOWLEDGE TABLE - ความรู้เฉพาะผู้ใช้
-- ===========================================
-- เก็บข้อมูลเฉพาะของผู้ใช้สำหรับ personalized recommendations
CREATE TABLE IF NOT EXISTS user_knowledge (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    topic VARCHAR(255) NOT NULL,               -- หัวข้อ: stress_pattern, sleep_quality, meditation_progress
    summary TEXT NOT NULL,                     -- สรุปข้อมูล
    embedding vector(1536),                    -- Embedding
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_user_knowledge_user_id ON user_knowledge(user_id);
CREATE INDEX IF NOT EXISTS idx_user_knowledge_embedding ON user_knowledge 
    USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- ===========================================
-- 5. FUNCTION: Vector Similarity Search
-- ===========================================
-- ฟังก์ชันค้นหาความรู้ที่เกี่ยวข้อง
CREATE OR REPLACE FUNCTION search_knowledge(
    query_embedding vector(1536),
    match_count INT DEFAULT 5,
    match_threshold FLOAT DEFAULT 0.7
)
RETURNS TABLE (
    id INT,
    title VARCHAR(500),
    content TEXT,
    category VARCHAR(100),
    similarity FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        kb.id,
        kb.title,
        kb.content,
        kb.category,
        1 - (kb.embedding <=> query_embedding) AS similarity
    FROM knowledge_base kb
    WHERE 1 - (kb.embedding <=> query_embedding) > match_threshold
    ORDER BY kb.embedding <=> query_embedding
    LIMIT match_count;
END;
$$;

-- ===========================================
-- 6. FUNCTION: Hybrid Search (Vector + Keyword)
-- ===========================================
-- ค้นหาแบบ Hybrid: รวม Vector Search กับ Keyword Search
CREATE OR REPLACE FUNCTION hybrid_search(
    query_embedding vector(1536),
    query_text TEXT,
    match_count INT DEFAULT 5,
    vector_weight FLOAT DEFAULT 0.7,
    text_weight FLOAT DEFAULT 0.3
)
RETURNS TABLE (
    id INT,
    title VARCHAR(500),
    content TEXT,
    category VARCHAR(100),
    combined_score FLOAT
)
LANGUAGE plpgsql
AS $$
-- Note: Using 'simple' text search config since Thai is not supported
BEGIN
    RETURN QUERY
    SELECT 
        kb.id,
        kb.title,
        kb.content,
        kb.category,
        (
            vector_weight * (1 - (kb.embedding <=> query_embedding)) +
            text_weight * COALESCE(
                ts_rank(to_tsvector('simple', kb.content), plainto_tsquery('simple', query_text)),
                0
            )
        ) AS combined_score
    FROM knowledge_base kb
    WHERE 
        kb.embedding IS NOT NULL
    ORDER BY combined_score DESC
    LIMIT match_count;
END;
$$;

-- ===========================================
-- 7. FUNCTION: Get User Context
-- ===========================================
-- ดึงบริบทของผู้ใช้สำหรับ personalized responses
CREATE OR REPLACE FUNCTION get_user_context(
    p_user_id INT,
    context_limit INT DEFAULT 5
)
RETURNS TABLE (
    topic VARCHAR(255),
    summary TEXT,
    brainwave_avg JSONB,
    stress_level VARCHAR(50),
    recent_activities TEXT[]
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        uk.topic,
        uk.summary,
        (
            SELECT jsonb_build_object(
                'alpha', AVG(bd.alpha_wave),
                'beta', AVG(bd.beta_wave),
                'theta', AVG(bd.theta_wave),
                'delta', AVG(bd.delta_wave),
                'gamma', AVG(bd.gamma_wave),
                'attention', AVG(bd.attention_score),
                'meditation', AVG(bd.meditation_score)
            )
            FROM brainwave_data bd 
            WHERE bd.user_id = p_user_id
            AND bd.recorded_at > NOW() - INTERVAL '7 days'
        ) AS brainwave_avg,
        (
            SELECT tr.stress_level 
            FROM test_results tr 
            WHERE tr.user_id = p_user_id 
            ORDER BY tr.test_date DESC 
            LIMIT 1
        ) AS stress_level,
        (
            SELECT array_agg(a.activity_name) 
            FROM (
                SELECT activity_name 
                FROM activities 
                WHERE user_id = p_user_id 
                ORDER BY completed_at DESC 
                LIMIT 5
            ) a
        ) AS recent_activities
    FROM user_knowledge uk
    WHERE uk.user_id = p_user_id
    ORDER BY uk.last_updated DESC
    LIMIT context_limit;
END;
$$;

-- ===========================================
-- 8. RLS Policies
-- ===========================================
ALTER TABLE knowledge_base ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_context ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_knowledge ENABLE ROW LEVEL SECURITY;

-- Policy for knowledge_base (read-only for all users)
CREATE POLICY "Allow read for knowledge_base" ON knowledge_base 
    FOR SELECT USING (true);

-- Policy for chat_context (users can only access their own)
CREATE POLICY "Users manage own chat_context" ON chat_context 
    FOR ALL USING (true) WITH CHECK (true);

-- Policy for user_knowledge (users can only access their own)
CREATE POLICY "Users manage own user_knowledge" ON user_knowledge 
    FOR ALL USING (true) WITH CHECK (true);

-- ===========================================
-- 9. TRIGGER: Auto-update timestamp
-- ===========================================
DROP TRIGGER IF EXISTS update_knowledge_base_updated_at ON knowledge_base;
CREATE TRIGGER update_knowledge_base_updated_at 
    BEFORE UPDATE ON knowledge_base
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===========================================
-- 10. SAMPLE KNOWLEDGE DATA (ข้อมูลความรู้ตัวอย่าง)
-- ===========================================
-- หมายเหตุ: embeddings ต้องสร้างจาก OpenAI API ก่อน

INSERT INTO knowledge_base (title, content, category, tags, metadata) VALUES

-- Brainwave Knowledge
('คลื่นสมอง Alpha คืออะไร', 
'คลื่น Alpha (8-13 Hz) เป็นคลื่นสมองที่เกิดขึ้นเมื่อเราอยู่ในสภาวะผ่อนคลาย สงบ และตื่นตัว เช่น การทำสมาธิ ปิดตาพักผ่อน หรือมองทิวทัศน์ธรรมชาติ คลื่น Alpha ช่วยลดความเครียด เพิ่มความคิดสร้างสรรค์ และส่งเสริมการเรียนรู้',
'brainwave', ARRAY['alpha', 'relaxation', 'meditation'], '{"frequency": "8-13 Hz", "state": "relaxed alertness"}'),

('คลื่นสมอง Beta และการทำงาน',
'คลื่น Beta (13-30 Hz) เป็นคลื่นที่ครองสมองเมื่อเราตื่นตัว ทำงาน คิดวิเคราะห์ หรือแก้ปัญหา Beta สูงเกินไปอาจทำให้วิตกกังวล เครียด หรือนอนไม่หลับ การฝึกสมาธิช่วยลด Beta ที่มากเกินไปได้',
'brainwave', ARRAY['beta', 'focus', 'work', 'anxiety'], '{"frequency": "13-30 Hz", "state": "active thinking"}'),

('คลื่นสมอง Theta และความคิดสร้างสรรค์',
'คลื่น Theta (4-8 Hz) เกิดขึ้นระหว่างการเคลิ้มหลับ ฝันกลางวัน หรือสมาธิลึก คลื่นนี้เชื่อมโยงกับความคิดสร้างสรรค์ ความจำ และการประมวลผลอารมณ์ การเพิ่ม Theta ช่วยให้จิตใจสงบและเข้าถึงจิตใต้สำนึก',
'brainwave', ARRAY['theta', 'creativity', 'meditation', 'dream'], '{"frequency": "4-8 Hz", "state": "deep relaxation"}'),

('คลื่นสมอง Delta และการนอนหลับ',
'คลื่น Delta (0.5-4 Hz) เกิดในระหว่างการนอนหลับลึก ไม่ฝัน เป็นคลื่นที่สำคัญสำหรับการฟื้นฟูร่างกาย ซ่อมแซมเนื้อเยื่อ และเสริมระบบภูมิคุ้มกัน การนอนไม่พอทำให้ Delta ลดลง',
'brainwave', ARRAY['delta', 'sleep', 'recovery', 'healing'], '{"frequency": "0.5-4 Hz", "state": "deep sleep"}'),

('คลื่นสมอง Gamma และสมาธิสูง',
'คลื่น Gamma (30-100+ Hz) เกี่ยวข้องกับการประมวลผลข้อมูลระดับสูง สติปัญญา และความตระหนักรู้ พบในผู้ทำสมาธิที่ชำนาญ Gamma สูงช่วยเพิ่มความจำ การเรียนรู้ และความสุข',
'brainwave', ARRAY['gamma', 'cognition', 'awareness', 'advanced meditation'], '{"frequency": "30-100+ Hz", "state": "peak mental processing"}'),

-- Mental Health Knowledge
('ความเครียดคืออะไรและผลกระทบ',
'ความเครียดคือการตอบสนองของร่างกายต่อสถานการณ์ที่ท้าทาย ความเครียดเฉียบพลันช่วยให้ตื่นตัว แต่ความเครียดเรื้อรังทำลายสุขภาพ ทำให้นอนไม่หลับ ปวดหัว ระบบภูมิคุ้มกันอ่อนแอ และเพิ่มความเสี่ยงโรคหัวใจ',
'mental_health', ARRAY['stress', 'health', 'chronic'], '{"type": "educational"}'),

('วิธีจัดการความเครียดอย่างมีประสิทธิภาพ',
'การจัดการความเครียดที่ได้ผล ได้แก่ 1) หายใจลึก 4-7-8: หายใจเข้า 4 วินาที กลั้น 7 วินาที หายใจออก 8 วินาที 2) ออกกำลังกายสม่ำเสมอ 3) นอนหลับให้เพียงพอ 4) ทำสมาธิ 10-20 นาทีต่อวัน 5) พูดคุยกับคนที่ไว้ใจ',
'mental_health', ARRAY['stress', 'management', 'breathing', 'exercise'], '{"type": "practical_advice"}'),

('สัญญาณของภาวะซึมเศร้า',
'สัญญาณซึมเศร้า ได้แก่ เศร้าหมองมากกว่า 2 สัปดาห์ ไม่สนใจสิ่งที่เคยชอบ นอนมากหรือน้อยผิดปกติ เบื่ออาหารหรือกินมาก เหนื่อยล้า รู้สึกไร้ค่า มีปัญหาสมาธิ หากมีหลายอาการ ควรปรึกษาผู้เชี่ยวชาญ',
'mental_health', ARRAY['depression', 'symptoms', 'warning signs'], '{"type": "awareness"}'),

-- Meditation Knowledge
('การทำสมาธิเบื้องต้น',
'เริ่มต้นสมาธิง่ายๆ: 1) นั่งสบาย หลับตา 2) หายใจตามธรรมชาติ 3) จดจ่อที่ลมหายใจ 4) เมื่อใจลอย ให้กลับมาที่ลมหายใจ 5) เริ่มจาก 5 นาที ค่อยๆ เพิ่ม การฝึกสม่ำเสมอช่วยเพิ่ม Alpha และ Theta',
'meditation', ARRAY['beginner', 'breathing', 'practice'], '{"difficulty": "beginner", "duration": "5-20 minutes"}'),

('Body Scan Meditation',
'Body Scan คือการสังเกตความรู้สึกทางกายตั้งแต่ศีรษะถึงปลายเท้า ช่วยผ่อนคลายกล้ามเนื้อ ลดความเครียด และเพิ่มการตระหนักรู้ในร่างกาย เหมาะทำก่อนนอนหรือเมื่อเครียด ใช้เวลา 15-30 นาที',
'meditation', ARRAY['body scan', 'relaxation', 'awareness'], '{"difficulty": "intermediate", "duration": "15-30 minutes"}'),

-- Sleep Knowledge
('วิธีนอนหลับให้ดีขึ้น',
'เคล็ดลับนอนหลับดี: 1) นอนและตื่นเวลาเดิมทุกวัน 2) ห้องนอนมืดและเย็น 3) งดหน้าจอ 1 ชั่วโมงก่อนนอน 4) งดคาเฟอีนหลังบ่าย 5) ออกกำลังกายแต่ไม่ใกล้เวลานอน 6) ทำกิจกรรมผ่อนคลายก่อนนอน',
'sleep', ARRAY['sleep hygiene', 'quality', 'tips'], '{"type": "practical_advice"}'),

('ความสัมพันธ์ระหว่างการนอนกับคลื่นสมอง',
'ในการนอนหลับปกติ สมองผ่านหลายระยะ: NREM 1 (Theta), NREM 2 (Sleep Spindles), NREM 3 (Delta ลึก), และ REM (ฝัน, คลื่นหลากหลาย) การนอนครบทุกระยะสำคัญต่อความจำ การเรียนรู้ และสุขภาพกาย',
'sleep', ARRAY['sleep stages', 'brainwave', 'REM', 'NREM'], '{"type": "educational"}'),

-- Muse Device Knowledge
('วิธีใช้ Muse S สำหรับการทำสมาธิ',
'Muse S คืออุปกรณ์ EEG สำหรับผู้บริโภคที่วัดคลื่นสมองขณะทำสมาธิ วิธีใช้: 1) สวมใส่ให้แน่นพอดี 2) เชื่อมต่อ Bluetooth กับแอป 3) เลือกโปรแกรมสมาธิ 4) ฟังเสียง feedback ที่เปลี่ยนตามสภาวะจิตใจ สมาธิดี = เสียงธรรมชาติสงบ',
'device', ARRAY['muse', 'eeg', 'meditation', 'setup'], '{"device": "Muse S", "type": "tutorial"}'),

('การอ่านค่าคลื่นสมองจาก Muse',
'Muse แสดงข้อมูล: Attention (สมาธิ) และ Meditation (ความสงบ) คะแนน 0-100 คะแนน Attention สูงหมายถึงจิตจดจ่อ คะแนน Meditation สูงหมายถึงจิตสงบผ่อนคลาย การติดตามแนวโน้มช่วยเห็นความก้าวหน้าในการฝึก',
'device', ARRAY['muse', 'metrics', 'attention', 'meditation'], '{"device": "Muse S/Muse 2", "type": "interpretation"}')

ON CONFLICT DO NOTHING;

-- ===========================================
COMMENT ON TABLE knowledge_base IS 'ฐานความรู้สำหรับ RAG - เก็บข้อมูลความรู้พร้อม embeddings';
COMMENT ON TABLE chat_context IS 'บริบทการสนทนาสำหรับ context-aware responses';
COMMENT ON TABLE user_knowledge IS 'ข้อมูลส่วนตัวผู้ใช้สำหรับ personalized recommendations';
COMMENT ON FUNCTION search_knowledge IS 'ค้นหาความรู้ด้วย vector similarity';
COMMENT ON FUNCTION hybrid_search IS 'ค้นหาแบบ hybrid: vector + keyword';
COMMENT ON FUNCTION get_user_context IS 'ดึงบริบทผู้ใช้สำหรับ personalized AI';

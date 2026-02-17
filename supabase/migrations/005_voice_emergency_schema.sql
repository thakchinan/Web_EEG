-- ===========================================
-- SmartBrain Care: Voice Metadata & Emergency Contact Schema
-- ===========================================
-- ใช้ SQL นี้ใน Supabase SQL Editor เพื่อเพิ่มตารางตาม ER Diagram

-- ===========================================
-- 1. VOICE METADATA TABLE - ข้อมูลการวิเคราะห์เสียง
-- ===========================================
-- เก็บข้อมูล metadata จากการวิเคราะห์เสียงพูดของผู้ใช้
CREATE TABLE IF NOT EXISTS voice_metadata (
    voice_id SERIAL PRIMARY KEY,
    message_id INTEGER REFERENCES chat_messages(id) ON DELETE CASCADE,
    detected_language VARCHAR(50) DEFAULT 'th',        -- ภาษาที่ตรวจจับได้ (th, en, etc.)
    duration_seconds REAL DEFAULT 0,                   -- ความยาวเสียง (วินาที)
    audio_file_url VARCHAR(500),                       -- URL ไฟล์เสียง (ถ้าเก็บใน storage)
    content_text TEXT,                                 -- ข้อความที่ถอดจากเสียง (Speech-to-Text)
    sender_type VARCHAR(50) DEFAULT 'user',            -- user หรือ bot
    sentiment_score REAL DEFAULT 0,                    -- คะแนนอารมณ์ (-1 ถึง 1)
    stress_index REAL DEFAULT 0,                       -- ดัชนีความเครียดจากเสียง (0-100)
    pitch_avg REAL,                                    -- ความถี่เสียงเฉลี่ย (Hz)
    volume_avg REAL,                                   -- ความดังเสียงเฉลี่ย (dB)
    speech_rate REAL,                                  -- อัตราการพูด (words per minute)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_voice_metadata_message_id ON voice_metadata(message_id);
CREATE INDEX IF NOT EXISTS idx_voice_metadata_created_at ON voice_metadata(created_at DESC);

-- ===========================================
-- 2. EMERGENCY CONTACT TABLE - ผู้ติดต่อฉุกเฉิน
-- ===========================================
-- เก็บข้อมูลผู้ติดต่อฉุกเฉินของผู้ใช้แต่ละคน
CREATE TABLE IF NOT EXISTS emergency_contacts (
    contact_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    contact_name VARCHAR(255) NOT NULL,                -- ชื่อผู้ติดต่อ
    relationship VARCHAR(100),                         -- ความสัมพันธ์ (ลูก, หลาน, แพทย์, etc.)
    phone_number VARCHAR(20) NOT NULL,                 -- เบอร์โทรศัพท์
    email VARCHAR(255),                                -- อีเมล (optional)
    is_primary BOOLEAN DEFAULT FALSE,                  -- เป็นผู้ติดต่อหลักหรือไม่
    notify_on_emergency BOOLEAN DEFAULT TRUE,          -- แจ้งเตือนเมื่อฉุกเฉิน
    notify_on_high_stress BOOLEAN DEFAULT FALSE,       -- แจ้งเตือนเมื่อความเครียดสูง
    notes TEXT,                                        -- หมายเหตุเพิ่มเติม
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_emergency_contacts_user_id ON emergency_contacts(user_id);
CREATE INDEX IF NOT EXISTS idx_emergency_contacts_is_primary ON emergency_contacts(is_primary);

-- ===========================================
-- 3. ELDERLY PROFILE TABLE - ข้อมูลเพิ่มเติมสำหรับผู้สูงอายุ
-- ===========================================
-- เก็บข้อมูลสุขภาพและข้อมูลเฉพาะของผู้สูงอายุ
CREATE TABLE IF NOT EXISTS elderly_profiles (
    profile_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    date_of_birth DATE,
    gender VARCHAR(20),                                -- male, female, other
    blood_type VARCHAR(5),                             -- A, B, AB, O with +/-
    height_cm REAL,                                    -- ส่วนสูง (cm)
    weight_kg REAL,                                    -- น้ำหนัก (kg)
    medical_conditions TEXT[],                         -- โรคประจำตัว (เช่น เบาหวาน, ความดัน)
    allergies TEXT[],                                  -- ประวัติแพ้ยา/อาหาร
    current_medications TEXT[],                        -- ยาที่กินอยู่
    mobility_status VARCHAR(100),                      -- สถานะการเคลื่อนไหว
    cognitive_status VARCHAR(100),                     -- สถานะทางความคิด
    doctor_name VARCHAR(255),                          -- ชื่อแพทย์ประจำตัว
    doctor_phone VARCHAR(20),                          -- เบอร์แพทย์
    hospital_name VARCHAR(255),                        -- โรงพยาบาลประจำ
    insurance_info TEXT,                               -- ข้อมูลประกันสุขภาพ
    special_needs TEXT,                                -- ความต้องการพิเศษ
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index
CREATE INDEX IF NOT EXISTS idx_elderly_profiles_user_id ON elderly_profiles(user_id);

-- ===========================================
-- 4. CONVERSATION TABLE - การสนทนา (Session)
-- ===========================================
-- แยก Conversation ออกมาเป็นตารางเฉพาะ
CREATE TABLE IF NOT EXISTS conversations (
    conversation_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE,
    topic_summary TEXT,                                -- สรุปหัวข้อการสนทนา
    sentiment_avg REAL,                                -- อารมณ์เฉลี่ยของการสนทนา
    is_active BOOLEAN DEFAULT TRUE,                    -- สนทนายังเปิดอยู่หรือไม่
    message_count INTEGER DEFAULT 0,                   -- จำนวนข้อความ
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index
CREATE INDEX IF NOT EXISTS idx_conversations_user_id ON conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_conversations_is_active ON conversations(is_active);

-- ===========================================
-- 5. RETRIEVAL LOG TABLE - บันทึกการดึงข้อมูล RAG
-- ===========================================
-- เก็บ log ของการดึงข้อมูลจาก knowledge base
CREATE TABLE IF NOT EXISTS retrieval_logs (
    log_id SERIAL PRIMARY KEY,
    message_id INTEGER REFERENCES chat_messages(id) ON DELETE CASCADE,
    knowledge_id INTEGER REFERENCES knowledge_base(id) ON DELETE SET NULL,
    query_text TEXT,                                   -- คำถามที่ค้นหา
    similarity_score REAL,                             -- คะแนน similarity
    rank_order INTEGER,                                -- ลำดับการจัดอันดับ
    was_used BOOLEAN DEFAULT FALSE,                    -- ถูกใช้ในการตอบหรือไม่
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_retrieval_logs_message_id ON retrieval_logs(message_id);
CREATE INDEX IF NOT EXISTS idx_retrieval_logs_knowledge_id ON retrieval_logs(knowledge_id);

-- ===========================================
-- 6. EEG DEVICE TABLE - อุปกรณ์ EEG
-- ===========================================
-- เก็บข้อมูลอุปกรณ์ EEG ที่ลงทะเบียน
CREATE TABLE IF NOT EXISTS eeg_devices (
    device_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    device_name VARCHAR(100) NOT NULL,                 -- ชื่ออุปกรณ์ (Muse S, Muse 2, etc.)
    model_name VARCHAR(100),                           -- รุ่น
    serial_number VARCHAR(100) UNIQUE,                 -- Serial Number
    mac_address VARCHAR(50),                           -- MAC Address
    firmware_version VARCHAR(50),                      -- เวอร์ชัน firmware
    status VARCHAR(50) DEFAULT 'active',               -- active, inactive, paired
    last_connected_at TIMESTAMP WITH TIME ZONE,
    battery_level INTEGER,                             -- ระดับแบตเตอรี่ล่าสุด
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index
CREATE INDEX IF NOT EXISTS idx_eeg_devices_user_id ON eeg_devices(user_id);
CREATE INDEX IF NOT EXISTS idx_eeg_devices_status ON eeg_devices(status);

-- ===========================================
-- 7. EEG SESSION TABLE - Session การวัดคลื่นสมอง
-- ===========================================
-- เก็บข้อมูลแต่ละ session ของการวัด EEG
CREATE TABLE IF NOT EXISTS eeg_sessions (
    session_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id INTEGER REFERENCES eeg_devices(device_id) ON DELETE SET NULL,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE,
    duration_seconds INTEGER,                          -- ระยะเวลา session
    avg_attention_score REAL,                          -- สมาธิเฉลี่ย
    avg_relaxation_score REAL,                         -- ความผ่อนคลายเฉลี่ย
    avg_stress_score REAL,                             -- ความเครียดเฉลี่ย
    data_quality_grade VARCHAR(10),                    -- คุณภาพข้อมูล (A, B, C, D)
    session_type VARCHAR(50) DEFAULT 'general',        -- meditation, sleep, focus, general
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_eeg_sessions_user_id ON eeg_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_eeg_sessions_device_id ON eeg_sessions(device_id);
CREATE INDEX IF NOT EXISTS idx_eeg_sessions_started_at ON eeg_sessions(started_at DESC);

-- ===========================================
-- 8. Add session_id to brainwave_data (Optional Link)
-- ===========================================
-- เพิ่ม column เชื่อมโยงกับ session (ถ้าต้องการ)
ALTER TABLE brainwave_data 
ADD COLUMN IF NOT EXISTS session_id INTEGER REFERENCES eeg_sessions(session_id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_brainwave_data_session_id ON brainwave_data(session_id);

-- ===========================================
-- 9. RLS Policies
-- ===========================================
ALTER TABLE voice_metadata ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE elderly_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE retrieval_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE eeg_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE eeg_sessions ENABLE ROW LEVEL SECURITY;

-- Allow all for development (ปรับตามความเหมาะสม)
CREATE POLICY "Allow all for voice_metadata" ON voice_metadata FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for emergency_contacts" ON emergency_contacts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for elderly_profiles" ON elderly_profiles FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for conversations" ON conversations FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for retrieval_logs" ON retrieval_logs FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for eeg_devices" ON eeg_devices FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for eeg_sessions" ON eeg_sessions FOR ALL USING (true) WITH CHECK (true);

-- ===========================================
-- 10. AUTO UPDATE TIMESTAMP TRIGGERS
-- ===========================================
DROP TRIGGER IF EXISTS update_emergency_contacts_updated_at ON emergency_contacts;
CREATE TRIGGER update_emergency_contacts_updated_at 
    BEFORE UPDATE ON emergency_contacts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_elderly_profiles_updated_at ON elderly_profiles;
CREATE TRIGGER update_elderly_profiles_updated_at 
    BEFORE UPDATE ON elderly_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===========================================
-- COMMENTS
-- ===========================================
COMMENT ON TABLE voice_metadata IS 'ข้อมูล metadata จากการวิเคราะห์เสียงพูด';
COMMENT ON TABLE emergency_contacts IS 'ผู้ติดต่อฉุกเฉินของผู้ใช้';
COMMENT ON TABLE elderly_profiles IS 'ข้อมูลสุขภาพและรายละเอียดผู้สูงอายุ';
COMMENT ON TABLE conversations IS 'Session การสนทนากับ AI';
COMMENT ON TABLE retrieval_logs IS 'บันทึกการดึงข้อมูลจาก Knowledge Base (RAG)';
COMMENT ON TABLE eeg_devices IS 'อุปกรณ์ EEG ที่ลงทะเบียน';
COMMENT ON TABLE eeg_sessions IS 'Session การวัดคลื่นสมอง';

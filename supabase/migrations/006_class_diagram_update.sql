-- ===========================================
-- SmartBrain Care: Class Diagram Alignment Update
-- ===========================================
-- Migration 006: เพิ่มตาราง EmotionLog และปรับปรุง fields ให้ตรงตาม Class Diagram
-- วันที่: 2026-02-11

-- ===========================================
-- 1. EMOTION LOG TABLE - บันทึกอารมณ์ (ใหม่)
-- ===========================================
-- ตาราง EmotionLog จาก Class Diagram
CREATE TABLE IF NOT EXISTS emotion_logs (
    log_id BIGSERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    emotion_type VARCHAR(100) NOT NULL,              -- ประเภทอารมณ์ (happy, sad, angry, anxious, calm, etc.)
    trigger_event VARCHAR(500),                       -- เหตุการณ์ที่กระตุ้น
    intensity INTEGER DEFAULT 5 CHECK (intensity >= 1 AND intensity <= 10),  -- ความรุนแรง (1-10)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_emotion_logs_user_id ON emotion_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_emotion_logs_created_at ON emotion_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_emotion_logs_emotion_type ON emotion_logs(emotion_type);

-- ===========================================
-- 2. UPDATE USERS TABLE - เพิ่ม fields ตาม Class Diagram
-- ===========================================
-- Class Diagram: User มี role, firstName, lastName, isActive
ALTER TABLE users ADD COLUMN IF NOT EXISTS first_name VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_name VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'user';
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- ===========================================
-- 3. UPDATE USER_SETTINGS TABLE - เพิ่ม fields ตาม Class Diagram
-- ===========================================
-- Class Diagram: UserSettings มี sensitivityLevel, stressThreshold, criticalFFT, brainMode, fontSize
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS notification_prefer VARCHAR(100) DEFAULT 'all';
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS sensitivity_level VARCHAR(50) DEFAULT 'medium';
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS stress_threshold VARCHAR(100) DEFAULT 'moderate';
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS critical_fft INTEGER DEFAULT 0;
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS brain_mode VARCHAR(50) DEFAULT 'normal';
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS font_size INTEGER DEFAULT 16;

-- ===========================================
-- 4. UPDATE SCHEDULES TABLE - เพิ่ม fields ตาม Class Diagram
-- ===========================================
-- Class Diagram: Schedule มี priority, type, isRecurring, status, nextOccurrence, reminderMinutes
ALTER TABLE schedules ADD COLUMN IF NOT EXISTS priority VARCHAR(20) DEFAULT 'medium';
ALTER TABLE schedules ADD COLUMN IF NOT EXISTS schedule_type VARCHAR(50) DEFAULT 'general';
ALTER TABLE schedules ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'Pending';
ALTER TABLE schedules ADD COLUMN IF NOT EXISTS is_recurring BOOLEAN DEFAULT FALSE;
ALTER TABLE schedules ADD COLUMN IF NOT EXISTS next_occurrence TIMESTAMP WITH TIME ZONE;
ALTER TABLE schedules ADD COLUMN IF NOT EXISTS reminder_minutes INTEGER DEFAULT 15;

-- ===========================================
-- 5. UPDATE TEST_RESULTS TABLE - เพิ่ม fields ตาม Class Diagram
-- ===========================================
-- Class Diagram: StressTestResult มี stressLevel(bool), depressionIndicator(bool), assessment
ALTER TABLE test_results ADD COLUMN IF NOT EXISTS assessment TEXT;

-- ===========================================
-- 6. UPDATE EEG_SESSIONS TABLE - เพิ่ม fields ตาม Class Diagram
-- ===========================================
-- Class Diagram: EEGSession มี status, attentionLevel, alphaWave, focusRecommendation, stressScore, deltaCalculated
ALTER TABLE eeg_sessions ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'active';
ALTER TABLE eeg_sessions ADD COLUMN IF NOT EXISTS attention_level INTEGER DEFAULT 0;
ALTER TABLE eeg_sessions ADD COLUMN IF NOT EXISTS alpha_wave REAL DEFAULT 0;
ALTER TABLE eeg_sessions ADD COLUMN IF NOT EXISTS focus_recommendation TEXT;
ALTER TABLE eeg_sessions ADD COLUMN IF NOT EXISTS stress_score REAL DEFAULT 0;
ALTER TABLE eeg_sessions ADD COLUMN IF NOT EXISTS delta_calculated REAL DEFAULT 0;

-- ===========================================
-- 7. UPDATE CHAT_MESSAGES TABLE - เพิ่ม fields ตาม Class Diagram
-- ===========================================
-- Class Diagram: ChatMessage มี senderRole, receivedAt
ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS sender_role VARCHAR(50) DEFAULT 'user';
ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS received_at TIMESTAMP WITH TIME ZONE;

-- ===========================================
-- 8. UPDATE CONVERSATIONS TABLE - เพิ่ม fields ตาม Class Diagram
-- ===========================================
-- Class Diagram: Conversation มี enableAI
ALTER TABLE conversations ADD COLUMN IF NOT EXISTS enable_ai BOOLEAN DEFAULT TRUE;
ALTER TABLE conversations ADD COLUMN IF NOT EXISTS end_conversation_text TEXT;

-- ===========================================
-- 9. UPDATE ELDERLY_PROFILES TABLE - เพิ่ม fields ตาม Class Diagram
-- ===========================================
-- Class Diagram: ElderlyProfile มี nickName, age, relationship, emergencyContact
ALTER TABLE elderly_profiles ADD COLUMN IF NOT EXISTS nick_name VARCHAR(100);
ALTER TABLE elderly_profiles ADD COLUMN IF NOT EXISTS age INTEGER;
ALTER TABLE elderly_profiles ADD COLUMN IF NOT EXISTS relationship VARCHAR(100);
ALTER TABLE elderly_profiles ADD COLUMN IF NOT EXISTS emergency_contact VARCHAR(255);

-- ===========================================
-- 10. UPDATE KNOWLEDGE_BASE TABLE - เพิ่ม fields ตาม Class Diagram
-- ===========================================
-- Class Diagram: MedicalKnowledge มี importance, hasSolution, addedManual
ALTER TABLE knowledge_base ADD COLUMN IF NOT EXISTS importance INTEGER DEFAULT 0;
ALTER TABLE knowledge_base ADD COLUMN IF NOT EXISTS has_solution BOOLEAN DEFAULT FALSE;
ALTER TABLE knowledge_base ADD COLUMN IF NOT EXISTS added_manual TIMESTAMP WITH TIME ZONE;

-- ===========================================
-- 11. UPDATE EEG_DEVICES TABLE - เพิ่ม fields ตาม Class Diagram
-- ===========================================
-- Class Diagram: EEGDevice มี isConnected
ALTER TABLE eeg_devices ADD COLUMN IF NOT EXISTS is_connected BOOLEAN DEFAULT FALSE;

-- ===========================================
-- 12. UPDATE BRAINWAVE_DATA (EEGRawData) TABLE - เพิ่ม fields ตาม Class Diagram
-- ===========================================
-- Class Diagram: EEGRawData มี channelName, channelData
ALTER TABLE brainwave_data ADD COLUMN IF NOT EXISTS channel_name VARCHAR(50);
ALTER TABLE brainwave_data ADD COLUMN IF NOT EXISTS channel_data REAL;

-- ===========================================
-- 13. UPDATE ACTIVITIES (ActivityLog) TABLE - เพิ่ม fields ตาม Class Diagram
-- ===========================================
-- Class Diagram: ActivityLog มี isAutoTracked, noteInfo
ALTER TABLE activities ADD COLUMN IF NOT EXISTS is_auto_tracked BOOLEAN DEFAULT FALSE;
ALTER TABLE activities ADD COLUMN IF NOT EXISTS note_info TEXT;

-- ===========================================
-- 14. UPDATE VOICE_METADATA TABLE - เพิ่ม fields ตาม Class Diagram
-- ===========================================
-- Class Diagram: VoiceMetadata มี emotionDetected
ALTER TABLE voice_metadata ADD COLUMN IF NOT EXISTS emotion_detected VARCHAR(100);

-- ===========================================
-- 15. UPDATE RETRIEVAL_LOGS TABLE - เพิ่ม fields ตาม Class Diagram
-- ===========================================
-- Class Diagram: RetrievalLog มี emotionType, queryText, searchMethod, createdBy
ALTER TABLE retrieval_logs ADD COLUMN IF NOT EXISTS search_method VARCHAR(50) DEFAULT 'vector';

-- ===========================================
-- 16. RLS POLICIES สำหรับตารางใหม่
-- ===========================================
ALTER TABLE emotion_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for emotion_logs" ON emotion_logs FOR ALL USING (true) WITH CHECK (true);

-- ===========================================
-- 17. COMMENTS
-- ===========================================
COMMENT ON TABLE emotion_logs IS 'บันทึกอารมณ์ของผู้ใช้ - ประเภท, เหตุการณ์กระตุ้น, ความรุนแรง';
COMMENT ON COLUMN users.role IS 'บทบาทผู้ใช้: user, admin, caretaker';
COMMENT ON COLUMN users.is_active IS 'สถานะการใช้งาน';
COMMENT ON COLUMN user_settings.sensitivity_level IS 'ระดับความไว: low, medium, high';
COMMENT ON COLUMN user_settings.brain_mode IS 'โหมดสมอง: normal, focus, relax, sleep';
COMMENT ON COLUMN schedules.priority IS 'ความสำคัญ: low, medium, high';
COMMENT ON COLUMN schedules.status IS 'สถานะ: Pending, Complete, Cancelled';
COMMENT ON COLUMN eeg_sessions.focus_recommendation IS 'คำแนะนำเกี่ยวกับสมาธิ';
COMMENT ON COLUMN emotion_logs.intensity IS 'ความรุนแรงของอารมณ์ 1-10';

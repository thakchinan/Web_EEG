-- ===========================================
-- 007: เปิด Supabase Realtime สำหรับตารางหลัก
-- ===========================================
-- ต้องเปิด Realtime เพื่อให้ .stream() ใน Flutter ทำงานได้แบบ real-time
-- เมื่อมีข้อมูลใหม่ (INSERT/UPDATE/DELETE) จะ push ไปยัง client ทันที

-- เพิ่มตารางเข้า publication "supabase_realtime"
-- (Supabase ใช้ publication ชื่อนี้โดย default)

ALTER PUBLICATION supabase_realtime ADD TABLE test_results;
ALTER PUBLICATION supabase_realtime ADD TABLE brainwave_data;
ALTER PUBLICATION supabase_realtime ADD TABLE activities;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE user_settings;

-- ⚠️ วิธีรันใน Supabase Dashboard:
-- 1. ไปที่ Supabase Dashboard → SQL Editor
-- 2. Copy SQL ด้านบนไป paste
-- 3. กด Run
-- หรือ ไปที่ Database → Replication → เปิด Toggle สำหรับแต่ละตาราง

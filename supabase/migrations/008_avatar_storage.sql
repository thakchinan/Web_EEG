-- =============================================
-- Migration 008: Avatar Storage Setup
-- สร้าง Storage Bucket สำหรับเก็บรูปโปรไฟล์
-- =============================================

-- 1. สร้าง storage bucket สำหรับ avatars
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- 2. Policy: ทุกคนสามารถดู avatar ได้ (public)
CREATE POLICY "Avatar images are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

-- 3. Policy: ผู้ใช้ที่ authenticated สามารถอัปโหลดได้
CREATE POLICY "Anyone can upload an avatar"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'avatars');

-- 4. Policy: ผู้ใช้สามารถอัปเดตรูปของตัวเองได้
CREATE POLICY "Anyone can update their own avatar"
ON storage.objects FOR UPDATE
USING (bucket_id = 'avatars');

-- 5. Policy: ผู้ใช้สามารถลบรูปของตัวเองได้
CREATE POLICY "Anyone can delete their own avatar"
ON storage.objects FOR DELETE
USING (bucket_id = 'avatars');

-- 6. ตรวจสอบว่า users table มีคอลัมน์ avatar_url
-- (ถ้ายังไม่มี ให้เพิ่ม)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'users' AND column_name = 'avatar_url'
  ) THEN
    ALTER TABLE users ADD COLUMN avatar_url TEXT;
  END IF;
END $$;

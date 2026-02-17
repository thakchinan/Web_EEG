# 📋 Scrum Board — SmartBrain Care

> **โปรเจกต์**: SmartBrain Care (Flutter + Supabase)  
> **ทีม**: 4 คน  
> **วันที่สร้าง**: 16 กุมภาพันธ์ 2026  
> **Sprint Duration**: 2 สัปดาห์/sprint

---

## 👥 การแบ่งทีม (Team Roles)

| สมาชิก | บทบาท | ขอบเขตรับผิดชอบ |
|--------|--------|-----------------|
| **คนที่ 1** | 🏠 Frontend — Home & Auth | หน้า Welcome, Login, Register, Home Screen, Muse Connection, Navigation |
| **คนที่ 2** | 📅 Frontend — Activities & Games | หน้ากิจกรรม, มินิเกม 4 เกม, ผู้ดูแล, โภชนา, กิจวัตร, กำหนดการ |
| **คนที่ 3** | 🤖 Backend & AI — Chatbot & Services | AI Chatbot, RAG System, Supabase Service, API Service, TTS/STT |
| **คนที่ 4** | 👤 Frontend — Profile & Settings | โปรไฟล์, แก้ไขข้อมูล, ตั้งค่า, แบบทดสอบ PHQ-9, ประวัติ, ช่วยเหลือ |

---

## 📂 ไฟล์ที่แต่ละคนรับผิดชอบ

### 🏠 คนที่ 1 — Home & Auth

```
lib/
├── main.dart                              ← Entry point
├── theme/
│   └── app_theme.dart                     ← ธีมสี, ฟอนต์
├── screens/
│   ├── main_navigation.dart               ← Bottom Navigation (4 แท็บ)
│   ├── auth/
│   │   ├── welcome_screen.dart            ← หน้า Welcome
│   │   ├── login_screen.dart              ← หน้า Login
│   │   └── register_screen.dart           ← หน้า Register
│   └── dashboard/
│       ├── home_screen.dart               ← หน้าหลัก (876 บรรทัด)
│       ├── chart_screen.dart              ← กราฟคลื่นสมอง
│       └── history_screen.dart            ← ประวัติ (ร่วมกับคนที่ 4)
├── services/
│   ├── muse_service.dart                  ← Bluetooth + Muse EEG
│   └── fft_calculator.dart                ← คำนวณ FFT
├── models/
│   ├── user.dart                          ← โมเดลผู้ใช้
│   ├── brain_data.dart                    ← ข้อมูลคลื่นสมอง
│   ├── eeg_device.dart                    ← อุปกรณ์ EEG
│   ├── eeg_raw_data.dart                  ← ข้อมูลดิบ EEG
│   └── eeg_session.dart                   ← session EEG
```

### 📅 คนที่ 2 — Activities & Games

```
lib/screens/dashboard/
├── activities_dashboard_screen.dart       ← Dashboard กิจกรรม (511 บรรทัด)
├── mini_games_screen.dart                 ← รวมเกม (237 บรรทัด)
├── memory_game_screen.dart                ← เกมจับคู่
├── color_sequence_screen.dart             ← เกมจำสี
├── number_puzzle_screen.dart              ← ปริศนาตัวเลข
├── reaction_game_screen.dart              ← เกมปฏิกิริยา
├── caretaker_screen.dart                  ← ผู้ดูแล + สายด่วน
├── nutrition_screen.dart                  ← โภชนา
└── daily_routine_screen.dart              ← กิจวัตรประจำวัน

lib/models/
├── schedule.dart                          ← โมเดลกำหนดการ
└── activity_log.dart                      ← โมเดลบันทึกกิจกรรม
```

### 🤖 คนที่ 3 — Backend & AI

```
lib/services/
├── api_service.dart                       ← API Service หลัก (15,892 bytes)
├── supabase_service.dart                  ← Supabase CRUD (42,963 bytes)
├── chatgpt_service.dart                   ← OpenAI API (13,199 bytes)
├── rag_service.dart                       ← RAG System (16,955 bytes)
├── tts_service.dart                       ← Text-to-Speech
└── stt_service.dart                       ← Speech-to-Text

lib/screens/dashboard/
└── recommendation_screen.dart             ← หน้า AI Chatbot (793 บรรทัด)

lib/models/
├── chat_message.dart                      ← โมเดลข้อความแชท
├── conversation.dart                      ← โมเดลการสนทนา
├── medical_knowledge.dart                 ← ฐานความรู้
├── retrieval_log.dart                     ← บันทึกการค้นหา RAG
└── voice_metadata.dart                    ← ข้อมูลเสียง

supabase/migrations/
├── 001_initial_schema.sql                 ← Schema เริ่มต้น
├── 002_rag_schema.sql                     ← Schema RAG
├── 003_emergency_knowledge.sql            ← ข้อมูลฉุกเฉิน
├── 004_update_samaritans_phone.sql
├── 005_voice_emergency_schema.sql
├── 006_class_diagram_update.sql
├── 007_enable_realtime.sql
└── 008_avatar_storage.sql
```

### 👤 คนที่ 4 — Profile & Settings

```
lib/screens/dashboard/
├── profile_screen.dart                    ← หน้าโปรไฟล์ (408 บรรทัด)
├── edit_profile_screen.dart               ← แก้ไขโปรไฟล์ (17,075 bytes)
├── settings_screen.dart                   ← ตั้งค่า (215 บรรทัด)
├── change_password_screen.dart            ← เปลี่ยนรหัสผ่าน
├── notification_settings_screen.dart      ← ตั้งค่าแจ้งเตือน
├── test_screen.dart                       ← แบบทดสอบ PHQ-9 (982 บรรทัด)
├── help_screen.dart                       ← หน้าช่วยเหลือ
└── saved_items_screen.dart                ← บันทึกไว้

lib/models/
├── stress_test_result.dart                ← ผลทดสอบ
├── elderly_profile.dart                   ← โปรไฟล์ผู้สูงอายุ
├── user_settings.dart                     ← การตั้งค่า
└── emotion_log.dart                       ← บันทึกอารมณ์
```

---

## 🏃 Sprint Plan

### 🟦 Sprint 1 — Foundation & Auth (สัปดาห์ที่ 1-2)

> **เป้าหมาย**: ระบบ Auth ทำงานได้ + โครงสร้างหลักพร้อม

| # | Task | ผู้รับผิดชอบ | Story Points | สถานะ |
|---|------|-------------|-------------|-------|
| 1.1 | ตั้งค่าโปรเจกต์ Flutter, dependencies, theme | คนที่ 1 | 3 | ☐ To Do |
| 1.2 | สร้าง Supabase Project + รัน migration 001 (Schema เริ่มต้น) | คนที่ 3 | 5 | ☐ To Do |
| 1.3 | ทำหน้า Welcome Screen | คนที่ 1 | 3 | ☐ To Do |
| 1.4 | ทำหน้า Register Screen (กรอก username, password, ชื่อ, เบอร์, วันเกิด) | คนที่ 1 | 5 | ☐ To Do |
| 1.5 | ทำหน้า Login Screen | คนที่ 1 | 3 | ☐ To Do |
| 1.6 | สร้าง API Service — Login / Register / getProfile | คนที่ 3 | 5 | ☐ To Do |
| 1.7 | สร้าง Supabase Service — Auth functions + CRUD พื้นฐาน | คนที่ 3 | 8 | ☐ To Do |
| 1.8 | สร้าง Models — User, BrainData, EEGSession | คนที่ 1 | 3 | ☐ To Do |
| 1.9 | ออกแบบ UI Components พื้นฐาน (ปุ่ม, การ์ด, input field) | คนที่ 4 | 3 | ☐ To Do |
| 1.10 | สร้าง App Theme (สี, ฟอนต์, spacing) | คนที่ 1 | 2 | ☐ To Do |
| 1.11 | สร้าง Models — Schedule, ActivityLog, ChatMessage | คนที่ 2 | 3 | ☐ To Do |
| 1.12 | สร้าง Models — StressTestResult, UserSettings, EmotionLog | คนที่ 4 | 3 | ☐ To Do |

**Sprint 1 รวม**: ~46 Story Points

---

### 🟩 Sprint 2 — Home Screen & Navigation (สัปดาห์ที่ 3-4)

> **เป้าหมาย**: เข้าแอปแล้วเห็นหน้าหลักได้ + Navigation ทำงาน

| # | Task | ผู้รับผิดชอบ | Story Points | สถานะ |
|---|------|-------------|-------------|-------|
| 2.1 | สร้าง Main Navigation (Bottom Nav 4 แท็บ) | คนที่ 1 | 5 | ☐ To Do |
| 2.2 | ทำ Home Screen — Header (สวัสดี + ชื่อ + ปุ่มตั้งค่า) | คนที่ 1 | 3 | ☐ To Do |
| 2.3 | ทำ Home Screen — Muse S Connection Card | คนที่ 1 | 5 | ☐ To Do |
| 2.4 | ทำ Home Screen — สรุปสุขภาพสมอง Card | คนที่ 1 | 5 | ☐ To Do |
| 2.5 | ทำ Home Screen — Quick Actions (ประวัติ + แบบทดสอบ) | คนที่ 1 | 2 | ☐ To Do |
| 2.6 | สร้าง Muse Service (Bluetooth scan, connect, simulate) | คนที่ 1 | 8 | ☐ To Do |
| 2.7 | สร้าง FFT Calculator | คนที่ 1 | 3 | ☐ To Do |
| 2.8 | ทำ API — getBrainwaveData, saveMuseBrainwave | คนที่ 3 | 5 | ☐ To Do |
| 2.9 | ทำ Supabase Realtime — stream คลื่นสมอง + ผลทดสอบ | คนที่ 3 | 5 | ☐ To Do |
| 2.10 | สร้าง Profile Screen — Layout + ดึงข้อมูลจาก API | คนที่ 4 | 5 | ☐ To Do |
| 2.11 | สร้าง Activities Dashboard — Layout ว่าง | คนที่ 2 | 3 | ☐ To Do |
| 2.12 | สร้าง Recommendation Screen — Layout ว่าง | คนที่ 3 | 3 | ☐ To Do |

**Sprint 2 รวม**: ~52 Story Points

---

### 🟨 Sprint 3 — Core Features (สัปดาห์ที่ 5-6)

> **เป้าหมาย**: ฟีเจอร์หลักทำงานได้ (ทดสอบ, แชท, เกม, โปรไฟล์)

| # | Task | ผู้รับผิดชอบ | Story Points | สถานะ |
|---|------|-------------|-------------|-------|
| 3.1 | ทำ Test Screen — แบบทดสอบ PHQ-9 (9 ข้อ + animation) | คนที่ 4 | 8 | ☐ To Do |
| 3.2 | ทำ Test Screen — คำนวณผล + แสดง Result Sheet | คนที่ 4 | 5 | ☐ To Do |
| 3.3 | ทำ API — saveTestResult, getTestResults | คนที่ 3 | 3 | ☐ To Do |
| 3.4 | สร้าง ChatGPT Service (OpenAI API integration) | คนที่ 3 | 8 | ☐ To Do |
| 3.5 | สร้าง RAG Service (vector search + keyword search) | คนที่ 3 | 8 | ☐ To Do |
| 3.6 | ทำ Recommendation Screen — UI แชท + ส่ง/รับข้อความ | คนที่ 3 | 8 | ☐ To Do |
| 3.7 | ทำ Mini Games Screen — รวมเกม 4 เกม | คนที่ 2 | 3 | ☐ To Do |
| 3.8 | ทำ Memory Game (เกมจับคู่) | คนที่ 2 | 5 | ☐ To Do |
| 3.9 | ทำ Color Sequence Game (เกมจำสี) | คนที่ 2 | 5 | ☐ To Do |
| 3.10 | ทำ Number Puzzle Game (ปริศนาตัวเลข) | คนที่ 2 | 5 | ☐ To Do |
| 3.11 | ทำ Reaction Game (เกมปฏิกิริยา) | คนที่ 2 | 5 | ☐ To Do |
| 3.12 | ทำ Edit Profile Screen | คนที่ 4 | 5 | ☐ To Do |

**Sprint 3 รวม**: ~68 Story Points

---

### 🟧 Sprint 4 — Activities & Settings (สัปดาห์ที่ 7-8)

> **เป้าหมาย**: กิจกรรมทั้งหมด + ระบบตั้งค่า + ระบบเสียง

| # | Task | ผู้รับผิดชอบ | Story Points | สถานะ |
|---|------|-------------|-------------|-------|
| 4.1 | ทำ Activities Dashboard — ปุ่ม 4 หมวดกิจกรรม | คนที่ 2 | 3 | ☐ To Do |
| 4.2 | ทำ Activities — ระบบกำหนดการ (เพิ่ม/ลบ/แสดง) | คนที่ 2 | 5 | ☐ To Do |
| 4.3 | ทำ API — getSchedules, addSchedule, deleteSchedule | คนที่ 3 | 3 | ☐ To Do |
| 4.4 | ทำ Caretaker Screen (ผู้ดูแล + สายด่วนฉุกเฉิน) | คนที่ 2 | 5 | ☐ To Do |
| 4.5 | ทำ Nutrition Screen (โภชนา) | คนที่ 2 | 3 | ☐ To Do |
| 4.6 | ทำ Daily Routine Screen (กิจวัตร timeline) | คนที่ 2 | 5 | ☐ To Do |
| 4.7 | ทำ Settings Screen | คนที่ 4 | 3 | ☐ To Do |
| 4.8 | ทำ Change Password Screen | คนที่ 4 | 5 | ☐ To Do |
| 4.9 | ทำ Notification Settings Screen | คนที่ 4 | 3 | ☐ To Do |
| 4.10 | ทำ Delete Account (+ Supabase cascade delete) | คนที่ 4 | 5 | ☐ To Do |
| 4.11 | สร้าง TTS Service (Text-to-Speech ภาษาไทย) | คนที่ 3 | 3 | ☐ To Do |
| 4.12 | สร้าง STT Service (Speech-to-Text) | คนที่ 3 | 5 | ☐ To Do |
| 4.13 | Integrate TTS + STT เข้า Recommendation Screen | คนที่ 3 | 5 | ☐ To Do |

**Sprint 4 รวม**: ~53 Story Points

---

### 🟥 Sprint 5 — Polish & Integration (สัปดาห์ที่ 9-10)

> **เป้าหมาย**: ปรับแต่ง UI, แก้ bug, ทดสอบ, เอกสาร

| # | Task | ผู้รับผิดชอบ | Story Points | สถานะ |
|---|------|-------------|-------------|-------|
| 5.1 | ทำ History Screen (ประวัติผลทดสอบ) | คนที่ 4 | 3 | ☐ To Do |
| 5.2 | ทำ Help Screen (วิธีใช้ + ติดต่อ + สายด่วน) | คนที่ 4 | 3 | ☐ To Do |
| 5.3 | ทำ Saved Items Screen (บันทึกไว้) | คนที่ 4 | 3 | ☐ To Do |
| 5.4 | ทำ Chart Screen (กราฟคลื่นสมอง fl_chart) | คนที่ 1 | 5 | ☐ To Do |
| 5.5 | รัน Supabase Migration 002-008 (RAG, emergency, realtime, avatar) | คนที่ 3 | 5 | ☐ To Do |
| 5.6 | เพิ่มข้อมูลฐานความรู้ RAG (คลื่นสมอง, สุขภาพจิต, ฉุกเฉิน) | คนที่ 3 | 5 | ☐ To Do |
| 5.7 | ทำ Avatar Upload (image_picker + Supabase Storage) | คนที่ 4 | 5 | ☐ To Do |
| 5.8 | เพิ่มปุ่ม Back ทุกหน้า + ปุ่ม Settings ทุกหน้า | คนที่ 1 | 3 | ☐ To Do |
| 5.9 | ทดสอบ Auth Flow ครบ (Register → Login → Home → Logout) | คนที่ 1 | 2 | ☐ To Do |
| 5.10 | ทดสอบ Muse Connection (จริง + Simulation) | คนที่ 1 | 3 | ☐ To Do |
| 5.11 | ทดสอบ AI Chatbot ครบ (ส่ง, รับ, TTS, STT, RAG) | คนที่ 3 | 3 | ☐ To Do |
| 5.12 | ทดสอบ PHQ-9 ครบ (ตอบ 9 ข้อ → ผลลัพธ์ → บันทึก Supabase) | คนที่ 4 | 2 | ☐ To Do |
| 5.13 | ทดสอบเกมทั้ง 4 เกม | คนที่ 2 | 2 | ☐ To Do |
| 5.14 | ทดสอบกำหนดการ (เพิ่ม/ลบ/refresh) | คนที่ 2 | 2 | ☐ To Do |
| 5.15 | เขียน USER_GUIDE.md | คนที่ 2 | 3 | ☐ To Do |
| 5.16 | เขียน README.md | คนที่ 1 | 3 | ☐ To Do |
| 5.17 | Pull to Refresh ทุกหน้าที่โหลดข้อมูล | ทุกคน | 2 | ☐ To Do |

**Sprint 5 รวม**: ~54 Story Points

---

## 📊 สรุป Workload ต่อคน

### คนที่ 1 — 🏠 Home & Auth

| Sprint | รายการ | SP |
|--------|--------|-----|
| Sprint 1 | ตั้งค่าโปรเจกต์, Welcome, Register, Login, Theme, Models | 22 |
| Sprint 2 | Navigation, Home Screen (ทุกส่วน), Muse Service, FFT | 31 |
| Sprint 5 | Chart, Back Buttons, ทดสอบ Auth + Muse, README | 16 |
| **รวม** | | **69 SP** |

### คนที่ 2 — 📅 Activities & Games

| Sprint | รายการ | SP |
|--------|--------|-----|
| Sprint 1 | Models (Schedule, ActivityLog) | 3 |
| Sprint 2 | Activities Dashboard layout | 3 |
| Sprint 3 | Mini Games Screen + 4 เกม | 23 |
| Sprint 4 | Dashboard, กำหนดการ, ผู้ดูแล, โภชนา, กิจวัตร | 21 |
| Sprint 5 | ทดสอบเกม + กำหนดการ, USER_GUIDE | 7 |
| **รวม** | | **57 SP** |

### คนที่ 3 — 🤖 Backend & AI

| Sprint | รายการ | SP |
|--------|--------|-----|
| Sprint 1 | Supabase setup, API Service, Supabase Service | 18 |
| Sprint 2 | API brainwave, Realtime, Chat layout | 13 |
| Sprint 3 | ChatGPT Service, RAG Service, Chat UI | 27 |
| Sprint 4 | Schedule API, TTS, STT, Integration | 16 |
| Sprint 5 | Migrations, RAG data, ทดสอบ Chatbot | 13 |
| **รวม** | | **87 SP** |

### คนที่ 4 — 👤 Profile & Settings

| Sprint | รายการ | SP |
|--------|--------|-----|
| Sprint 1 | UI Components, Models | 6 |
| Sprint 2 | Profile Screen | 5 |
| Sprint 3 | PHQ-9 Test (UI + ผล), Edit Profile | 18 |
| Sprint 4 | Settings, Password, Notification, Delete Account | 16 |
| Sprint 5 | History, Help, SavedItems, Avatar, ทดสอบ PHQ-9 | 16 |
| **รวม** | | **61 SP** |

---

## 📈 สรุปภาพรวม

```
คนที่ 1 (Home/Auth)    : ████████████████████░░░░░  69 SP
คนที่ 2 (Activities)   : ██████████████░░░░░░░░░░░  57 SP
คนที่ 3 (Backend/AI)   : █████████████████████████  87 SP ⭐ งานหนักสุด
คนที่ 4 (Profile/Test) : ███████████████░░░░░░░░░░  61 SP
                                              รวม: 274 SP
```

> ⚠️ **หมายเหตุ**: คนที่ 3 มี workload สูงสุดเพราะดูแล Backend + AI ทั้งหมด  
> แนะนำให้คนที่ 1 หรือ 2 **ช่วยเขียน API calls** หรือ **ทดสอบ backend** เพิ่ม

---

## ✅ Definition of Done (DoD)

แต่ละ Task จะถือว่า **"เสร็จ"** เมื่อ:

- [ ] โค้ดทำงานได้ไม่มี error
- [ ] ทดสอบบน Simulator/Emulator แล้ว
- [ ] UI ตรงตาม design (สี, ฟอนต์, spacing)
- [ ] เชื่อมต่อ Supabase ได้ (ถ้ามี backend)
- [ ] ไม่มี warning จาก `flutter analyze`
- [ ] Code review ผ่าน (อย่างน้อย 1 คนรีวิว)

---

## 🔄 Daily Standup (ประชุมรายวัน)

ทุกวัน 15 นาที ตอบ 3 คำถาม:
1. **เมื่อวาน** ทำอะไรไปบ้าง?
2. **วันนี้** จะทำอะไร?
3. มี **ปัญหา/ติดขัด** อะไรไหม?

---

## 📝 User Stories

### Epic 1: ระบบ Authentication
- ✍️ **US-01**: ในฐานะผู้ใช้ใหม่ ฉันต้องการสมัครสมาชิกด้วย username, password, ชื่อ, เบอร์, วันเกิด เพื่อเข้าใช้แอปได้
- ✍️ **US-02**: ในฐานะผู้ใช้ ฉันต้องการ login ด้วย username/password เพื่อเข้าใช้แอป
- ✍️ **US-03**: ในฐานะผู้ใช้ ฉันต้องการ logout เพื่อออกจากระบบอย่างปลอดภัย

### Epic 2: Muse EEG & คลื่นสมอง
- ✍️ **US-04**: ในฐานะผู้ใช้ ฉันต้องการเชื่อมต่อ Muse S ผ่าน Bluetooth เพื่อวัดคลื่นสมอง real-time
- ✍️ **US-05**: ในฐานะผู้ใช้ ฉันต้องการใช้โหมดจำลอง เมื่อไม่มีอุปกรณ์ Muse
- ✍️ **US-06**: ในฐานะผู้ใช้ ฉันต้องการบันทึกข้อมูลคลื่นสมองลง Supabase
- ✍️ **US-07**: ในฐานะผู้ใช้ ฉันต้องการเห็นคลื่นสมอง 5 ชนิด (Delta, Theta, Alpha, Beta, Gamma) ในหน้าหลัก

### Epic 3: แบบทดสอบ PHQ-9
- ✍️ **US-08**: ในฐานะผู้ใช้ ฉันต้องการทำแบบทดสอบ PHQ-9 (9 ข้อ) เพื่อประเมินภาวะซึมเศร้า
- ✍️ **US-09**: ในฐานะผู้ใช้ ฉันต้องการเห็นผลลัพธ์ทันทีพร้อมคำแนะนำหลังทำเสร็จ
- ✍️ **US-10**: ในฐานะผู้ใช้ ฉันต้องการดูประวัติผลทดสอบย้อนหลังทั้งหมด

### Epic 4: AI Chatbot
- ✍️ **US-11**: ในฐานะผู้ใช้ ฉันต้องการพิมพ์คำถามเกี่ยวกับสุขภาพจิตและรับคำตอบจาก AI
- ✍️ **US-12**: ในฐานะผู้ใช้ ฉันต้องการพูดคำถามด้วยเสียง (Speech-to-Text)
- ✍️ **US-13**: ในฐานะผู้ใช้ ฉันต้องการฟัง AI ตอบเป็นเสียง (Text-to-Speech)
- ✍️ **US-14**: ในฐานะผู้ใช้ ฉันต้องการให้ AI ค้นหาจากฐานความรู้ (RAG) ก่อนตอบ

### Epic 5: เกมฝึกสมอง
- ✍️ **US-15**: ในฐานะผู้ใช้ ฉันต้องการเล่นเกมจับคู่ เพื่อฝึกความจำ
- ✍️ **US-16**: ในฐานะผู้ใช้ ฉันต้องการเล่นเกมจำสี เพื่อฝึกความจำลำดับ
- ✍️ **US-17**: ในฐานะผู้ใช้ ฉันต้องการเล่นเกมปริศนาตัวเลข เพื่อฝึกตรรกะ
- ✍️ **US-18**: ในฐานะผู้ใช้ ฉันต้องการเล่นเกมปฏิกิริยา เพื่อฝึกความเร็วตอบสนอง

### Epic 6: กิจกรรม
- ✍️ **US-19**: ในฐานะผู้ใช้ ฉันต้องการดูข้อมูลผู้ดูแลและเบอร์ฉุกเฉิน
- ✍️ **US-20**: ในฐานะผู้ใช้ ฉันต้องการดูอาหารบำรุงสมอง
- ✍️ **US-21**: ในฐานะผู้ใช้ ฉันต้องการดูกิจวัตรประจำวันที่แนะนำ
- ✍️ **US-22**: ในฐานะผู้ใช้ ฉันต้องการเพิ่ม/ลบกำหนดการส่วนตัว

### Epic 7: โปรไฟล์ & ตั้งค่า
- ✍️ **US-23**: ในฐานะผู้ใช้ ฉันต้องการดู/แก้ไขข้อมูลส่วนตัว
- ✍️ **US-24**: ในฐานะผู้ใช้ ฉันต้องการเปลี่ยนรหัสผ่าน
- ✍️ **US-25**: ในฐานะผู้ใช้ ฉันต้องการตั้งค่าการแจ้งเตือน (เสียง, สั่น)
- ✍️ **US-26**: ในฐานะผู้ใช้ ฉันต้องการลบบัญชีถาวร
- ✍️ **US-27**: ในฐานะผู้ใช้ ฉันต้องการดูวิธีใช้งานแอปและเบอร์ติดต่อ

---

## 🏷️ Technology Stack

| หมวด | เทคโนโลยี |
|------|----------|
| **Frontend** | Flutter (Dart) |
| **Backend** | Supabase (PostgreSQL + Realtime + Storage) |
| **AI** | OpenAI GPT API + RAG |
| **Bluetooth** | flutter_blue_plus |
| **Voice** | flutter_tts + speech_to_text |
| **Charts** | fl_chart |
| **State Management** | Provider |
| **Image** | image_picker |

---

> 📝 **อัปเดตสถานะงาน**: เปลี่ยน `☐ To Do` → `🔄 In Progress` → `✅ Done`

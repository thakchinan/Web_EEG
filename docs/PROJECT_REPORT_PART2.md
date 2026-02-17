
### 3.3 Use Case Diagram

```
                          ┌─────────────────────┐
                          │   SmartBrain Care    │
                          │      System          │
       ┌──────────────────┼─────────────────────┼──────────────────┐
       │                  │                     │                  │
       │    ┌─────────────┴──────────┐          │                  │
       │    │ UC-01: สมัครสมาชิก      │          │                  │
       │    │ UC-02: เข้าสู่ระบบ      │          │                  │
       │    │ UC-03: ออกจากระบบ       │          │                  │
       │    └────────────────────────┘          │                  │
       │                                        │                  │
       │    ┌────────────────────────┐          │                  │
       │    │ UC-04: ดูคลื่นสมอง     │          │                  │
  ┌────┤    │ UC-05: เชื่อมต่อ Muse S│          │                  │
  │    │    │ UC-06: บันทึกข้อมูล EEG │          │                  │
  │    │    └────────────────────────┘          │                  │
  │    │                                        │                  │
  │☻   │    ┌────────────────────────┐          │  ┌────────────┐  │
  │ผู้ใช้│    │ UC-07: ทำแบบทดสอบ PHQ-9│          │  │  OpenAI    │  │
  │    ├───▶│ UC-08: ดูผลประเมิน     │          ├─▶│  GPT API   │  │
  │    │    │ UC-09: ดูประวัติทดสอบ   │          │  └────────────┘  │
  │    │    └────────────────────────┘          │                  │
  │    │                                        │  ┌────────────┐  │
  │    │    ┌────────────────────────┐          │  │  Supabase   │  │
  │    │    │ UC-10: แชทกับ AI       │          ├─▶│  Cloud      │  │
  │    ├───▶│ UC-11: สั่งด้วยเสียง   │          │  └────────────┘  │
  │    │    │ UC-12: ฟัง AI ตอบเสียง  │          │                  │
  │    │    └────────────────────────┘          │  ┌────────────┐  │
  │    │                                        │  │  Muse S    │  │
  │    │    ┌────────────────────────┐          ├─▶│  Device     │  │
  │    │    │ UC-13: เล่นเกมฝึกสมอง  │          │  └────────────┘  │
  │    ├───▶│ UC-14: จัดการกำหนดการ  │          │                  │
  │    │    │ UC-15: ดูโภชนาการ      │          │                  │
  │    │    └────────────────────────┘          │                  │
  │    │                                        │                  │
  │    │    ┌────────────────────────┐          │                  │
  │    │    │ UC-16: แก้ไขโปรไฟล์    │          │                  │
  └────├───▶│ UC-17: ตั้งค่าแจ้งเตือน│          │                  │
       │    │ UC-18: เปลี่ยนรหัสผ่าน  │          │                  │
       │    │ UC-19: ลบบัญชี         │          │                  │
       │    └────────────────────────┘          │                  │
       └────────────────────────────────────────┴──────────────────┘
```

### 3.4 Sequence Diagram — การทำงานหลัก

#### 3.4.1 Login Flow
```
ผู้ใช้           LoginScreen       ApiService       SupabaseService     Supabase DB
  │                  │                │                   │                 │
  │─── กรอก user/pass ──▶│            │                   │                 │
  │                  │──── login() ──▶│                   │                 │
  │                  │                │── login() ────────▶│                │
  │                  │                │                   │── SELECT * ────▶│
  │                  │                │                   │◀── user data ──│
  │                  │                │◀── { success } ──│                 │
  │                  │◀── user obj ──│                    │                 │
  │◀── ไปหน้า Home ──│                │                   │                 │
```

#### 3.4.2 AI Chatbot with RAG Flow
```
ผู้ใช้      RecommendScreen    ChatGPTService     RAGService      OpenAI API     Supabase
  │              │                  │                │               │              │
  │── พิมพ์คำถาม ──▶│                │                │               │              │
  │              │── sendMessageWithRAG() ─▶│         │               │              │
  │              │                  │── searchKnowledge() ──▶│        │              │
  │              │                  │                │── createEmbedding() ──▶│      │
  │              │                  │                │◀── embedding ──│              │
  │              │                  │                │── vectorSearch() ────────────▶│
  │              │                  │                │◀── knowledge results ────────│
  │              │                  │◀── context ───│                │              │
  │              │                  │── buildUserContext() ─▶│       │              │
  │              │                  │◀── user context ──────│       │              │
  │              │                  │── GPT API call (context + question) ──▶│      │
  │              │                  │◀── AI response ───────────────│              │
  │              │◀── คำตอบ ────────│                │               │              │
  │◀── แสดงคำตอบ ──│                │                │               │              │
```

#### 3.4.3 Muse S EEG Data Flow
```
Muse S         MuseService        FFTCalculator     HomeScreen      ApiService     Supabase
  │                │                   │                │              │              │
  │── BLE packet ─▶│                   │                │              │              │
  │                │── parseEEGPacket()│                │              │              │
  │                │── addToWindow() ──│                │              │              │
  │                │                   │                │              │              │
  │ (every 256 samples)                │                │              │              │
  │                │── calculateFFT() ─▶│               │              │              │
  │                │                   │── FFT ──▶      │              │              │
  │                │◀── band powers ──│                 │              │              │
  │                │── notifyListeners() ───────────────▶│             │              │
  │                │                   │                │◀ update UI   │              │
  │                │                   │                │              │              │
  │ (user กด "บันทึก")                 │                │              │              │
  │                │                   │                │── saveMuse() ▶│             │
  │                │                   │                │              │── INSERT ───▶│
  │                │                   │                │              │◀── ok ──────│
```

### 3.5 Class Diagram (หลัก)

```
┌────────────────────────┐     ┌─────────────────────────┐
│     MuseService        │     │     ChatGPTService       │
│     (ChangeNotifier)   │     ├─────────────────────────┤
├────────────────────────┤     │ - _apiKey: String        │
│ - _device: BtDevice?   │     │ - _ragEnabled: bool      │
│ - _isConnected: bool   │     │ - _userId: int?          │
│ - _isScanning: bool    │     ├─────────────────────────┤
│ - _isSimulating: bool  │     │ + sendMessage()          │
│ - _brainwaveData: Data │     │ + sendMessageWithRAG()   │
│ - _eegWindow: List     │     │ + setUserId()            │
├────────────────────────┤     │ + toggleRAG()            │
│ + startScan()          │     └──────────┬──────────────┘
│ + stopScan()           │                │ uses
│ + connectToDevice()    │                ▼
│ + disconnect()         │     ┌─────────────────────────┐
│ + startSimulation()    │     │     RAGService           │
│ + getPower()           │     ├─────────────────────────┤
│ - _calculateFFT()      │     │ + createEmbedding()      │
│ - _parseMuseEEGPacket()│     │ + searchKnowledge()      │
│ - _processEEGData()    │     │ + buildContext()         │
└────────────────────────┘     │ + buildUserContext()     │
                               │ + addKnowledge()         │
┌────────────────────────┐     │ - _vectorSearch()        │
│    SupabaseService     │     │ - _keywordSearch()       │
├────────────────────────┤     │ - _broadSearch()         │
│ + initialize()         │     └─────────────────────────┘
│ + login()              │
│ + register()           │     ┌─────────────────────────┐
│ + getProfile()         │     │     ApiService           │
│ + updateProfile()      │     │     (Wrapper/Facade)     │
│ + uploadAvatar()       │     ├─────────────────────────┤
│ + changePassword()     │     │ + login()                │
│ + saveTestResult()     │     │ + register()             │
│ + getTestResults()     │     │ + getProfile()           │
│ + saveBrainwaveData()  │     │ + saveTestResult()       │
│ + getBrainwaveData()   │     │ + sendChatGPTMessage()   │
│ + getSchedules()       │     │ + saveMuseBrainwave()    │
│ + addSchedule()        │     │ + getSchedules()         │
│ + deleteSchedule()     │     │  ... (delegates to       │
│ + sendChatMessage()    │     │       SupabaseService)   │
│ + getChatHistory()     │     └─────────────────────────┘
│ + getSettings()        │
│ + updateSettings()     │
│ + deleteAccount()      │
└────────────────────────┘
```

### 3.6 Directory Structure

```
brain_wave_flutter/
├── lib/
│   ├── main.dart                          # Entry point
│   ├── theme/
│   │   └── app_theme.dart                 # สี, ฟอนต์, ธีม
│   ├── models/                            # Data Models
│   │   ├── user.dart
│   │   ├── brain_data.dart
│   │   ├── chat_message.dart
│   │   ├── schedule.dart
│   │   ├── stress_test_result.dart
│   │   ├── user_settings.dart
│   │   └── ... (12 models)
│   ├── services/                          # Business Logic
│   │   ├── api_service.dart               # API Wrapper (Facade)
│   │   ├── supabase_service.dart          # Supabase CRUD (1,296 lines)
│   │   ├── chatgpt_service.dart           # OpenAI GPT Integration
│   │   ├── rag_service.dart               # RAG: Vector + Keyword Search
│   │   ├── muse_service.dart              # Bluetooth + EEG Processing
│   │   ├── fft_calculator.dart            # Fast Fourier Transform
│   │   ├── tts_service.dart               # Text-to-Speech
│   │   └── stt_service.dart               # Speech-to-Text
│   └── screens/                           # UI Screens
│       ├── main_navigation.dart           # Bottom Navigation (4 tabs)
│       ├── auth/
│       │   ├── welcome_screen.dart
│       │   ├── login_screen.dart
│       │   └── register_screen.dart
│       └── dashboard/
│           ├── home_screen.dart           # หน้าหลัก (876 lines)
│           ├── recommendation_screen.dart # AI Chatbot (793 lines)
│           ├── profile_screen.dart        # โปรไฟล์
│           ├── activities_dashboard_screen.dart  # กิจกรรม
│           ├── test_screen.dart           # PHQ-9 (982 lines)
│           ├── mini_games_screen.dart     # เกม 4 เกม
│           ├── settings_screen.dart       # ตั้งค่า
│           ├── help_screen.dart           # ช่วยเหลือ
│           └── ... (15 screen files)
├── supabase/
│   └── migrations/                        # Database Migrations
│       ├── 001_initial_schema.sql         # 7 ตาราง + RLS
│       ├── 002_rag_schema.sql             # RAG: pgvector + knowledge
│       ├── 003_emergency_knowledge.sql
│       └── ... (8 migration files)
├── assets/images/                         # รูปภาพ
├── pubspec.yaml                           # Dependencies
└── docs/                                  # เอกสาร
    └── PROJECT_REPORT.md                  # รายงานนี้
```

---

## บทที่ 4 การพัฒนาระบบ

### 4.1 การตั้งค่าฐานข้อมูล Supabase

ฐานข้อมูลมีทั้งหมด **10 ตาราง** แบ่งเป็น 2 กลุ่ม:

**กลุ่ม Core (7 ตาราง):**

| ตาราง | จำนวน Column | คำอธิบาย |
|-------|-------------|---------|
| `users` | 9 | ข้อมูลผู้ใช้ (username, password, full_name, email, phone, birth_date, avatar_url) |
| `user_settings` | 9 | การตั้งค่า (daily_reminder, weekly_report, stress_alert, dark_mode, language) |
| `brainwave_data` | 10 | ข้อมูลคลื่นสมอง EEG 5 ชนิด + attention + meditation scores |
| `test_results` | 6 | ผล PHQ-9 (stress_score, depression_score, stress_level) |
| `activities` | 7 | กิจกรรม (activity_type, score, duration_minutes) |
| `schedules` | 8 | กำหนดการ (title, time, icon_name, color, is_completed) |
| `chat_messages` | 5 | ประวัติแชท AI (message, is_bot) |

**กลุ่ม RAG (3 ตาราง):**

| ตาราง | จำนวน Column | คำอธิบาย |
|-------|-------------|---------|
| `knowledge_base` | 8 | ฐานความรู้ + embedding vector(1536) + tags + metadata |
| `chat_context` | 7 | บริบทการสนทนา + embedding |
| `user_knowledge` | 6 | ข้อมูลเฉพาะผู้ใช้ + embedding |

**Database Functions (3 ฟังก์ชัน):**
1. `search_knowledge()` — Vector similarity search (cosine)
2. `hybrid_search()` — Hybrid: vector 70% + keyword 30%
3. `get_user_context()` — ดึงบริบทผู้ใช้ (brainwave avg + stress level + recent activities)

**ความปลอดภัย:**
- Row Level Security (RLS) เปิดใช้งานทุกตาราง
- Auto-update timestamp trigger บน users และ user_settings
- `ON DELETE CASCADE` ทุก foreign key

### 4.2 การพัฒนา Muse S Integration

กระบวนการรับข้อมูล EEG จาก Muse S:

1. **Bluetooth Scanning** — สแกนอุปกรณ์ BLE ที่มีชื่อ "Muse"
2. **Connection** — เชื่อมต่อ GATT แล้วค้นหา EEG Characteristics (UUID: 273e0003-0009)
3. **Data Parsing** — แปลง raw bytes เป็น μV samples (12-bit unsigned, reference 1682.815 μV)
4. **FFT Processing** — สะสม 256 samples แล้วทำ FFT เพื่อแยก band powers
5. **Band Power Extraction**: Delta (0.5-4Hz), Theta (4-8Hz), Alpha (8-13Hz), Beta (13-30Hz), Gamma (30+Hz)
6. **Real-time Display** — อัปเดต UI ทุกรอบ FFT ผ่าน ChangeNotifier

### 4.3 การพัฒนาระบบ RAG

ขั้นตอนการค้นหาความรู้:
1. สร้าง embedding จากคำถาม (OpenAI `text-embedding-3-small`, 1536 dimensions)
2. **Vector Search**: เทียบ cosine similarity กับ `knowledge_base.embedding` (threshold 0.3)
3. **Keyword Search (fallback)**: แยกคำสำคัญ → ค้นหา ILIKE ใน title + content
4. **Broad Search**: แยกคำ → ค้นหาทีละคำ (กรณี vector ไม่พบผลลัพธ์)
5. รวมผลลัพธ์ ลบรายการซ้ำ → ส่งเป็น context ให้ GPT

**Knowledge Base เริ่มต้น:** 13 entries ครอบคลุมหมวด brainwave, mental_health, meditation, sleep, device

### 4.4 การพัฒนาแบบทดสอบ PHQ-9

- 9 คำถามภาษาไทย พร้อม 4 ตัวเลือก (0-3 คะแนน)
- Navigation ด้วย animation (FadeTransition)
- Progress bar แบบ linear
- Result sheet แสดง gauge + ระดับ + คำแนะนำ
- บันทึกผลทันทีลง Supabase (`test_results`)

### 4.5 การพัฒนาเกมฝึกสมอง

| เกม | กลไก | ทักษะที่ฝึก |
|-----|-------|-----------|
| **Memory Game** | เปิดการ์ดจับคู่ | ความจำระยะสั้น |
| **Color Sequence** | จำลำดับสีแล้วกดตาม | ความจำลำดับ |
| **Number Puzzle** | เรียงตัวเลขตามลำดับ | ตรรกะ, การวางแผน |
| **Reaction Game** | กดเร็วเมื่อสีเปลี่ยน | ความเร็วปฏิกิริยา |

---

## บทที่ 5 ผลการดำเนินงาน

### 5.1 ผลลัพธ์หน้าจอแอปพลิเคชัน

#### 5.1.1 หน้า Welcome / Login / Register
- หน้า Welcome แสดงโลโก้และปุ่ม "เข้าสู่ระบบ" / "สมัครสมาชิก"
- หน้า Login รับ username + password พร้อม validation
- หน้า Register รับข้อมูล 5 ฟิลด์ พร้อมตรวจสอบ username ซ้ำ

#### 5.1.2 หน้าหลัก (Home Screen)
- แสดง header ทักทายผู้ใช้ + ปุ่มตั้งค่า
- Card เชื่อมต่อ Muse S (ปุ่มเชื่อมต่อ / โหมดจำลอง)
- แสดงค่าคลื่นสมอง 5 ชนิดแบบ real-time
- Card สรุปสุขภาพสมอง (PHQ-9 score + ระดับ + วันที่ทดสอบ)
- Quick Actions: ประวัติ + แบบทดสอบ

#### 5.1.3 AI Chatbot (คำแนะนำ)
- Chat UI พร้อมแบ่ง bubble ผู้ใช้/AI
- ปุ่มไมค์สำหรับ Speech-to-Text
- ปุ่มลำโพงบนข้อความ AI สำหรับ Text-to-Speech
- ค้นหาจาก RAG อัตโนมัติก่อนตอบ

#### 5.1.4 แบบทดสอบ PHQ-9
- หน้าเริ่มต้นแสดงข้อมูล PHQ-9 + เกณฑ์คะแนน
- แสดงคำถามทีละข้อพร้อม progress bar
- Animation เปลี่ยนข้อ
- Result sheet แสดง gauge + ระดับ + คำแนะนำ

#### 5.1.5 กิจกรรม
- Grid 4 หมวด: ผู้ดูแล, เกมคลายเครียด, รู้โภชนา, จากกิจวัตร
- รายการกำหนดการพร้อมปุ่มเพิ่ม/ลบ

#### 5.1.6 โปรไฟล์
- แสดงข้อมูลส่วนตัว (ชื่อ, เบอร์, อีเมล, วันเกิด)
- เมนู: แก้ไข, บันทึกไว้, ตั้งค่า, ช่วยเหลือ, ออกจากระบบ

### 5.2 ผลการทดสอบระบบ

| ฟีเจอร์ | ผลการทดสอบ | หมายเหตุ |
|---------|-----------|---------|
| สมัครสมาชิก / เข้าสู่ระบบ | ✅ ผ่าน | ตรวจ username ซ้ำ + validate ครบ |
| เชื่อมต่อ Muse S (BLE) | ✅ ผ่าน | ทดสอบกับ Muse S จริง + Simulation |
| แสดงคลื่นสมอง real-time | ✅ ผ่าน | อัปเดตทุก ~1 วินาที (256 samples/FFT) |
| บันทึกคลื่นสมองลง Supabase | ✅ ผ่าน | INSERT สำเร็จ + ดึงกลับมาได้ |
| แบบทดสอบ PHQ-9 (9 ข้อ) | ✅ ผ่าน | คำนวณคะแนนถูกต้อง 5 ระดับ |
| ประวัติผลทดสอบ | ✅ ผ่าน | เรียงตามวันที่ + แสดงระดับ/สี |
| AI Chatbot + RAG | ✅ ผ่าน | ค้นหา knowledge base ก่อนตอบ |
| Voice Input (STT) | ✅ ผ่าน | รองรับภาษาไทย (th-TH) |
| Voice Output (TTS) | ✅ ผ่าน | อ่านข้อความภาษาไทย |
| เกมฝึกสมอง 4 เกม | ✅ ผ่าน | เล่นได้ครบ + scoring ทำงาน |
| กำหนดการ (เพิ่ม/ลบ) | ✅ ผ่าน | CRUD Supabase สมบูรณ์ |
| แก้ไขโปรไฟล์ + อัปโหลดรูป | ✅ ผ่าน | ใช้ Supabase Storage |
| เปลี่ยนรหัสผ่าน | ✅ ผ่าน | ตรวจรหัสเดิม + อัปเดต |
| ลบบัญชี | ✅ ผ่าน | CASCADE ลบข้อมูลทั้งหมด |
| ตั้งค่าการแจ้งเตือน | ✅ ผ่าน | บันทึก Supabase อัตโนมัติ |

---

## บทที่ 6 สรุปผลและข้อเสนอแนะ

### 6.1 สรุปผล

โครงงาน SmartBrain Care ได้พัฒนาแอปพลิเคชันดูแลสุขภาพจิตที่ผสานเทคโนโลยีหลายด้านเข้าด้วยกัน ดังนี้:

1. **ระบบติดตามคลื่นสมอง** — เชื่อมต่อ Muse S ผ่าน BLE, ประมวลผล FFT แยก 5 bands, แสดง real-time, บันทึกลง Supabase
2. **AI Chatbot อัจฉริยะ** — ใช้ OpenAI GPT-4o-mini ร่วมกับ RAG (pgvector + hybrid search) ให้คำตอบแม่นยำจากฐานความรู้ 13 entries
3. **แบบประเมิน PHQ-9** — 9 คำถามมาตรฐานสากล, ระบบ scoring 5 ระดับ, เก็บประวัติ
4. **เกมฝึกสมอง 4 เกม** — ฝึกความจำ, ตรรกะ, สมาธิ, ปฏิกิริยา
5. **ระบบจัดการกิจกรรม** — กำหนดการ, ข้อมูลผู้ดูแล, โภชนาการ, กิจวัตร
6. **ระบบ Voice I/O** — STT สั่งด้วยเสียง, TTS ฟังคำตอบ AI

ผลการทดสอบแสดงว่าทุกฟีเจอร์ทำงานได้ถูกต้องตามข้อกำหนด ข้อมูลถูกจัดเก็บอย่างปลอดภัยด้วย Row Level Security บน Supabase

### 6.2 ปัญหาและอุปสรรค

1. **Bluetooth บน macOS** — สิทธิ์ TCC ทำให้บางครั้งเชื่อมต่อ Muse ไม่ได้ แก้โดย request permissions ก่อนใช้งาน
2. **STT บน macOS** — speech_to_text plugin ต้องการ microphone permission ที่ macOS แก้โดยทำ initialization แบบ conditional
3. **Thai Language Search** — PostgreSQL ไม่รองรับ Thai text search config ดั้งเดิม แก้โดยใช้ 'simple' config + keyword fallback
4. **RAG Embedding** — ต้อง generate embeddings แยก ทำให้ knowledge ใหม่ต้องรอ embedding ก่อนค้นหา vector ได้

### 6.3 ข้อเสนอแนะในการพัฒนาต่อ

1. **เพิ่มระบบ Notification** — แจ้งเตือนทำกิจกรรมตามกำหนดการ (Push Notification)
2. **เพิ่มวิเคราะห์แนวโน้ม** — กราฟแสดงแนวโน้มคลื่นสมองและสุขภาพจิตรายสัปดาห์/เดือน
3. **เพิ่มฐานความรู้ RAG** — ขยายจาก 13 entries เป็น 100+ entries ครอบคลุมหัวข้อมากขึ้น
4. **รองรับหลายภาษา** — เพิ่มภาษาอังกฤษ
5. **เพิ่ม Gamification** — ระบบ streak, badge, leaderboard สำหรับเกมฝึกสมอง
6. **เพิ่มเกม** — เกมหมากรุก, Sudoku, Word Search
7. **เพิ่มระบบ Caretaker แบบเชื่อมต่อ** — ให้ผู้ดูแลดูข้อมูลผู้ใช้ได้แบบ real-time
8. **Machine Learning** — วิเคราะห์คลื่นสมองด้วย ML เพื่อทำนายสภาวะอารมณ์ล่วงหน้า

---

## บรรณานุกรม

1. Kroenke, K., Spitzer, R. L., & Williams, J. B. (2001). The PHQ-9: validity of a brief depression severity measure. *Journal of General Internal Medicine*, 16(9), 606-613.
2. Krigolson, O. E., et al. (2017). Using Muse: Rapid mobile assessment of resting state EEG. *Frontiers in Neuroscience*, 11, 1-10.
3. Lewis, P., et al. (2020). Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks. *Advances in Neural Information Processing Systems*, 33.
4. Flutter Documentation. (2025). https://docs.flutter.dev/
5. Supabase Documentation. (2025). https://supabase.com/docs
6. OpenAI API Reference. (2025). https://platform.openai.com/docs/api-reference
7. InteraXon Inc. (2024). Muse S (Gen 2) Technical Specifications. https://choosemuse.com/
8. pgvector. (2025). Open-source vector similarity search for Postgres. https://github.com/pgvector/pgvector

---

## ภาคผนวก

### ภาคผนวก ก — SQL Schema (ย่อ)

ดูไฟล์ฉบับเต็ม: `supabase/migrations/001_initial_schema.sql` และ `002_rag_schema.sql`

### ภาคผนวก ข — API Endpoints (ผ่าน Supabase Service)

| Method | Function | คำอธิบาย |
|--------|----------|---------|
| `login()` | username, password | เข้าสู่ระบบ |
| `register()` | username, password, fullName, phone, birthDate | สมัครสมาชิก |
| `getProfile()` | userId | ดึงข้อมูลผู้ใช้ |
| `updateProfile()` | userId, fields... | แก้ไขโปรไฟล์ |
| `uploadAvatar()` | userId, imageFile | อัปโหลดรูป |
| `changePassword()` | userId, currentPwd, newPwd | เปลี่ยนรหัสผ่าน |
| `saveTestResult()` | userId, scores, level | บันทึกผล PHQ-9 |
| `getTestResults()` | userId | ดึงประวัติทดสอบ |
| `saveBrainwaveData()` | userId, alpha, beta, theta, delta, gamma | บันทึก EEG |
| `getBrainwaveData()` | userId | ดึงข้อมูลคลื่นสมอง |
| `sendChatMessage()` | userId, message, isBot | บันทึกแชท |
| `getChatHistory()` | userId | ดึงประวัติแชท |
| `sendChatGPTMessage()` | userId, message, history | ส่งถาม AI + RAG |
| `getSchedules()` | userId | ดึงกำหนดการ |
| `addSchedule()` | userId, title, time, desc | เพิ่มกำหนดการ |
| `deleteSchedule()` | scheduleId, userId | ลบกำหนดการ |
| `getSettings()` | userId | ดึงการตั้งค่า |
| `updateSettings()` | userId, fields... | อัปเดตตั้งค่า |
| `deleteAccount()` | userId | ลบบัญชี (CASCADE) |

### ภาคผนวก ค — Supabase Migrations

| ไฟล์ | คำอธิบาย |
|------|---------|
| `001_initial_schema.sql` | สร้าง 7 ตาราง + RLS + Triggers |
| `002_rag_schema.sql` | pgvector + knowledge_base + functions + 13 entries |
| `003_emergency_knowledge.sql` | เพิ่มเบอร์ฉุกเฉิน (1323, สมาริตันส์, 1669) |
| `004_update_samaritans_phone.sql` | อัปเดตเบอร์สมาริตันส์ |
| `005_voice_emergency_schema.sql` | Schema สำหรับระบบเสียงฉุกเฉิน |
| `006_class_diagram_update.sql` | ปรับโครงสร้างตาม class diagram |
| `007_enable_realtime.sql` | เปิด Supabase Realtime |
| `008_avatar_storage.sql` | สร้าง Storage bucket สำหรับรูปโปรไฟล์ |

### ภาคผนวก ง — คู่มือการใช้งาน

ดูไฟล์: `USER_GUIDE.md`

### ภาคผนวก จ — Source Code

ดูได้ที่ GitHub Repository: `[ใส่ลิงก์ GitHub]`

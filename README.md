# 🧠 SmartBrain Care

> **แอปพลิเคชัน Flutter สำหรับดูแลสุขภาพจิตและติดตามคลื่นสมอง (EEG) ด้วยอุปกรณ์ Muse S/Muse 2**  
> **พร้อมระบบ AI Chatbot (ChatGPT + RAG) และเกมฝึกสมอง**

[![Flutter](https://img.shields.io/badge/Flutter-3.10.4-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?logo=supabase)](https://supabase.com)
[![OpenAI](https://img.shields.io/badge/OpenAI-GPT--4o-412991?logo=openai)](https://openai.com)
[![Version](https://img.shields.io/badge/Version-v1.0.0-brightgreen)](https://github.com)

---

## 📌 ภาพรวมโปรเจกต์

**SmartBrain Care** เป็นแอปพลิเคชัน Cross-Platform ที่พัฒนาด้วย Flutter ออกแบบมาเพื่อช่วยติดตามและดูแลสุขภาพจิตผ่านการวัดคลื่นสมอง (EEG) ด้วยอุปกรณ์ Muse S/Muse 2 โดยมี AI Chatbot ที่ใช้ ChatGPT ร่วมกับ RAG (Retrieval-Augmented Generation) ในการให้คำแนะนำเกี่ยวกับสุขภาพจิตและคลื่นสมองอย่างแม่นยำ

### ✨ จุดเด่นของแอป
- 🧠 **วัดคลื่นสมองแบบ Real-time** ผ่าน Bluetooth กับอุปกรณ์ Muse S/Muse 2
- 🤖 **AI Chatbot อัจฉริยะ** ใช้ ChatGPT + RAG ให้คำแนะนำเฉพาะบุคคล
- 🔊 **Voice Interaction** รองรับ Text-to-Speech และ Speech-to-Text
- 📊 **Data Visualization** กราฟแสดงข้อมูลคลื่นสมองแบบ Interactive
- 🎮 **Brain Training Games** เกมฝึกสมอง 5 แบบ
- 📝 **แบบทดสอบความเครียด** ประเมินระดับสุขภาพจิต
- 🆘 **ระบบฉุกเฉิน** ข้อมูลผู้ติดต่อฉุกเฉินและสายด่วนสุขภาพจิต

---

## 🛠️ Tech Stack

| Category | Technology | Version |
|----------|------------|---------|
| **Frontend** | Flutter (Dart) | ^3.10.4 |
| **Backend/Database** | Supabase (PostgreSQL + pgvector) | Latest |
| **AI Chatbot** | OpenAI ChatGPT | gpt-4o |
| **AI Enhancement** | RAG (Retrieval-Augmented Generation) | Custom |
| **EEG Device** | Muse S / Muse 2 | Bluetooth BLE |
| **State Management** | Provider | ^6.1.2 |
| **Charts** | fl_chart | ^0.70.2 |
| **Text-to-Speech** | flutter_tts | ^4.2.0 |
| **Speech-to-Text** | speech_to_text | ^7.0.0 |
| **Bluetooth** | flutter_blue_plus | ^1.34.5 |
| **HTTP Client** | http | ^1.2.2 |
| **Typography** | Google Fonts (Prompt) | ^6.2.1 |

---

## 📁 โครงสร้างโปรเจกต์ (Folder Structure)

```
brain_wave_flutter/
├── lib/
│   ├── main.dart                          # 🚀 Entry point + Supabase init
│   ├── models/                            # 📋 Data Models (17 files)
│   │   ├── user.dart                      #   - User model
│   │   ├── brain_data.dart                #   - Brainwave data model
│   │   ├── chat_message.dart              #   - Chat message model
│   │   ├── conversation.dart              #   - Conversation model
│   │   ├── eeg_device.dart                #   - EEG device model
│   │   ├── eeg_raw_data.dart              #   - EEG raw data model
│   │   ├── eeg_session.dart               #   - EEG session model
│   │   ├── elderly_profile.dart           #   - Elderly profile model
│   │   ├── emotion_log.dart               #   - Emotion log model
│   │   ├── medical_knowledge.dart         #   - Medical knowledge model
│   │   ├── schedule.dart                  #   - Schedule model
│   │   ├── stress_test_result.dart        #   - Stress test result model
│   │   ├── user_settings.dart             #   - User settings model
│   │   ├── voice_metadata.dart            #   - Voice metadata model
│   │   ├── activity_log.dart              #   - Activity log model
│   │   ├── retrieval_log.dart             #   - RAG retrieval log model
│   │   └── models.dart                    #   - Export barrel file
│   ├── providers/
│   │   └── brain_provider.dart            # 🔄 State management (Provider)
│   ├── screens/
│   │   ├── main_navigation.dart           # 🧭 Bottom navigation bar
│   │   ├── auth/                          # 🔐 Authentication screens
│   │   │   ├── welcome_screen.dart        #   - Welcome/landing page
│   │   │   ├── login_screen.dart          #   - Login form
│   │   │   └── register_screen.dart       #   - Registration form
│   │   └── dashboard/                     # 📱 Main app screens (17 files)
│   │       ├── home_screen.dart           #   - Home: EEG monitoring
│   │       ├── chart_screen.dart          #   - Brainwave chart
│   │       ├── history_screen.dart        #   - History records
│   │       ├── test_screen.dart           #   - Stress test
│   │       ├── recommendation_screen.dart #   - AI Chatbot
│   │       ├── profile_screen.dart        #   - User profile
│   │       ├── edit_profile_screen.dart   #   - Edit profile
│   │       ├── settings_screen.dart       #   - App settings
│   │       ├── change_password_screen.dart#   - Change password
│   │       ├── notification_settings_screen.dart # - Notification settings
│   │       ├── activities_dashboard_screen.dart   # - Activities hub
│   │       ├── mini_games_screen.dart     #   - Brain games list
│   │       ├── memory_game_screen.dart    #   - Memory card game
│   │       ├── number_puzzle_screen.dart  #   - Number puzzle game
│   │       ├── reaction_game_screen.dart  #   - Reaction speed game
│   │       ├── color_sequence_screen.dart #   - Color sequence game
│   │       └── checkers_game_screen.dart  #   - Checkers board game
│   ├── services/                          # ⚙️ Business logic (8 files)
│   │   ├── supabase_service.dart          #   - Supabase CRUD (45+ methods)
│   │   ├── muse_service.dart              #   - Muse EEG Bluetooth
│   │   ├── chatgpt_service.dart           #   - ChatGPT API integration
│   │   ├── rag_service.dart               #   - RAG pipeline
│   │   ├── tts_service.dart               #   - Text-to-Speech
│   │   ├── stt_service.dart               #   - Speech-to-Text
│   │   ├── api_service.dart               #   - HTTP API helper
│   │   └── fft_calculator.dart            #   - FFT math computation
│   └── theme/
│       └── app_theme.dart                 # 🎨 App theme & colors
├── supabase/
│   └── migrations/                        # 🗄️ Database migrations (7 files)
│       ├── 001_initial_schema.sql         #   - Core tables
│       ├── 002_rag_schema.sql             #   - RAG + pgvector
│       ├── 003_emergency_knowledge.sql    #   - Emergency data
│       ├── 004_update_samaritans_phone.sql#   - Phone update
│       ├── 005_voice_emergency_schema.sql #   - Voice & emergency schema
│       ├── 006_class_diagram_update.sql   #   - Class diagram update
│       └── 007_enable_realtime.sql        #   - Realtime subscription
├── assets/images/                         # 🖼️ App images & icons
├── pubspec.yaml                           # 📦 Dependencies
├── README.md                              # 📖 Project overview (this file)
├── PROJECT_SUMMARY.md                     # 📋 Detailed project summary
├── RAG_GUIDE.md                           # 🤖 RAG system guide
├── SUPABASE_GUIDE.md                      # 🗄️ Supabase setup guide
├── USER_GUIDE.md                          # 📘 User manual
├── API_DOCUMENTATION.md                   # 📡 API & Data model docs
├── SCRUM_REPORT.md                        # 📊 Scrum/Sprint report
└── DESIGN_DOCUMENT.md                     # 🎨 System design document
```

---

## 🚀 การติดตั้งและรัน (Installation)

### Prerequisites

| Tool | Version | Required |
|------|---------|----------|
| Flutter SDK | ^3.10.4 | ✅ |
| Dart SDK | ^3.10 | ✅ (มากับ Flutter) |
| Supabase Account | - | ✅ |
| OpenAI API Key | - | ✅ (สำหรับ AI Chatbot) |
| Muse S / Muse 2 | - | ⚡ Optional (มี Simulation mode) |
| Android Studio / Xcode | Latest | ✅ |

### ขั้นตอนการติดตั้ง

#### 1. Clone โปรเจกต์
```bash
git clone <repository-url>
cd brain_wave_flutter
```

#### 2. ติดตั้ง Dependencies
```bash
flutter pub get
```

#### 3. ตั้งค่า Supabase
1. สร้างโปรเจกต์ที่ [supabase.com](https://supabase.com)
2. ไปที่ **SQL Editor** → รัน migration files ตามลำดับ:
   - `supabase/migrations/001_initial_schema.sql`
   - `supabase/migrations/002_rag_schema.sql`
   - `supabase/migrations/003_emergency_knowledge.sql`
   - `supabase/migrations/004_update_samaritans_phone.sql`
   - `supabase/migrations/005_voice_emergency_schema.sql`
   - `supabase/migrations/006_class_diagram_update.sql`
   - `supabase/migrations/007_enable_realtime.sql`
3. ใส่ **Supabase URL** และ **Anon Key** ในไฟล์ `lib/services/supabase_service.dart`

#### 4. ตั้งค่า OpenAI API Key
ใส่ API Key ในไฟล์:
- `lib/services/chatgpt_service.dart`
- `lib/services/rag_service.dart`

#### 5. รันแอป
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# macOS
flutter run -d macos

# Web
flutter run -d chrome
```

---

## 📊 สรุปฟีเจอร์ทั้งหมด

| # | Feature | Description | Status |
|---|---------|-------------|--------|
| 1 | 🧠 **Brainwave Monitoring** | วัดคลื่นสมอง Alpha, Beta, Theta, Delta, Gamma แบบ Real-time | ✅ |
| 2 | 📊 **Data Visualization** | กราฟแสดงข้อมูลคลื่นสมอง (fl_chart) | ✅ |
| 3 | 🤖 **AI Chatbot (RAG)** | ChatGPT + RAG ให้คำแนะนำเฉพาะบุคคล | ✅ |
| 4 | 🔊 **Text-to-Speech** | อ่านคำตอบ AI เป็นเสียงภาษาไทย | ✅ |
| 5 | 🎤 **Speech-to-Text** | รับคำสั่งเสียงจากผู้ใช้ | ✅ |
| 6 | 📝 **Stress Test** | แบบทดสอบความเครียด + ประเมินผล | ✅ |
| 7 | 🎮 **Memory Game** | เกมจำตำแหน่ง ฝึกความจำ | ✅ |
| 8 | 🔢 **Number Puzzle** | เกมตัวเลข ฝึกตรรกะ | ✅ |
| 9 | ⚡ **Reaction Game** | เกมทดสอบความเร็วปฏิกิริยา | ✅ |
| 10 | 🎨 **Color Sequence** | เกมลำดับสี ฝึกความจำระยะสั้น | ✅ |
| 11 | ♟️ **Checkers Game** | เกมหมากฮอส ฝึกกลยุทธ์ | ✅ |
| 12 | 📅 **Daily Schedule** | ตารางกิจกรรมประจำวัน | ✅ |
| 13 | 👤 **User Profile** | จัดการโปรไฟล์ + แก้ไขข้อมูล | ✅ |
| 14 | 🔐 **Authentication** | Login / Register + เปลี่ยนรหัสผ่าน | ✅ |
| 15 | ⚙️ **Settings** | ตั้งค่าแอป (แจ้งเตือน, ธีม, ภาษา) | ✅ |
| 16 | 🆘 **Emergency Contacts** | ผู้ติดต่อฉุกเฉิน + สายด่วนสุขภาพจิต | ✅ |
| 17 | 📈 **History & Analytics** | ประวัติการวัด + ผลทดสอบ | ✅ |
| 18 | 😊 **Emotion Logging** | บันทึกและติดตามอารมณ์ | ✅ |
| 19 | 🗑️ **Account Deletion** | ลบบัญชีผู้ใช้ | ✅ |

---

## 🗄️ โครงสร้างฐานข้อมูล (Database Schema)

ดูรายละเอียดเพิ่มเติมที่ [`API_DOCUMENTATION.md`](API_DOCUMENTATION.md)

### ตารางหลัก (Core Tables)
| Table | Description | Fields |
|-------|-------------|--------|
| `users` | ข้อมูลผู้ใช้ | username, password, full_name, email, phone, avatar_url |
| `user_settings` | การตั้งค่า | daily_reminder, weekly_report, dark_mode, language |
| `brainwave_data` | คลื่นสมอง | alpha, beta, theta, delta, gamma, attention, meditation |
| `test_results` | ผลทดสอบ | stress_score, depression_score, stress_level |
| `activities` | กิจกรรม | activity_type, activity_name, score, duration |
| `schedules` | ตารางเวลา | title, description, time, icon, color, is_completed |
| `chat_messages` | ข้อความแชท | message, is_bot, sent_at |

### ตาราง RAG
| Table | Description |
|-------|-------------|
| `knowledge_base` | ฐานความรู้ + embeddings (pgvector) |
| `chat_context` | บริบทการสนทนา |
| `user_knowledge` | ข้อมูลเฉพาะผู้ใช้ |

### ตารางเพิ่มเติม (Extended)
| Table | Description |
|-------|-------------|
| `elderly_profiles` | โปรไฟล์ผู้สูงอายุ |
| `emergency_contacts` | ผู้ติดต่อฉุกเฉิน |
| `emotion_logs` | บันทึกอารมณ์ |
| `eeg_devices` | อุปกรณ์ EEG |
| `eeg_sessions` | เซสชันการวัด |
| `voice_metadata` | ข้อมูลเสียง |

---

## 📚 เอกสารประกอบ (Documentation)

| Document | Description |
|----------|-------------|
| 📖 [`README.md`](README.md) | ภาพรวมโปรเจกต์ (ไฟล์นี้) |
| 📋 [`PROJECT_SUMMARY.md`](PROJECT_SUMMARY.md) | สรุปโปรเจกต์อย่างละเอียด |
| 📘 [`USER_GUIDE.md`](USER_GUIDE.md) | คู่มือการใช้งานสำหรับผู้ใช้ |
| 📡 [`API_DOCUMENTATION.md`](API_DOCUMENTATION.md) | เอกสาร API และ Data Model |
| 📊 [`SCRUM_REPORT.md`](SCRUM_REPORT.md) | Scrum Report + Sprint Timeline |
| 🎨 [`DESIGN_DOCUMENT.md`](DESIGN_DOCUMENT.md) | เอกสารออกแบบระบบ |
| 🤖 [`RAG_GUIDE.md`](RAG_GUIDE.md) | คู่มือระบบ RAG |
| 🗄️ [`SUPABASE_GUIDE.md`](SUPABASE_GUIDE.md) | คู่มือตั้งค่า Supabase |

---

## 🔐 ความปลอดภัย (Security)

- **Row Level Security (RLS)** - ป้องกันการเข้าถึงข้อมูลข้ามผู้ใช้
- **Password Hashing** - เข้ารหัสรหัสผ่านก่อนจัดเก็บ
- **API Key Management** - แยกเก็บ API Keys ไม่ hardcode
- **Input Validation** - ตรวจสอบข้อมูลก่อน submit ทุก form

---

## 👥 ทีมพัฒนา

| Role | Name |
|------|------|
| **Front end** | Peeniti,Pisit |
| **Back end** | Thakchinan,Kittisak |

---

## 📄 License

This project is for educational purposes.

---

> **📝 หมายเหตุ**: โปรเจกต์นี้เป็นแอปพลิเคชันด้านสุขภาพจิต ที่รวมเทคโนโลยี IoT(Muse EEG) AI(ChatGPT+RAG) และ Mobile Development(Flutter) เข้าด้วยกันอย่างครบถ้วน.

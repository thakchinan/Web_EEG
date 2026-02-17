# 📊 Scrum Report - SmartBrain Care

> **โปรเจกต์**: SmartBrain Care - แอปดูแลสุขภาพจิตและติดตามคลื่นสมอง  
> **ระยะเวลาพัฒนา**: 4 สัปดาห์ (4 Sprints)  
> **วันเริ่มต้น**: 20 มกราคม 2026  
> **วันส่งมอบ**: 15 กุมภาพันธ์ 2026  
> **Version**: v1.0.0

---

## 📅 Sprint Timeline Overview

```
Sprint 1 (Week 1)          Sprint 2 (Week 2)          Sprint 3 (Week 3)          Sprint 4 (Week 4)
20-26 ม.ค.                 27 ม.ค. - 2 ก.พ.           3-9 ก.พ.                  10-15 ก.พ.
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│ 🏗️ Foundation    │       │ 🧠 Core Features │       │ 🤖 AI & Games   │       │ 🔧 Polish &     │
│                 │       │                 │       │                 │       │    Release      │
│ • Project Setup │       │ • EEG Bluetooth │       │ • ChatGPT + RAG │       │ • Bug Fixes     │
│ • Auth System   │       │ • Brainwave UI  │       │ • Brain Games   │       │ • Profile UX    │
│ • Supabase DB   │       │ • Charts        │       │ • TTS/STT       │       │ • Documentation │
│ • UI Foundation │       │ • Test Screen   │       │ • Emergency     │       │ • Testing       │
│ • Navigation    │       │ • History       │       │ • Emotion Log   │       │ • Deployment    │
└─────────────────┘       └─────────────────┘       └─────────────────┘       └─────────────────┘
     28 Story Points            35 Story Points            32 Story Points            25 Story Points
```

---

## 🏃 Sprint 1: Foundation & Authentication (20-26 ม.ค. 2026)

### 📋 Sprint Goal
สร้างโครงสร้างพื้นฐานของแอป รวมถึงระบบ Authentication, Supabase Database, และ UI Foundation

### 📌 Sprint Backlog - Task Breakdown

| Task ID | Task (ฟังก์ชัน) | Module | Status | Story Points |
|---------|-----------------|--------|--------|:------------:|
| **T1.1** | `createProjectStructure()` - สร้างโครงสร้าง Flutter project | Setup | ✅ Done | 2 |
| **T1.2** | `setupSupabase()` - ตั้งค่า Supabase project + API Keys | Setup | ✅ Done | 2 |
| **T1.3** | `runMigration_001()` - สร้างตาราง users, brainwave_data, schedules, activities, test_results, chat_messages, user_settings | Database | ✅ Done | 3 |
| **T1.4** | `setupRLS()` - ตั้งค่า Row Level Security Policies | Database | ✅ Done | 2 |
| **T1.5** | `createSupabaseService.initialize()` - เชื่อมต่อ Supabase client | Service | ✅ Done | 1 |
| **T1.6** | `createSupabaseService.login()` - ระบบ Login (username/password) | Auth | ✅ Done | 3 |
| **T1.7** | `createSupabaseService.register()` - ระบบ Register (username, password, fullName, phone, birthDate) | Auth | ✅ Done | 3 |
| **T1.8** | `designWelcomeScreen()` - หน้าต้อนรับ + animation | UI | ✅ Done | 2 |
| **T1.9** | `designLoginScreen()` - หน้า Login + form validation | UI | ✅ Done | 2 |
| **T1.10** | `designRegisterScreen()` - หน้า Register + form validation | UI | ✅ Done | 3 |
| **T1.11** | `createMainNavigation()` - Bottom navigation bar (Home, Chart, Test, Chat, Profile) | Navigation | ✅ Done | 2 |
| **T1.12** | `createAppTheme()` - ธีมแอป (สี, ฟอนต์ Prompt, Dark mode) | Theme | ✅ Done | 1 |
| **T1.13** | `createBrainProvider()` - State management | Provider | ✅ Done | 2 |

**Total Story Points: 28** | **Completed: 28** | **Velocity: 28**

### 📝 Sprint 1 - รายละเอียดฟังก์ชัน

#### SupabaseService - Authentication Functions

```
┌──────────────────────────────────────────────────────────────────┐
│ SupabaseService                                                   │
├──────────────────────────────────────────────────────────────────┤
│ + initialize()                                                    │
│   ├── Input: supabaseUrl, supabaseAnonKey                        │
│   ├── Process: Supabase.initialize(url, anonKey)                 │
│   └── Output: Supabase client ready                              │
│                                                                   │
│ + login(username, password)                                       │
│   ├── Input: String username, String password                    │
│   ├── Process: SELECT * FROM users WHERE username=? AND pass=?   │
│   ├── Validation: Check empty fields, user exists                │
│   └── Output: Map {success, user_id, message}                   │
│                                                                   │
│ + register({username, password, fullName, phone, birthDate})      │
│   ├── Input: Required username/password, Optional profile data   │
│   ├── Process: INSERT INTO users + INSERT INTO user_settings     │
│   ├── Validation: Check duplicate username, password length      │
│   └── Output: Map {success, user_id, message}                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🏃 Sprint 2: Core Features & EEG Integration (27 ม.ค. - 2 ก.พ. 2026)

### 📋 Sprint Goal
พัฒนาฟีเจอร์หลักของแอป: การเชื่อมต่อ Muse EEG, แสดงคลื่นสมอง, กราฟ, แบบทดสอบความเครียด, และประวัติ

### 📌 Sprint Backlog - Task Breakdown

| Task ID | Task (ฟังก์ชัน) | Module | Status | Story Points |
|---------|-----------------|--------|--------|:------------:|
| **T2.1** | `createMuseService()` - สร้าง Bluetooth service ทั้งหมด | EEG | ✅ Done | 5 |
| **T2.2** | `MuseService.startScan()` - สแกนอุปกรณ์ Bluetooth BLE | EEG | ✅ Done | 3 |
| **T2.3** | `MuseService.connectToDevice()` - เชื่อมต่อ Muse S/Muse 2 | EEG | ✅ Done | 3 |
| **T2.4** | `MuseService._processEEGData()` - ประมวลผลข้อมูล EEG จาก Muse | EEG | ✅ Done | 3 |
| **T2.5** | `MuseService._parseMuseEEGPacket()` - Parse EEG packet data | EEG | ✅ Done | 2 |
| **T2.6** | `FFTCalculator._calculateFFT()` - คำนวณ FFT แยกคลื่น Alpha/Beta/Theta/Delta/Gamma | Algorithm | ✅ Done | 3 |
| **T2.7** | `MuseService.startSimulation()` - Simulation mode สำหรับทดสอบ | EEG | ✅ Done | 2 |
| **T2.8** | `designHomeScreen()` - หน้าหลัก แสดงคลื่นสมอง Real-time | UI | ✅ Done | 3 |
| **T2.9** | `SupabaseService.saveBrainwaveData()` - บันทึกข้อมูลคลื่นสมอง | Database | ✅ Done | 2 |
| **T2.10** | `SupabaseService.getBrainwaveData()` - ดึงข้อมูลคลื่นสมอง | Database | ✅ Done | 1 |
| **T2.11** | `designChartScreen()` - กราฟ fl_chart แสดงข้อมูล | UI | ✅ Done | 3 |
| **T2.12** | `designTestScreen()` - แบบทดสอบความเครียด (PHQ-9, GAD-7) | UI | ✅ Done | 3 |
| **T2.13** | `SupabaseService.saveTestResult()` - บันทึกผลทดสอบ | Database | ✅ Done | 1 |
| **T2.14** | `designHistoryScreen()` - ประวัติการวัด + ผลทดสอบ | UI | ✅ Done | 2 |
| **T2.15** | `SupabaseService.getSchedules()` + `addSchedule()` + `deleteSchedule()` - จัดการตารางกิจกรรม | Database | ✅ Done | 2 |
| **T2.16** | `SupabaseService.saveActivity()` + `getActivities()` - จัดการกิจกรรม | Database | ✅ Done | 1 |

**Total Story Points: 35** | **Completed: 35** | **Velocity: 35**

### 📝 Sprint 2 - รายละเอียดฟังก์ชัน

#### MuseService - EEG Functions

```
┌──────────────────────────────────────────────────────────────────┐
│ MuseService (ChangeNotifier)                                      │
├──────────────────────────────────────────────────────────────────┤
│ Properties:                                                       │
│   alphaWave, betaWave, thetaWave, deltaWave, gammaWave           │
│   attention (0-100), meditation (0-100)                           │
│   isConnected, isScanning, connectedDevice                       │
│   discoveredDevices: List<BluetoothDevice>                       │
│                                                                   │
│ + isBluetoothAvailable() → Future<bool>                          │
│ + startScan() → Future<void>                                     │
│   ├── Check Bluetooth permission                                 │
│   ├── FlutterBluePlus.startScan(timeout: 10s)                   │
│   └── Filter: name contains "Muse"                              │
│                                                                   │
│ + connectToDevice(BluetoothDevice) → Future<void>                │
│   ├── device.connect(timeout: 15s)                               │
│   ├── discoverServices()                                         │
│   └── _setupMuseConnection()                                     │
│                                                                   │
│ - _processEEGData(uuid, rawData) → void                         │
│   ├── _parseMuseEEGPacket(rawData)                               │
│   ├── _addToWindow(ch1-ch4)                                      │
│   └── _calculateFFT()                                            │
│                                                                   │
│ - _calculateFFT() → void                                         │
│   ├── FFTCalculator.compute(window, sampleRate: 256)             │
│   ├── Extract: alpha(8-13Hz), beta(13-30Hz), theta(4-8Hz)       │
│   ├── Extract: delta(0.5-4Hz), gamma(30-100Hz)                  │
│   ├── Calculate: attention, meditation scores                     │
│   └── notifyListeners()                                          │
│                                                                   │
│ + startSimulation() → void                                       │
│   └── Timer.periodic(500ms) → generate random brainwave data    │
│                                                                   │
│ + disconnect() → Future<void>                                    │
│ + dispose() → void                                               │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🏃 Sprint 3: AI Chatbot, Games & Advanced Features (3-9 ก.พ. 2026)

### 📋 Sprint Goal
พัฒนา AI Chatbot ด้วย ChatGPT + RAG, เกมฝึกสมอง 5 เกม, ระบบ TTS/STT, และระบบฉุกเฉิน

### 📌 Sprint Backlog - Task Breakdown

| Task ID | Task (ฟังก์ชัน) | Module | Status | Story Points |
|---------|-----------------|--------|--------|:------------:|
| **T3.1** | `runMigration_002()` - สร้างตาราง knowledge_base + pgvector | Database | ✅ Done | 2 |
| **T3.2** | `createRAGService.createEmbedding()` - สร้าง embedding ด้วย OpenAI | RAG | ✅ Done | 3 |
| **T3.3** | `createRAGService.searchKnowledge()` - Vector search + keyword fallback | RAG | ✅ Done | 3 |
| **T3.4** | `createRAGService._vectorSearch()` - Vector similarity search (pgvector) | RAG | ✅ Done | 2 |
| **T3.5** | `createRAGService._keywordSearch()` - Keyword-based fallback search | RAG | ✅ Done | 2 |
| **T3.6** | `createRAGService.buildContext()` - สร้าง context จาก search results | RAG | ✅ Done | 1 |
| **T3.7** | `createRAGService.buildUserContext()` - สร้าง personalized context | RAG | ✅ Done | 2 |
| **T3.8** | `createChatGPTService.sendMessage()` - ส่งข้อความไป ChatGPT | AI | ✅ Done | 2 |
| **T3.9** | `createChatGPTService.sendMessageWithRAG()` - ส่งข้อความ + RAG context | AI | ✅ Done | 3 |
| **T3.10** | `createChatGPTService.sendMessageWithBrainwaveContext()` - ส่ง + brainwave data | AI | ✅ Done | 2 |
| **T3.11** | `designRecommendationScreen()` - หน้า AI Chatbot + voice I/O | UI | ✅ Done | 3 |
| **T3.12** | `createTTSService()` - Text-to-Speech ภาษาไทย | Voice | ✅ Done | 1 |
| **T3.13** | `createSTTService()` - Speech-to-Text | Voice | ✅ Done | 2 |
| **T3.14** | `designMemoryGameScreen()` - เกมจำตำแหน่ง | Game | ✅ Done | 2 |
| **T3.15** | `designNumberPuzzleScreen()` - เกมตัวเลข | Game | ✅ Done | 2 |
| **T3.16** | `designReactionGameScreen()` - เกม Reaction | Game | ✅ Done | 1 |
| **T3.17** | `designColorSequenceScreen()` - เกมลำดับสี | Game | ✅ Done | 1 |
| **T3.18** | `designCheckersGameScreen()` - เกมหมากฮอส | Game | ✅ Done | 2 |
| **T3.19** | `runMigration_003()` - เพิ่มข้อมูลฉุกเฉิน (สายด่วนสุขภาพจิต) | Database | ✅ Done | 1 |
| **T3.20** | `SupabaseService.getEmergencyContacts()` + `addEmergencyContact()` | Emergency | ✅ Done | 2 |

**Total Story Points: 32** (ลดลงจาก Sprint 2 เนื่องจากมี learning curve กับ RAG)

### 📝 Sprint 3 - รายละเอียดฟังก์ชัน

#### RAGService - AI Enhancement Functions

```
┌──────────────────────────────────────────────────────────────────┐
│ RAGService                                                        │
├──────────────────────────────────────────────────────────────────┤
│ + createEmbedding(text) → Future<List<double>>                   │
│   ├── POST https://api.openai.com/v1/embeddings                 │
│   ├── model: "text-embedding-ada-002"                            │
│   └── Output: 1536-dimensional vector                            │
│                                                                   │
│ + searchKnowledge(query, {maxResults, threshold, category})      │
│   ├── Step 1: createEmbedding(query)                             │
│   ├── Step 2: _vectorSearch(embedding) → semantic results        │
│   ├── Step 3: _keywordSearch(query) → keyword results            │
│   ├── Step 4: _broadSearch(query) → broad results                │
│   ├── Merge & Deduplicate results                                │
│   └── Output: List<Map> sorted by similarity                     │
│                                                                   │
│ + buildContext(results) → String                                  │
│   └── Format: [แหล่งข้อมูล 1: title]\ncontent\n---              │
│                                                                   │
│ + buildUserContext(userId) → Future<String>                      │
│   ├── Get latest brainwave data                                  │
│   ├── Get recent test results                                    │
│   ├── Get recent activities                                      │
│   └── Combine into personalized context                          │
│                                                                   │
│ + addKnowledge({title, content, category, tags})                 │
│   ├── Create embedding for content                               │
│   ├── INSERT INTO knowledge_base                                 │
│   └── Output: Map {success, id}                                  │
│                                                                   │
│ + updateEmbeddings() → Future<Map>                               │
│   ├── SELECT WHERE embedding IS NULL                             │
│   ├── For each: createEmbedding(title + content)                 │
│   ├── UPDATE knowledge_base SET embedding = ?                    │
│   └── Output: Map {success, updated_count}                       │
└──────────────────────────────────────────────────────────────────┘
```

#### ChatGPTService - AI Chat Functions

```
┌──────────────────────────────────────────────────────────────────┐
│ ChatGPTService                                                    │
├──────────────────────────────────────────────────────────────────┤
│ + sendMessage({message, chatHistory}) → Future<Map>              │
│   ├── Build system prompt (Thai mental health expert)            │
│   ├── POST https://api.openai.com/v1/chat/completions           │
│   ├── Model: gpt-4o                                              │
│   └── Output: Map {success, bot_response}                        │
│                                                                   │
│ + sendMessageWithRAG({message, chatHistory, userId})             │
│   ├── RAGService.searchKnowledge(message)                        │
│   ├── RAGService.buildContext(results)                           │
│   ├── RAGService.buildUserContext(userId)                        │
│   ├── Enhance system prompt with RAG context                    │
│   ├── POST to ChatGPT with enhanced prompt                      │
│   └── Output: Map {success, bot_response, rag_used, ids}        │
│                                                                   │
│ + sendMessageWithBrainwaveContext({message, brainwaveData})      │
│   ├── Add brainwave data to system prompt                        │
│   ├── POST to ChatGPT                                            │
│   └── Output: Map {success, bot_response}                        │
│                                                                   │
│ + setUserId(userId) → void                                       │
│ + toggleRAG(enabled) → void                                      │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🏃 Sprint 4: Polish, Testing & Release (10-15 ก.พ. 2026)

### 📋 Sprint Goal
แก้ Bug, ปรับปรุง UX, เขียนเอกสาร, ทดสอบ, และเตรียม Release

### 📌 Sprint Backlog - Task Breakdown

| Task ID | Task (ฟังก์ชัน) | Module | Status | Story Points |
|---------|-----------------|--------|--------|:------------:|
| **T4.1** | `fixAccountDeletion()` - แก้ปัญหาลบบัญชี + cascade delete | Bug Fix | ✅ Done | 2 |
| **T4.2** | `refineProfileScreen()` - ปรับ UI/UX โปรไฟล์ | UI | ✅ Done | 2 |
| **T4.3** | `addBackButtons()` - เพิ่มปุ่มกลับทุกหน้า | UX | ✅ Done | 2 |
| **T4.4** | `fixMacOSSpeechRecognition()` - แก้ crash บน macOS (TCC) | Bug Fix | ✅ Done | 3 |
| **T4.5** | `runMigration_005()` - Voice + Emergency schema update | Database | ✅ Done | 1 |
| **T4.6** | `runMigration_006()` - Class diagram + extended tables | Database | ✅ Done | 1 |
| **T4.7** | `runMigration_007()` - Enable Realtime subscriptions | Database | ✅ Done | 1 |
| **T4.8** | `SupabaseService.saveEmotionLog()` + `getEmotionLogs()` - บันทึกอารมณ์ | Feature | ✅ Done | 2 |
| **T4.9** | `SupabaseService.saveElderlyProfile()` - โปรไฟล์ผู้สูงอายุ | Feature | ✅ Done | 2 |
| **T4.10** | `SupabaseService.registerEEGDevice()` + `updateDeviceStatus()` - จัดการอุปกรณ์ | Feature | ✅ Done | 2 |
| **T4.11** | `SupabaseService.startEEGSession()` + `endEEGSession()` - จัดการ session | Feature | ✅ Done | 2 |
| **T4.12** | `SupabaseService.startConversation()` + `endConversation()` - จัดการ conversation | Feature | ✅ Done | 1 |
| **T4.13** | `writeDocumentation()` - เขียน README, User Guide, API Doc, Design Doc, Scrum Report | Docs | ✅ Done | 3 |
| **T4.14** | `testAllFeatures()` - ทดสอบฟีเจอร์ทั้งหมด | Testing | ✅ Done | 2 |

**Total Story Points: 25** | **Completed: 25** | **Velocity: 25**

---

## 📈 Burndown Chart

```
Story Points
   120 ─┐
        │ ★ Sprint Start: 120 total story points
   100 ─│──★
        │    ╲
    80 ─│     ╲  Sprint 1 (-28)
        │      ★──────
    60 ─│              ╲  Sprint 2 (-35)
        │               ★──────
    40 ─│                      ╲  Sprint 3 (-32)
        │                       ★──────
    20 ─│                              ╲  Sprint 4 (-25)
        │                               ★──────
     0 ─│                                      ★ Done!
        └────────────────────────────────────────────
        Week 1     Week 2     Week 3     Week 4
```

---

## 📊 Sprint Summary

| Sprint | Duration | Story Points | Velocity | Focus |
|--------|----------|:------------:|:--------:|-------|
| Sprint 1 | 20-26 ม.ค. | 28 | 28 | Foundation & Auth |
| Sprint 2 | 27 ม.ค.-2 ก.พ. | 35 | 35 | Core EEG & Features |
| Sprint 3 | 3-9 ก.พ. | 32 | 32 | AI & Games |
| Sprint 4 | 10-15 ก.พ. | 25 | 25 | Polish & Release |
| **Total** | **4 weeks** | **120** | **Avg: 30** | **All Complete** |

---

## 🏁 Product Backlog (Final)

### ✅ Completed Features (v1.0.0)

| Priority | User Story | Sprint |
|----------|------------|--------|
| 🔴 High | ผู้ใช้สามารถ Login/Register ได้ | Sprint 1 |
| 🔴 High | ผู้ใช้สามารถเชื่อมต่อ Muse EEG ผ่าน Bluetooth | Sprint 2 |
| 🔴 High | ผู้ใช้สามารถดูคลื่นสมอง Real-time | Sprint 2 |
| 🔴 High | ผู้ใช้สามารถทำแบบทดสอบความเครียดได้ | Sprint 2 |
| 🔴 High | ผู้ใช้สามารถแชทกับ AI Chatbot (RAG) ได้ | Sprint 3 |
| 🟡 Med | ผู้ใช้สามารถดูกราฟข้อมูลคลื่นสมองได้ | Sprint 2 |
| 🟡 Med | ผู้ใช้สามารถดูประวัติการวัดและผลทดสอบ | Sprint 2 |
| 🟡 Med | ผู้ใช้สามารถเล่นเกมฝึกสมอง 5 เกมได้ | Sprint 3 |
| 🟡 Med | ผู้ใช้สามารถฟัง AI ตอบเป็นเสียง (TTS) | Sprint 3 |
| 🟡 Med | ผู้ใช้สามารถพูดสั่งงาน AI (STT) | Sprint 3 |
| 🟡 Med | ผู้ใช้สามารถจัดการตารางกิจกรรมได้ | Sprint 2 |
| 🟢 Low | ผู้ใช้สามารถแก้ไขโปรไฟล์ได้ | Sprint 4 |
| 🟢 Low | ผู้ใช้สามารถตั้งค่าแอปได้ | Sprint 1 |
| 🟢 Low | ผู้ใช้สามารถบันทึกอารมณ์ได้ | Sprint 4 |
| 🟢 Low | ผู้ใช้สามารถเพิ่มผู้ติดต่อฉุกเฉินได้ | Sprint 3 |
| 🟢 Low | ผู้ใช้สามารถลบบัญชีได้ | Sprint 4 |

---

## 📊 Retrospective

### Sprint 1 Retrospective
| What went well | What to improve |
|----------------|-----------------|
| ✅ Supabase setup ง่ายกว่าคาด | ⚡ ควรวาง folder structure ดีกว่านี้ |
| ✅ Provider state management ใช้ง่าย | ⚡ Form validation ควรทำ reusable |

### Sprint 2 Retrospective
| What went well | What to improve |
|----------------|-----------------|
| ✅ Bluetooth connection ทำงานได้ดี | ⚡ FFT calculation ซับซ้อนกว่าคาด |
| ✅ Simulation mode ช่วยทดสอบได้ดี | ⚡ Chart performance ต้อง optimize |

### Sprint 3 Retrospective
| What went well | What to improve |
|----------------|-----------------|
| ✅ RAG เพิ่มความแม่นยำ AI มาก | ⚡ OpenAI API มี rate limit |
| ✅ เกมสนุก ใช้ง่าย | ⚡ TTS ภาษาไทยบางคำอ่านไม่ชัด |

### Sprint 4 Retrospective  
| What went well | What to improve |
|----------------|-----------------|
| ✅ Bug fix ทำได้เร็ว | ⚡ ควรเขียน Unit test เพิ่ม |
| ✅ Documentation ครบถ้วน | ⚡ การ deploy ควรทำ CI/CD |

---

## 🗂️ Definition of Done (DoD)

- [x] Code ทำงานได้ถูกต้อง ไม่มี crash
- [x] UI ตรงตาม design
- [x] เชื่อมต่อ Database ได้ + CRUD ทำงาน
- [x] Form validation ทุก form
- [x] Navigation ทำงานถูกต้อง (รวมปุ่มกลับ)
- [x] ทดสอบบน Simulator/Emulator
- [x] เอกสารครบถ้วน

---

> **📝 หมายเหตุ**: Scrum Report นี้สรุปการพัฒนาทั้งหมด 4 Sprints ครอบคลุม 120 Story Points พร้อม Task Breakdown ระดับฟังก์ชัน ที่สามารถ Trace กลับไปยัง code ได้ทุก Task

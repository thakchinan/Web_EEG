# 📡 API Documentation & Data Model - SmartBrain Care

> **เอกสาร API ระดับฟังก์ชัน + โครงสร้างฐานข้อมูลอย่างละเอียด**  
> **Version 1.0.0** | อัปเดตล่าสุด: 15 กุมภาพันธ์ 2026

---

## 📋 สารบัญ

1. [System Architecture](#-system-architecture)
2. [Data Model (Database Schema)](#-data-model-database-schema)
3. [SupabaseService API Reference](#-supabaseservice-api-reference)
4. [ChatGPTService API Reference](#-chatgptservice-api-reference)
5. [RAGService API Reference](#-ragservice-api-reference)
6. [MuseService API Reference](#-museservice-api-reference)
7. [TTSService API Reference](#-ttsservice-api-reference)
8. [STTService API Reference](#-sttservice-api-reference)

---

## 🏛️ System Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                            SmartBrain Care                                │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌───────────────────────────────────────────────────────────────────┐   │
│  │                        Flutter Application                        │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │   │
│  │  │  Screens  │  │  Models  │  │ Providers│  │     Theme        │  │   │
│  │  │ (21 files)│  │(17 files)│  │ (1 file) │  │   (1 file)       │  │   │
│  │  └─────┬─────┘  └────┬─────┘  └─────┬────┘  └────────────────┘  │   │
│  │        │              │              │                             │   │
│  │  ┌─────▼──────────────▼──────────────▼─────────────────────────┐  │   │
│  │  │                    Services Layer (8 files)                  │  │   │
│  │  │ ┌────────────────┐ ┌────────────────┐ ┌──────────────────┐  │  │   │
│  │  │ │SupabaseService │ │  MuseService   │ │ ChatGPTService   │  │  │   │
│  │  │ │  (45 methods)  │ │  (23 methods)  │ │  (7 methods)     │  │  │   │
│  │  │ └───────┬────────┘ └───────┬────────┘ └────────┬─────────┘  │  │   │
│  │  │ ┌───────┴────────┐ ┌──────┴─────────┐ ┌───────┴─────────┐  │  │   │
│  │  │ │  RAGService    │ │FFTCalculator   │ │  TTS/STT        │  │  │   │
│  │  │ │  (15 methods)  │ │  (2 methods)   │ │  Services       │  │  │   │
│  │  │ └───────┬────────┘ └────────────────┘ └─────────────────┘  │  │   │
│  │  └─────────┼────────────────────────────────────────────────────┘  │   │
│  └────────────┼──────────────────────────────────────────────────────┘   │
│               │                                                           │
│  ┌────────────▼──────────────────────────────────────────────────────┐   │
│  │                     External Services                              │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────────────────┐   │   │
│  │  │   Supabase   │  │  OpenAI API  │  │   Muse S / Muse 2     │   │   │
│  │  │ (PostgreSQL) │  │  (GPT-4o)    │  │   (Bluetooth BLE)     │   │   │
│  │  │ + pgvector   │  │  + Embedding │  │                        │   │   │
│  │  └──────────────┘  └──────────────┘  └────────────────────────┘   │   │
│  └───────────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 🗄️ Data Model (Database Schema)

### Entity Relationship Diagram

```
┌─────────────┐       ┌──────────────────┐       ┌──────────────────┐
│    users     │───1:1─│  user_settings   │       │  elderly_profiles│
│             │       │                  │       │                  │
│ • id (PK)   │──1:1──│ • id (PK)        │       │ • id (PK)        │
│ • username  │       │ • user_id (FK)   │       │ • user_id (FK)   │
│ • password  │       │ • daily_reminder │       │ • first_name     │
│ • full_name │       │ • weekly_report  │       │ • blood_type     │
│ • email     │       │ • stress_alert   │       │ • medical_conds  │
│ • phone     │       │ • dark_mode      │       │ • allergies      │
│ • birth_date│       │ • language       │       │ • mobility_status│
│ • avatar_url│       │ • brain_mode     │       └──────────────────┘
│ • role      │       └──────────────────┘
│ • created_at│
└──────┬──────┘
       │
       ├───1:N──┌──────────────────┐
       │        │  brainwave_data  │
       │        │ • id (PK)        │
       │        │ • user_id (FK)   │
       │        │ • alpha_wave     │
       │        │ • beta_wave      │
       │        │ • theta_wave     │
       │        │ • delta_wave     │
       │        │ • gamma_wave     │
       │        │ • attention_score│
       │        │ • meditation_score│
       │        │ • device_name    │
       │        │ • recorded_at    │
       │        └──────────────────┘
       │
       ├───1:N──┌──────────────────┐
       │        │  test_results    │
       │        │ • id (PK)        │
       │        │ • user_id (FK)   │
       │        │ • stress_score   │
       │        │ • depression_score│
       │        │ • stress_level   │
       │        │ • tested_at      │
       │        └──────────────────┘
       │
       ├───1:N──┌──────────────────┐
       │        │   activities     │
       │        │ • id (PK)        │
       │        │ • user_id (FK)   │
       │        │ • activity_type  │
       │        │ • activity_name  │
       │        │ • score          │
       │        │ • duration_mins  │
       │        │ • created_at     │
       │        └──────────────────┘
       │
       ├───1:N──┌──────────────────┐
       │        │   schedules      │
       │        │ • id (PK)        │
       │        │ • user_id (FK)   │
       │        │ • title          │
       │        │ • description    │
       │        │ • time           │
       │        │ • icon_name      │
       │        │ • color          │
       │        │ • is_completed   │
       │        └──────────────────┘
       │
       ├───1:N──┌──────────────────┐
       │        │  chat_messages   │
       │        │ • id (PK)        │
       │        │ • user_id (FK)   │
       │        │ • message        │
       │        │ • is_bot         │
       │        │ • sent_at        │
       │        └──────────────────┘
       │
       ├───1:N──┌──────────────────┐
       │        │ emergency_contacts│
       │        │ • id (PK)        │
       │        │ • user_id (FK)   │
       │        │ • contact_name   │
       │        │ • phone_number   │
       │        │ • relationship   │
       │        │ • is_primary     │
       │        └──────────────────┘
       │
       ├───1:N──┌──────────────────┐
       │        │  emotion_logs    │
       │        │ • id (PK)        │
       │        │ • user_id (FK)   │
       │        │ • emotion_type   │
       │        │ • trigger_event  │
       │        │ • intensity      │
       │        │ • logged_at      │
       │        └──────────────────┘
       │
       ├───1:N──┌──────────────────┐
       │        │   eeg_devices    │
       │        │ • id (PK)        │
       │        │ • user_id (FK)   │
       │        │ • device_name    │
       │        │ • model_name     │
       │        │ • serial_number  │
       │        │ • mac_address    │
       │        │ • battery_level  │
       │        │ • status         │
       │        └──────────────────┘
       │
       ├───1:N──┌──────────────────┐
       │        │  eeg_sessions    │
       │        │ • id (PK)        │
       │        │ • user_id (FK)   │
       │        │ • device_id (FK) │
       │        │ • session_type   │
       │        │ • started_at     │
       │        │ • ended_at       │
       │        │ • avg_attention  │
       │        │ • avg_relaxation │
       │        └──────────────────┘
       │
       └───1:N──┌──────────────────┐
                │  conversations   │
                │ • id (PK)        │
                │ • user_id (FK)   │
                │ • started_at     │
                │ • ended_at       │
                │ • topic_summary  │
                │ • sentiment_avg  │
                └──────────────────┘


┌──────────────────┐       ┌──────────────────┐
│  knowledge_base  │       │  voice_metadata  │
│ (RAG System)     │       │                  │
│ • id (PK)        │       │ • id (PK)        │
│ • title          │       │ • message_id(FK) │
│ • content        │       │ • language       │
│ • category       │       │ • duration_secs  │
│ • tags[]         │       │ • sentiment_score│
│ • embedding      │       │ • stress_index   │
│   (vector 1536)  │       │ • pitch_avg      │
│ • metadata       │       │ • volume_avg     │
│ • created_at     │       │ • speech_rate    │
└──────────────────┘       └──────────────────┘
```

---

## 📡 SupabaseService API Reference

> **ไฟล์**: `lib/services/supabase_service.dart`  
> **จำนวน Methods**: 45+  
> **ลักษณะ**: Static class, ทุก method เป็น static

### Authentication

#### `initialize()`
```dart
static Future<void> initialize()
```
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| - | - | - | ใช้ค่า supabaseUrl, supabaseAnonKey ที่กำหนดไว้ |

**Returns**: `void`  
**Error Handling**: Throws exception if failed

---

#### `login(username, password)`
```dart
static Future<Map<String, dynamic>> login(String username, String password)
```
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| username | String | ✅ | ชื่อผู้ใช้ |
| password | String | ✅ | รหัสผ่าน |

**Returns**: `Map<String, dynamic>`
```json
{
  "success": true,
  "user_id": 1,
  "message": "เข้าสู่ระบบสำเร็จ"
}
```

---

#### `register({...})`
```dart
static Future<Map<String, dynamic>> register({
  required String username,
  required String password,
  String? fullName,
  String? phone,
  String? birthDate,
})
```

**Returns**: `Map<String, dynamic>`
```json
{
  "success": true,
  "user_id": 2,
  "message": "สมัครสมาชิกสำเร็จ"
}
```

---

### Profile Management

#### `getProfile(userId)`
```dart
static Future<Map<String, dynamic>> getProfile(int userId)
```

**Returns**: `Map` with user profile data or error

---

#### `updateProfile({...})`
```dart
static Future<Map<String, dynamic>> updateProfile({
  required int userId,
  String? fullName,
  String? firstName,
  String? lastName,
  String? phone,
  String? email,
  String? birthDate,
  String? avatarUrl,
  String? role,
})
```

---

#### `changePassword({...})`
```dart
static Future<Map<String, dynamic>> changePassword({
  required int userId,
  String? currentPassword,
  required String newPassword,
})
```

---

### Brainwave Data

#### `saveBrainwaveData({...})`
```dart
static Future<Map<String, dynamic>> saveBrainwaveData({
  required int userId,
  required double alphaWave,
  required double betaWave,
  required double thetaWave,
  required double deltaWave,
  double gammaWave = 0,
  double attentionScore = 0,
  double meditationScore = 0,
  String deviceName = 'Muse S',
})
```

#### `getBrainwaveData(userId)`
```dart
static Future<Map<String, dynamic>> getBrainwaveData(int userId)
```

**Returns**: Last 100 brainwave records, ordered by recorded_at DESC

---

### Test Results

#### `saveTestResult({...})`
```dart
static Future<Map<String, dynamic>> saveTestResult({
  required int userId,
  required int stressScore,
  required int depressionScore,
  required String stressLevel,
})
```

| stressLevel | คำอธิบาย |
|-------------|---------|
| `"normal"` | ปกติ |
| `"mild"` | เล็กน้อย |
| `"moderate"` | ปานกลาง |
| `"severe"` | รุนแรง |

#### `getTestResults(userId)`
```dart
static Future<Map<String, dynamic>> getTestResults(int userId)
```

---

### Activities

#### `saveActivity({...})`
```dart
static Future<Map<String, dynamic>> saveActivity({
  required int userId,
  required String activityType,   // "meditation", "breathing", "game"
  required String activityName,
  required int score,
  required int durationMinutes,
})
```

#### `getActivities(userId)`
```dart
static Future<Map<String, dynamic>> getActivities(int userId)
```

---

### Schedules

#### `getSchedules(userId)` / `addSchedule({...})` / `deleteSchedule({...})`
```dart
static Future<Map<String, dynamic>> addSchedule({
  required int userId,
  required String title,
  required String description,
  required String time,         // "HH:mm" format
  String iconName = 'event',
  String color = 'purple',
})
```

#### `updateScheduleCompletion({...})`
```dart
static Future<Map<String, dynamic>> updateScheduleCompletion({
  required int scheduleId,
  required bool isCompleted,
})
```

---

### Chat Messages

#### `sendChatMessage({...})`
```dart
static Future<Map<String, dynamic>> sendChatMessage({
  required int userId,
  required String message,
  bool isBot = false,
})
```

#### `getChatHistory(userId)`
```dart
static Future<Map<String, dynamic>> getChatHistory(int userId)
```

**Returns**: Last 50 messages, ordered by sent_at ASC

---

### Settings

#### `getSettings(userId)` / `updateSettings({...})`
```dart
static Future<Map<String, dynamic>> updateSettings({
  required int userId,
  bool? dailyReminder,
  bool? weeklyReport,
  bool? stressAlert,
  String? reminderTime,
  bool? darkMode,
  String? language,
  String? notificationPrefer,
  String? sensitivityLevel,
  String? stressThreshold,
  int? criticalFFT,
  String? brainMode,
  int? fontSize,
})
```

---

### Emergency Contacts

#### `getEmergencyContacts(userId)` / `addEmergencyContact({...})` / `updateEmergencyContact({...})` / `deleteEmergencyContact(contactId)`

```dart
static Future<Map<String, dynamic>> addEmergencyContact({
  required int userId,
  required String contactName,
  required String phoneNumber,
  String? relationship,
  String? email,
  bool isPrimary = false,
  bool notifyOnEmergency = true,
  bool notifyOnHighStress = false,
  String? notes,
})
```

---

### Elderly Profile

#### `getElderlyProfile(userId)` / `saveElderlyProfile({...})`

---

### EEG Device Management

#### `registerEEGDevice({...})` / `getEEGDevices(userId)` / `updateDeviceStatus({...})`

---

### EEG Sessions

#### `startEEGSession({...})` / `endEEGSession({...})` / `getEEGSessions(userId)`

---

### Conversations

#### `startConversation(userId)` / `endConversation({...})` / `getActiveConversation(userId)`

---

### Emotion Logs

#### `saveEmotionLog({...})`
```dart
static Future<Map<String, dynamic>> saveEmotionLog({
  required int userId,
  required String emotionType,   // "happy", "sad", "angry", "anxious", "calm"
  String? triggerEvent,
  int intensity = 5,             // 1-10
})
```

#### `getEmotionLogs(userId)` / `getEmotionLogsByType(userId, emotionType)` / `deleteEmotionLog(logId)` / `getEmotionSummary(userId)`

---

### Account Management

#### `deleteAccount(userId)`
```dart
static Future<Map<String, dynamic>> deleteAccount(int userId)
```
**Note**: Cascade deletes all related data (brainwave, tests, activities, schedules, chats, settings, etc.)

---

### Voice Metadata

#### `saveVoiceMetadata({...})` / `getVoiceMetadata(messageId)`

---

## 🤖 ChatGPTService API Reference

> **ไฟล์**: `lib/services/chatgpt_service.dart`  
> **จำนวน Methods**: 5

### `sendMessage({message, chatHistory})`
```dart
static Future<Map<String, dynamic>> sendMessage({
  required String message,
  List<Map<String, dynamic>>? chatHistory,
})
```

**Returns**:
```json
{
  "success": true,
  "bot_response": "AI response text..."
}
```

---

### `sendMessageWithRAG({message, chatHistory, userId})`
```dart
static Future<Map<String, dynamic>> sendMessageWithRAG({
  required String message,
  List<Map<String, dynamic>>? chatHistory,
  int? userId,
})
```

**Returns**:
```json
{
  "success": true,
  "bot_response": "AI response with RAG context...",
  "rag_used": true,
  "retrieved_knowledge_ids": [1, 3, 5]
}
```

---

### `sendMessageWithBrainwaveContext({message, brainwaveData, chatHistory})`
```dart
static Future<Map<String, dynamic>> sendMessageWithBrainwaveContext({
  required String message,
  required Map<String, double> brainwaveData,
  List<Map<String, dynamic>>? chatHistory,
})
```

**brainwaveData format**:
```json
{
  "alpha": 35.0,
  "beta": 25.0,
  "theta": 20.0,
  "delta": 15.0,
  "gamma": 5.0,
  "attention": 65.0,
  "meditation": 72.0
}
```

---

### `setUserId(userId)` / `toggleRAG(enabled)`

---

## 🔍 RAGService API Reference

> **ไฟล์**: `lib/services/rag_service.dart`  
> **จำนวน Methods**: 12

### `createEmbedding(text)`
```dart
static Future<List<double>> createEmbedding(String text)
```
**Description**: สร้าง 1536-dimensional embedding vector จาก OpenAI API  
**Model**: text-embedding-ada-002

---

### `searchKnowledge(query, {maxResults, threshold, category})`
```dart
static Future<List<Map<String, dynamic>>> searchKnowledge(
  String query, {
  int? maxResults,
  double? threshold,
  String? category,
})
```

**Search Strategy**:
1. Vector Search (pgvector cosine similarity)
2. Keyword Search (SQL ILIKE fallback)
3. Broad Search (word-by-word matching)
4. Merge & Deduplicate results

---

### `buildContext(results)` / `buildUserContext(userId)`
### `addKnowledge({title, content, category, tags})`
### `updateEmbeddings()`
### `getAllKnowledge({category, limit})` / `getCategories()`

---

## 📡 MuseService API Reference

> **ไฟล์**: `lib/services/muse_service.dart`  
> **จำนวน Methods**: 17

### Key Methods

| Method | Description |
|--------|-------------|
| `isBluetoothAvailable()` | ตรวจสอบ Bluetooth |
| `startScan()` | สแกนอุปกรณ์ (filter: "Muse") |
| `stopScan()` | หยุดสแกน |
| `connectToDevice(device)` | เชื่อมต่อ Muse |
| `disconnect()` | ตัดการเชื่อมต่อ |
| `startSimulation()` | เริ่ม Simulation mode |
| `stopSimulation()` | หยุด Simulation |
| `dispose()` | Cleanup resources |

### Internal Processing Methods

| Method | Description |
|--------|-------------|
| `_setupMuseConnection()` | Setup BLE services & characteristics |
| `_processEEGData(uuid, rawData)` | ประมวลผล raw EEG data |
| `_parseMuseEEGPacket(rawData)` | Parse Muse packet format |
| `_calculateFFT()` | FFT → Alpha/Beta/Theta/Delta/Gamma |
| `_addToWindow(window, samples)` | Sliding window buffer |
| `getPower(buf)` | คำนวณ signal power |

---

## 🔊 TTSService API Reference

> **ไฟล์**: `lib/services/tts_service.dart`

- `speak(text)` - อ่านข้อความออกเสียงภาษาไทย
- `stop()` - หยุดอ่าน
- `setLanguage(lang)` - ตั้งค่าภาษา
- `setSpeechRate(rate)` - ตั้งค่าความเร็ว

---

## 🎤 STTService API Reference

> **ไฟล์**: `lib/services/stt_service.dart`

- `initialize()` - เริ่มต้นระบบ
- `startListening(onResult)` - เริ่มฟัง
- `stopListening()` - หยุดฟัง
- `isAvailable()` - ตรวจสอบความพร้อม

---

## 📊 API Flow Diagrams

### Login Flow
```
User → LoginScreen → SupabaseService.login() → Supabase DB
  ← {success, user_id} ← SELECT * FROM users WHERE username=? ← 
  → MainNavigation (if success)
```

### Chat with RAG Flow
```
User → RecommendationScreen → ChatGPTService.sendMessageWithRAG()
  → RAGService.searchKnowledge() → Supabase (pgvector)
    ← Retrieved Knowledge ←
  → RAGService.buildContext()
  → OpenAI API (GPT-4o + enhanced prompt)
    ← AI Response ←
  → SupabaseService.sendChatMessage() → Save to DB
  → TTSService.speak() → Audio output
  ← Display response ←
```

### Brainwave Monitoring Flow
```
Muse Device → Bluetooth BLE → MuseService.connectToDevice()
  → _setupMuseConnection() → subscribe to EEG characteristics
  → _processEEGData() → _parseMuseEEGPacket() → _calculateFFT()
  → notifyListeners() → HomeScreen UI update
  → SupabaseService.saveBrainwaveData() → Save to DB
```

---

> **📝 หมายเหตุ**: เอกสารนี้ครอบคลุม API ทั้งหมดของ SmartBrain Care ที่ระดับ Function Level

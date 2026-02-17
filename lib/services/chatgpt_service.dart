import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'rag_service.dart';

class ChatGPTService {
  // ==================== CONFIGURATION ====================
  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini'; // หรือ 'gpt-4o' สำหรับประสิทธิภาพสูงสุด
  
  // RAG Configuration
  static bool _useRAG = true;  // เปิด/ปิด RAG
  static int? _currentUserId;  // User ID สำหรับ personalized context
  
  // System prompt สำหรับ AI (Base prompt - RAG context จะถูกเพิ่มด้านล่าง)
  static const String _baseSystemPrompt = '''
คุณคือ "สมาร์ทเบรน AI" ผู้เชี่ยวชาญด้านคลื่นสมองและสุขภาพจิต ทำหน้าที่:

1. **ความรู้เฉพาะทาง:**
   - คลื่นสมอง 5 ประเภท: Delta (0.5-4 Hz), Theta (4-8 Hz), Alpha (8-13 Hz), Beta (13-30 Hz), Gamma (30-100+ Hz)
   - ความสัมพันธ์ระหว่างคลื่นสมองกับสุขภาพจิต
   - วิธีเพิ่มคลื่น Alpha/Theta ด้วยการทำสมาธิ
   - อุปกรณ์ EEG สำหรับผู้บริโภค เช่น Muse S, Muse 2

2. **บทบาท:**
   - ให้คำแนะนำเรื่องสุขภาพจิต ความเครียด การนอนหลับ
   - อธิบายข้อมูลคลื่นสมองให้เข้าใจง่าย
   - แนะนำกิจกรรมลดความเครียด เช่น หายใจลึก สมาธิ
   - เตือนความจำเรื่องการดูแลสุขภาพจิต

3. **รูปแบบการตอบ:**
   - ใช้ภาษาไทยที่เป็นกันเอง
   - ห้ามใช้ emoji ทุกชนิด
   - ห้ามใช้อักษรพิเศษเช่น ** ## * - หรือ markdown formatting ใดๆ ทั้งสิ้น
   - ตอบเป็นข้อความธรรมดาอ่านง่าย ไม่ต้องมีหัวข้อ ไม่ต้องมีสัญลักษณ์
   - ตอบกระชับ ไม่เกิน 3-4 ประโยค
   - ใส่คำแนะนำที่นำไปใช้ได้จริง

4. **สำคัญ (RAG):**
   - ใช้ข้อมูลอ้างอิงที่ให้มาเป็นหลักในการตอบ
   - หากมีข้อมูลผู้ใช้ ให้ปรับคำตอบให้เหมาะสมกับสถานการณ์ของผู้ใช้
   - อ้างอิงข้อมูลจากฐานความรู้เพื่อเพิ่มความน่าเชื่อถือ
''';
  
  // Legacy system prompt (backwards compatibility)
  static const String _systemPrompt = _baseSystemPrompt;

  /// ส่งข้อความไปยัง ChatGPT และรับคำตอบ
  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    List<Map<String, dynamic>>? chatHistory,
  }) async {
    // ตรวจสอบ API Key
    if (_apiKey == 'YOUR_OPENAI_API_KEY' || _apiKey.isEmpty) {
      return {
        'success': false,
        'message': 'กรุณาตั้งค่า OpenAI API Key ใน chatgpt_service.dart',
      };
    }

    try {
      // สร้าง messages array
      final messages = <Map<String, dynamic>>[
        {'role': 'system', 'content': _systemPrompt},
      ];
      
      // เพิ่ม chat history (ถ้ามี)
      if (chatHistory != null && chatHistory.isNotEmpty) {
        // เก็บแค่ 10 messages ล่าสุดเพื่อประหยัด token
        final recentHistory = chatHistory.length > 10 
            ? chatHistory.sublist(chatHistory.length - 10)
            : chatHistory;
            
        for (final msg in recentHistory) {
          messages.add({
            'role': msg['is_bot'] == true ? 'assistant' : 'user',
            'content': msg['message'] ?? '',
          });
        }
      }
      
      // เพิ่มข้อความใหม่
      messages.add({'role': 'user', 'content': message});

      // เรียก API
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': _model,
          'messages': messages,
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final botResponse = data['choices'][0]['message']['content'];
        
        return {
          'success': true,
          'bot_response': botResponse,
          'usage': data['usage'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': 'API Error: ${errorData['error']['message'] ?? response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'เครือข่ายมีปัญหา: $e',
      };
    }
  }
  
  // ==================== RAG METHODS ====================
  
  /// ตั้งค่า User ID สำหรับ personalized context
  static void setUserId(int? userId) {
    _currentUserId = userId;
  }
  
  /// เปิด/ปิด RAG
  static void toggleRAG(bool enabled) {
    _useRAG = enabled;
  }
  
  /// ตรวจสอบสถานะ RAG
  static bool get isRAGEnabled => _useRAG;
  
  /// ส่งข้อความพร้อม RAG (Retrieval-Augmented Generation)
  /// ค้นหาความรู้ที่เกี่ยวข้องจาก knowledge base ก่อนสร้างคำตอบ
  static Future<Map<String, dynamic>> sendMessageWithRAG({
    required String message,
    List<Map<String, dynamic>>? chatHistory,
    int? userId,
  }) async {
    // ตรวจสอบ API Key
    if (_apiKey == 'YOUR_OPENAI_API_KEY' || _apiKey.isEmpty) {
      return {
        'success': false,
        'message': 'กรุณาตั้งค่า OpenAI API Key ใน chatgpt_service.dart',
      };
    }

    try {
      // 1. ค้นหาความรู้ที่เกี่ยวข้องจาก RAG
      String ragContext = '';
      List<int> retrievedKnowledgeIds = [];
      
      if (_useRAG) {
        final searchResults = await RAGService.searchKnowledge(
          message,
          maxResults: 5,
          threshold: 0.5,
        );
        
        // Debug: แสดงผลการค้นหา
        debugPrint('📚 RAG Search for: "$message"');
        debugPrint('📚 RAG Found: ${searchResults.length} results');
        
        if (searchResults.isNotEmpty) {
          ragContext = RAGService.buildContext(searchResults);
          retrievedKnowledgeIds = searchResults
              .map((r) => r['id'] as int)
              .toList();
          
          // Debug: แสดงหัวข้อที่เจอ
          for (final r in searchResults) {
            debugPrint('   📖 ${r['title']}');
          }
        }
        
        // 2. ดึง user context ถ้ามี userId
        final effectiveUserId = userId ?? _currentUserId;
        if (effectiveUserId != null) {
          final userContext = await RAGService.buildUserContext(effectiveUserId);
          if (userContext.isNotEmpty) {
            ragContext = '$userContext\n$ragContext';
          }
        }
      }
      
      // 3. สร้าง enhanced system prompt
      String enhancedSystemPrompt = _baseSystemPrompt;
      if (ragContext.isNotEmpty) {
        // บังคับให้ AI ใช้ข้อมูลจาก context เท่านั้น
        enhancedSystemPrompt = '''$_baseSystemPrompt

⚠️ สำคัญมาก: ใช้ข้อมูลจาก "ข้อมูลอ้างอิง" ด้านล่างนี้เท่านั้นในการตอบ
ห้ามใช้ความรู้อื่นที่ไม่ได้ระบุไว้ในข้อมูลอ้างอิง
หากไม่มีข้อมูลในอ้างอิง ให้ตอบว่าไม่มีข้อมูล

$ragContext''';
        debugPrint('📚 RAG Context added to prompt');
      } else {
        debugPrint('⚠️ RAG: No context found, using base prompt only');
      }
      
      // 4. สร้าง messages array
      final messages = <Map<String, dynamic>>[
        {'role': 'system', 'content': enhancedSystemPrompt},
      ];
      
      // เพิ่ม chat history (ถ้ามี)
      if (chatHistory != null && chatHistory.isNotEmpty) {
        // เก็บแค่ 10 messages ล่าสุดเพื่อประหยัด token
        final recentHistory = chatHistory.length > 10 
            ? chatHistory.sublist(chatHistory.length - 10)
            : chatHistory;
            
        for (final msg in recentHistory) {
          messages.add({
            'role': msg['is_bot'] == true ? 'assistant' : 'user',
            'content': msg['message'] ?? '',
          });
        }
      }
      
      // เพิ่มข้อความใหม่
      messages.add({'role': 'user', 'content': message});

      // 5. เรียก API
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': _model,
          'messages': messages,
          'max_tokens': 800,  // เพิ่ม tokens สำหรับ context-aware responses
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final botResponse = data['choices'][0]['message']['content'];
        
        return {
          'success': true,
          'bot_response': botResponse,
          'usage': data['usage'],
          'rag_used': _useRAG && ragContext.isNotEmpty,
          'retrieved_knowledge_ids': retrievedKnowledgeIds,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': 'API Error: ${errorData['error']['message'] ?? response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'เครือข่ายมีปัญหา: $e',
      };
    }
  }
  
  /// ส่งข้อความพร้อมข้อมูลคลื่นสมอง (สำหรับ personalized recommendations)
  static Future<Map<String, dynamic>> sendMessageWithBrainwaveContext({
    required String message,
    required Map<String, double> brainwaveData,
    List<Map<String, dynamic>>? chatHistory,
  }) async {
    // สร้าง brainwave context
    final brainwaveContext = '''
=== ข้อมูลคลื่นสมองปัจจุบัน ===
🧠 Alpha: ${brainwaveData['alpha']?.toStringAsFixed(1) ?? 'N/A'}%
🧠 Beta: ${brainwaveData['beta']?.toStringAsFixed(1) ?? 'N/A'}%
🧠 Theta: ${brainwaveData['theta']?.toStringAsFixed(1) ?? 'N/A'}%
🧠 Delta: ${brainwaveData['delta']?.toStringAsFixed(1) ?? 'N/A'}%
🧠 Gamma: ${brainwaveData['gamma']?.toStringAsFixed(1) ?? 'N/A'}%
📊 Attention Score: ${brainwaveData['attention']?.toStringAsFixed(1) ?? 'N/A'}
📊 Meditation Score: ${brainwaveData['meditation']?.toStringAsFixed(1) ?? 'N/A'}
=== จบข้อมูลคลื่นสมอง ===
''';
    
    // เพิ่ม context เข้าไปในข้อความ
    final enhancedMessage = '''$brainwaveContext

คำถามผู้ใช้: $message

กรุณาให้คำแนะนำโดยอ้างอิงจากข้อมูลคลื่นสมองข้างต้น''';
    
    return await sendMessageWithRAG(
      message: enhancedMessage,
      chatHistory: chatHistory,
    );
  }
  
  /// ตรวจสอบว่า API Key ถูกตั้งค่าแล้วหรือยัง
  static bool get isConfigured => 
      _apiKey != 'YOUR_OPENAI_API_KEY' && _apiKey.isNotEmpty;
}


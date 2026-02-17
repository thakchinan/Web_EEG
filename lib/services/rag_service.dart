import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'supabase_service.dart';

/// RAG Service - Retrieval-Augmented Generation
/// ใช้สำหรับค้นหาความรู้จาก knowledge base และเสริมคำตอบของ AI
class RAGService {
  // ==================== CONFIGURATION ====================
  static String get _openaiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String _embeddingModel = 'text-embedding-3-small';
  static const String _embeddingUrl = 'https://api.openai.com/v1/embeddings';
  
  // RAG Configuration
  static const int _maxResults = 5;           // จำนวนผลลัพธ์สูงสุด
  static const double _matchThreshold = 0.7;  // Similarity threshold
  
  // ==================== EMBEDDING ====================
  
  /// สร้าง Embedding จากข้อความโดยใช้ OpenAI API
  static Future<List<double>?> createEmbedding(String text) async {
    if (_openaiApiKey.isEmpty || _openaiApiKey == 'YOUR_OPENAI_API_KEY') {
      print('RAG: OpenAI API Key not configured');
      return null;
    }
    
    try {
      final response = await http.post(
        Uri.parse(_embeddingUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openaiApiKey',
        },
        body: json.encode({
          'model': _embeddingModel,
          'input': text,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final embedding = data['data'][0]['embedding'] as List;
        return embedding.map((e) => e as double).toList();
      } else {
        print('RAG Embedding Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('RAG Embedding Exception: $e');
      return null;
    }
  }
  
  // ==================== KNOWLEDGE SEARCH ====================
  
  /// ค้นหาความรู้ที่เกี่ยวข้องจาก knowledge base
  static Future<List<Map<String, dynamic>>> searchKnowledge(
    String query, {
    int? maxResults,
    double? threshold,
    String? category,
  }) async {
    try {
      // 1. ลองใช้ keyword search ก่อน (เร็วและเชื่อถือได้)
      var results = await _keywordSearch(query, category: category);
      
      if (results.isNotEmpty) {
        debugPrint('🔍 RAG: Found ${results.length} results via keyword search');
        return results.take(maxResults ?? _maxResults).toList();
      }
      
      // 2. ถ้า keyword search ไม่เจอ ลอง vector search
      final embedding = await createEmbedding(query);
      
      if (embedding != null) {
        results = await _vectorSearch(
          embedding,
          maxResults: maxResults ?? _maxResults,
          threshold: threshold ?? _matchThreshold,
          category: category,
        );
        
        if (results.isNotEmpty) {
          debugPrint('🔍 RAG: Found ${results.length} results via vector search');
          return results;
        }
      }
      
      // 3. ถ้ายังไม่เจอ ลองค้นหาแบบกว้างขึ้น
      results = await _broadSearch(query);
      debugPrint('🔍 RAG: Found ${results.length} results via broad search');
      
      return results.take(maxResults ?? _maxResults).toList();
    } catch (e) {
      debugPrint('RAG Search Error: $e');
      return [];
    }
  }
  
  /// Broad search - ค้นหาแบบกว้าง แยกคำ
  static Future<List<Map<String, dynamic>>> _broadSearch(String query) async {
    try {
      // แยกคำสำคัญ
      final keywords = query.split(RegExp(r'[\s,]+'))
          .where((w) => w.length > 2)
          .take(3)
          .toList();
      
      if (keywords.isEmpty) {
        return [];
      }
      
      // ค้นหาแต่ละคำ
      final orConditions = keywords
          .map((k) => 'title.ilike.%$k%,content.ilike.%$k%')
          .join(',');
      
      final response = await SupabaseService.client
          .from('knowledge_base')
          .select('id, title, content, category')
          .or(orConditions)
          .limit(_maxResults);
      
      return (response as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('RAG Broad Search Error: $e');
      return [];
    }
  }
  
  /// Vector similarity search
  static Future<List<Map<String, dynamic>>> _vectorSearch(
    List<double> embedding, {
    required int maxResults,
    required double threshold,
    String? category,
  }) async {
    try {
      // เรียก RPC function ใน Supabase
      final response = await SupabaseService.client.rpc(
        'search_knowledge',
        params: {
          'query_embedding': embedding.toString(),
          'match_count': maxResults,
          'match_threshold': threshold,
        },
      );
      
      if (response == null) return [];
      
      final List<Map<String, dynamic>> results = 
          (response as List).map((e) => e as Map<String, dynamic>).toList();
      
      // กรองตาม category ถ้าระบุ
      if (category != null) {
        return results.where((r) => r['category'] == category).toList();
      }
      
      return results;
    } catch (e) {
      debugPrint('RAG Vector Search Error: $e');
      // Fallback to keyword search
      return await _keywordSearch(embedding.toString());
    }
  }
  
  /// Keyword-based search (fallback)
  static Future<List<Map<String, dynamic>>> _keywordSearch(
    String query, {
    String? category,
  }) async {
    try {
      // แยกคำสำคัญและทำให้เป็น pattern ที่ค้นหาได้
      final keywords = _extractKeywords(query);
      debugPrint('🔍 Keywords extracted: $keywords');
      
      if (keywords.isEmpty) {
        return [];
      }
      
      // สร้าง OR conditions สำหรับแต่ละ keyword
      final orConditions = keywords
          .map((k) => 'title.ilike.%$k%,content.ilike.%$k%')
          .join(',');
      
      var queryBuilder = SupabaseService.client
          .from('knowledge_base')
          .select('id, title, content, category');
      
      // Add category filter if specified
      if (category != null) {
        queryBuilder = queryBuilder.eq('category', category);
      }
      
      final response = await queryBuilder
          .or(orConditions)
          .limit(_maxResults);
      
      final results = (response as List).map((e) => e as Map<String, dynamic>).toList();
      debugPrint('🔍 Keyword search found: ${results.length} results');
      
      return results;
    } catch (e) {
      debugPrint('RAG Keyword Search Error: $e');
      return [];
    }
  }
  
  /// แยกคำสำคัญจาก query
  static List<String> _extractKeywords(String query) {
    // Mapping สำหรับคำที่มีหลายแบบการสะกด
    final synonyms = {
      'สมาริตันส์': ['สมาริตันส์', 'สะมาริตันส์', 'Samaritans'],
      'สะมาริตันส์': ['สมาริตันส์', 'สะมาริตันส์', 'Samaritans'],
      'samaritans': ['สมาริตันส์', 'สะมาริตันส์', 'Samaritans'],
      'เบอร์': ['เบอร์', 'โทร', 'หมายเลข'],
      'โทร': ['เบอร์', 'โทร', 'หมายเลข'],
      'สุขภาพจิต': ['สุขภาพจิต', '1323'],
      '1323': ['สุขภาพจิต', '1323', 'สายด่วน'],
      'สายด่วน': ['สายด่วน', '1323', 'ฉุกเฉิน'],
      'ฉุกเฉิน': ['ฉุกเฉิน', 'emergency', 'สายด่วน'],
      'ทำร้ายตัวเอง': ['ทำร้ายตัวเอง', 'ฆ่าตัวตาย', 'อันตราย'],
      'ฆ่าตัวตาย': ['ทำร้ายตัวเอง', 'ฆ่าตัวตาย', 'สะมาริตันส์'],
      'เครียด': ['เครียด', 'stress', 'กังวล'],
      'ซึมเศร้า': ['ซึมเศร้า', 'depression', 'เศร้า'],
    };
    
    // แยกคำจาก query
    final words = query
        .toLowerCase()
        .split(RegExp(r'[\s,?!.]+'))
        .where((w) => w.length > 1)
        .toList();
    
    final keywords = <String>[];
    
    for (final word in words) {
      // เพิ่มคำหลัก
      keywords.add(word);
      
      // เพิ่ม synonyms
      for (final entry in synonyms.entries) {
        if (word.contains(entry.key.toLowerCase()) || 
            entry.key.toLowerCase().contains(word)) {
          keywords.addAll(entry.value);
        }
      }
    }
    
    // ลบคำซ้ำและคำสั้นเกินไป
    return keywords
        .toSet()
        .where((k) => k.length > 1)
        .take(6)
        .toList();
  }
  
  // ==================== CONTEXT BUILDING ====================
  
  /// สร้าง context จากผลการค้นหาสำหรับส่งให้ AI
  static String buildContext(List<Map<String, dynamic>> searchResults) {
    if (searchResults.isEmpty) {
      return '';
    }
    
    final buffer = StringBuffer();
    buffer.writeln('=== ข้อมูลอ้างอิงที่เกี่ยวข้อง ===');
    
    for (int i = 0; i < searchResults.length; i++) {
      final result = searchResults[i];
      buffer.writeln('');
      buffer.writeln('📚 ${i + 1}. ${result['title'] ?? 'ไม่มีหัวข้อ'}');
      buffer.writeln('${result['content'] ?? 'ไม่มีเนื้อหา'}');
    }
    
    buffer.writeln('');
    buffer.writeln('=== จบข้อมูลอ้างอิง ===');
    
    return buffer.toString();
  }
  
  /// สร้าง context เฉพาะผู้ใช้
  static Future<String> buildUserContext(int userId) async {
    try {
      final response = await SupabaseService.client.rpc(
        'get_user_context',
        params: {
          'p_user_id': userId,
          'context_limit': 5,
        },
      );
      
      if (response == null || (response as List).isEmpty) {
        return '';
      }
      
      final buffer = StringBuffer();
      buffer.writeln('=== ข้อมูลผู้ใช้ ===');
      
      for (final context in response) {
        if (context['brainwave_avg'] != null) {
          final avg = context['brainwave_avg'] as Map<String, dynamic>;
          buffer.writeln('📊 คลื่นสมองเฉลี่ย 7 วันล่าสุด:');
          buffer.writeln('   - Alpha: ${(avg['alpha'] ?? 0).toStringAsFixed(1)}%');
          buffer.writeln('   - Beta: ${(avg['beta'] ?? 0).toStringAsFixed(1)}%');
          buffer.writeln('   - Theta: ${(avg['theta'] ?? 0).toStringAsFixed(1)}%');
          buffer.writeln('   - Attention: ${(avg['attention'] ?? 0).toStringAsFixed(1)}');
          buffer.writeln('   - Meditation: ${(avg['meditation'] ?? 0).toStringAsFixed(1)}');
        }
        
        if (context['stress_level'] != null) {
          buffer.writeln('😰 ระดับความเครียดล่าสุด: ${_translateStressLevel(context['stress_level'])}');
        }
        
        if (context['recent_activities'] != null) {
          buffer.writeln('🎯 กิจกรรมล่าสุด: ${(context['recent_activities'] as List).join(', ')}');
        }
      }
      
      buffer.writeln('=== จบข้อมูลผู้ใช้ ===');
      
      return buffer.toString();
    } catch (e) {
      print('RAG User Context Error: $e');
      return '';
    }
  }
  
  /// แปลระดับความเครียดเป็นภาษาไทย
  static String _translateStressLevel(String level) {
    switch (level.toLowerCase()) {
      case 'normal':
        return 'ปกติ';
      case 'mild':
        return 'เครียดเล็กน้อย';
      case 'moderate':
        return 'เครียดปานกลาง';
      case 'severe':
        return 'เครียดสูง';
      default:
        return level;
    }
  }
  
  // ==================== KNOWLEDGE MANAGEMENT ====================
  
  /// เพิ่มความรู้ใหม่เข้า knowledge base
  static Future<Map<String, dynamic>> addKnowledge({
    required String title,
    required String content,
    String category = 'general',
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // สร้าง embedding สำหรับเนื้อหา
      final embedding = await createEmbedding('$title $content');
      
      final insertData = {
        'title': title,
        'content': content,
        'category': category,
        'tags': tags ?? [],
        'metadata': metadata ?? {},
      };
      
      if (embedding != null) {
        insertData['embedding'] = embedding.toString();
      }
      
      final response = await SupabaseService.client
          .from('knowledge_base')
          .insert(insertData)
          .select()
          .single();
      
      return {
        'success': true,
        'message': 'เพิ่มความรู้สำเร็จ',
        'id': response['id'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'ไม่สามารถเพิ่มความรู้ได้: $e',
      };
    }
  }
  
  /// อัปเดต embeddings สำหรับ knowledge ที่ยังไม่มี
  static Future<Map<String, dynamic>> updateEmbeddings() async {
    try {
      // ดึง knowledge ที่ยังไม่มี embedding
      final response = await SupabaseService.client
          .from('knowledge_base')
          .select('id, title, content')
          .isFilter('embedding', null);
      
      if (response == null || (response as List).isEmpty) {
        return {
          'success': true,
          'message': 'ไม่มีความรู้ที่ต้องอัปเดต',
          'updated_count': 0,
        };
      }
      
      int updatedCount = 0;
      
      for (final item in response) {
        final embedding = await createEmbedding(
          '${item['title']} ${item['content']}'
        );
        
        if (embedding != null) {
          await SupabaseService.client
              .from('knowledge_base')
              .update({'embedding': embedding.toString()})
              .eq('id', item['id']);
          updatedCount++;
        }
        
        // Rate limiting
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      return {
        'success': true,
        'message': 'อัปเดต embeddings สำเร็จ',
        'updated_count': updatedCount,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'ไม่สามารถอัปเดต embeddings ได้: $e',
      };
    }
  }
  
  /// ดึง knowledge ทั้งหมด
  static Future<List<Map<String, dynamic>>> getAllKnowledge({
    String? category,
    int limit = 50,
  }) async {
    try {
      var query = SupabaseService.client
          .from('knowledge_base')
          .select('id, title, content, category, tags, created_at');
      
      if (category != null) {
        query = query.eq('category', category);
      }
      
      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);
      
      return (response as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('RAG Get All Knowledge Error: $e');
      return [];
    }
  }
  
  /// ดึง categories ทั้งหมด
  static Future<List<String>> getCategories() async {
    try {
      final response = await SupabaseService.client
          .from('knowledge_base')
          .select('category')
          .order('category');
      
      final categories = (response as List)
          .map((e) => e['category'] as String)
          .toSet()
          .toList();
      
      return categories;
    } catch (e) {
      print('RAG Get Categories Error: $e');
      return [];
    }
  }
}

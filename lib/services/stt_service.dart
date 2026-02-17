import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

/// Service สำหรับ Speech-to-Text ใช้ OpenAI Whisper API
/// รองรับทุก platform: iOS/Android (Simulator + จริง), macOS
class STTService {
  static final STTService _instance = STTService._internal();
  factory STTService() => _instance;
  STTService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastRecognizedText = '';

  // OpenAI API Key (ใช้ key เดียวกับ ChatGPT service)
  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String _whisperUrl =
      'https://api.openai.com/v1/audio/transcriptions';

  String? _currentRecordingPath;

  // Callbacks
  Function(String)? onResult;
  Function(String)? onPartialResult;
  Function()? onListeningStarted;
  Function()? onListeningStopped;
  Function(String)? onError;

  /// ตรวจสอบว่ากำลังฟังอยู่หรือไม่
  bool get isListening => _isListening;

  /// ตรวจสอบว่า STT พร้อมใช้งานหรือไม่
  bool get isAvailable => _isInitialized;

  /// ข้อความที่รับรู้ล่าสุด
  String get lastRecognizedText => _lastRecognizedText;

  /// Initialize STT — ตรวจสอบว่ามีไมค์หรือไม่
  Future<bool> init() async {
    if (_isInitialized) return true;

    try {
      // ตรวจสอบว่ามี microphone permission หรือไม่
      final hasPermission = await _recorder.hasPermission();
      debugPrint('🎤 Whisper STT: hasPermission = $hasPermission');

      if (!hasPermission) {
        debugPrint('🎤 Whisper STT: ไม่มีสิทธิ์ไมโครโฟน');
        onError?.call('กรุณาอนุญาตการใช้ไมโครโฟน');
        return false;
      }

      _isInitialized = true;
      debugPrint('🎤 Whisper STT: Initialized ✅');
      return true;
    } catch (e) {
      debugPrint('🎤 Whisper STT Init Error: $e');
      onError?.call('ไม่สามารถเปิดไมโครโฟนได้: $e');
      return false;
    }
  }

  /// เริ่มฟัง (บันทึกเสียง)
  Future<void> startListening() async {
    if (!_isInitialized) {
      final success = await init();
      if (!success) {
        onError?.call('ไม่สามารถเปิดไมโครโฟนได้');
        return;
      }
    }

    if (_isListening) {
      // ถ้ากำลังฟังอยู่ → หยุดแล้วส่งผลลัพธ์
      await stopListening();
      return;
    }

    try {
      // Set listening state BEFORE async start เพื่อกัน race condition
      _isListening = true;
      _lastRecognizedText = '';
      onListeningStarted?.call();
      onPartialResult?.call('กำลังฟัง... พูดแล้วกดไมค์อีกทีเพื่อหยุด 🎤');

      // สร้าง file path สำหรับบันทึก
      final dir = await getTemporaryDirectory();
      _currentRecordingPath =
          '${dir.path}/stt_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // เริ่มบันทึก
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 64000,
        ),
        path: _currentRecordingPath!,
      );

      debugPrint('🎤 Whisper STT: Start recording → $_currentRecordingPath');
    } catch (e) {
      debugPrint('🎤 Whisper STT: Start error: $e');
      _isListening = false;
      onListeningStopped?.call();
      onError?.call('ไม่สามารถเริ่มบันทึกเสียงได้: $e');
    }
  }

  /// หยุดฟัง (หยุดบันทึกแล้วส่ง Whisper API)
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      final path = await _recorder.stop();
      _isListening = false;
      debugPrint('🎤 Whisper STT: Stopped recording → $path');

      if (path != null && path.isNotEmpty) {
        // แสดงสถานะกำลังแปลง
        onPartialResult?.call('กำลังแปลงเสียง...');

        // ส่งไฟล์ไป Whisper API
        final text = await _transcribeWithWhisper(path);

        if (text != null && text.isNotEmpty) {
          _lastRecognizedText = text;
          debugPrint('🎤 Whisper STT: Result → $text');
          onResult?.call(text);
        } else {
          debugPrint('🎤 Whisper STT: No text recognized');
          onPartialResult?.call('');
        }

        // ลบไฟล์บันทึกชั่วคราว
        try {
          final file = File(path);
          if (await file.exists()) await file.delete();
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('🎤 Whisper STT: Stop error: $e');
      _isListening = false;
      onError?.call('เกิดข้อผิดพลาดในการแปลงเสียง');
    } finally {
      onListeningStopped?.call();
    }
  }

  /// ยกเลิกการฟัง
  Future<void> cancelListening() async {
    if (!_isListening) return;

    try {
      await _recorder.stop();
    } catch (_) {}

    _isListening = false;
    _lastRecognizedText = '';

    // ลบไฟล์บันทึก
    if (_currentRecordingPath != null) {
      try {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }

    onListeningStopped?.call();
  }

  /// ส่งไฟล์เสียงไป OpenAI Whisper API
  Future<String?> _transcribeWithWhisper(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('🎤 Whisper: File not found: $filePath');
        return null;
      }

      final fileSize = await file.length();
      debugPrint('🎤 Whisper: Sending file ($fileSize bytes)');

      // ถ้าไฟล์เล็กเกินไป (< 1KB) อาจจะไม่มีเสียง
      if (fileSize < 1000) {
        debugPrint('🎤 Whisper: File too small, likely no audio');
        return null;
      }

      final request = http.MultipartRequest('POST', Uri.parse(_whisperUrl));
      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.fields['model'] = 'whisper-1';
      request.fields['language'] = 'th'; // ภาษาไทย
      request.fields['response_format'] = 'json';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final json = jsonDecode(responseBody);
        final text = json['text'] as String?;
        debugPrint('🎤 Whisper: Success → "$text"');
        return text?.trim();
      } else {
        debugPrint('🎤 Whisper: Error ${response.statusCode}: $responseBody');
        onError?.call('ไม่สามารถแปลงเสียงได้ ลองใหม่อีกครั้ง');
        return null;
      }
    } catch (e) {
      debugPrint('🎤 Whisper: Exception: $e');
      onError?.call('เกิดข้อผิดพลาดในการเชื่อมต่อ');
      return null;
    }
  }

  /// เปลี่ยนภาษา (สำหรับ compatibility)
  void setLocale(String localeId) {
    // Whisper รองรับหลายภาษาอัตโนมัติ
    debugPrint('🎤 Whisper STT: setLocale → $localeId (auto-detected)');
  }

  /// ปิด STT
  void dispose() {
    cancelListening();
    _recorder.dispose();
    onResult = null;
    onPartialResult = null;
    onListeningStarted = null;
    onListeningStopped = null;
    onError = null;
  }
}

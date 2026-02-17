import 'package:flutter_tts/flutter_tts.dart';

/// Service สำหรับ Text-to-Speech ให้ AI พูดได้
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _autoSpeak = false;

  /// ตรวจสอบว่ากำลังพูดอยู่หรือไม่
  bool get isSpeaking => _isSpeaking;

  /// ตั้งค่า auto-speak
  bool get autoSpeak => _autoSpeak;
  set autoSpeak(bool value) => _autoSpeak = value;

  /// Initialize TTS
  Future<void> init() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage('th-TH');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
    });

    _isInitialized = true;
  }

  /// พูดข้อความ
  Future<void> speak(String text) async {
    if (!_isInitialized) await init();
    
    // หยุดพูดก่อนถ้ากำลังพูดอยู่
    if (_isSpeaking) {
      await stop();
    }

    await _flutterTts.speak(text);
  }

  /// หยุดพูด
  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  /// ตั้งค่าความเร็วในการพูด (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  /// ตั้งค่า pitch (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

  /// ปิด TTS
  Future<void> dispose() async {
    await stop();
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import '../models/brain_data.dart';

class BrainProvider extends ChangeNotifier {
  TestResult? _testResult;
  BrainwaveData _brainwaveData = BrainwaveData(
    alpha: 65,
    beta: 45,
    theta: 55,
    calmState: true,
    focusLevel: FocusLevel.moderate,
    relaxation: true,
  );

  TestResult? get testResult => _testResult;
  BrainwaveData get brainwaveData => _brainwaveData;

  void setTestResult(TestResult result) {
    _testResult = result;
    notifyListeners();
  }

  void refreshBrainwave() {
    final random = Random();
    _brainwaveData = BrainwaveData(
      alpha: random.nextInt(40) + 50,
      beta: random.nextInt(40) + 30,
      theta: random.nextInt(40) + 40,
      calmState: random.nextDouble() > 0.3,
      focusLevel: random.nextDouble() > 0.6
          ? FocusLevel.high
          : random.nextDouble() > 0.3
              ? FocusLevel.moderate
              : FocusLevel.low,
      relaxation: random.nextDouble() > 0.4,
    );
    notifyListeners();
  }

  // Helper method to get stress level from score
  static StressLevel getLevel(int score, int maxScore) {
    final percent = (score / maxScore) * 100;
    if (percent <= 25) return StressLevel.normal;
    if (percent <= 50) return StressLevel.mild;
    if (percent <= 75) return StressLevel.moderate;
    return StressLevel.high;
  }

  // Get level info for display
  static Map<String, dynamic> getLevelInfo(StressLevel level) {
    switch (level) {
      case StressLevel.normal:
        return {
          'emoji': '😊',
          'text': 'ปกติ',
          'color': const Color(0xFF4CAF50),
          'message': 'สุขภาพจิตของคุณอยู่ในเกณฑ์ดี!'
        };
      case StressLevel.mild:
        return {
          'emoji': '😐',
          'text': 'เล็กน้อย',
          'color': const Color(0xFF8BC34A),
          'message': 'ควรพักผ่อนและทำกิจกรรมผ่อนคลาย'
        };
      case StressLevel.moderate:
        return {
          'emoji': '😟',
          'text': 'ปานกลาง',
          'color': const Color(0xFFFFC107),
          'message': 'ควรพูดคุยกับคนใกล้ชิด'
        };
      case StressLevel.high:
        return {
          'emoji': '😢',
          'text': 'สูง',
          'color': const Color(0xFFF44336),
          'message': 'แนะนำให้ปรึกษาผู้เชี่ยวชาญ'
        };
    }
  }
}

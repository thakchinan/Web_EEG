import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';

class MemoryGameScreen extends StatefulWidget {
  final User? user;
  
  const MemoryGameScreen({super.key, this.user});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  List<String> emojis = ['🍎', '🍊', '🍋', '🍇', '🍓', '🍑', '🍎', '🍊', '🍋', '🍇', '🍓', '🍑'];
  List<bool> revealed = [];
  List<bool> matched = [];
  int? firstIndex;
  int? secondIndex;
  bool isChecking = false;
  int moves = 0;
  int matchedPairs = 0;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    emojis.shuffle(Random());
    revealed = List.filled(12, false);
    matched = List.filled(12, false);
    firstIndex = null;
    secondIndex = null;
    isChecking = false;
    moves = 0;
    matchedPairs = 0;
    _startTime = DateTime.now();
  }

  void _onCardTap(int index) {
    if (isChecking || revealed[index] || matched[index]) return;

    setState(() {
      revealed[index] = true;
      
      if (firstIndex == null) {
        firstIndex = index;
      } else {
        secondIndex = index;
        moves++;
        isChecking = true;
        
        _checkMatch();
      }
    });
  }

  void _checkMatch() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!mounted) return;
    
    setState(() {
      if (emojis[firstIndex!] == emojis[secondIndex!]) {
        matched[firstIndex!] = true;
        matched[secondIndex!] = true;
        matchedPairs++;
        
        if (matchedPairs == 6) {
          _showWinDialog();
        }
      } else {
        revealed[firstIndex!] = false;
        revealed[secondIndex!] = false;
      }
      
      firstIndex = null;
      secondIndex = null;
      isChecking = false;
    });
  }

  Future<void> _showWinDialog() async {
    final duration = DateTime.now().difference(_startTime!).inMinutes;
    
    if (widget.user != null) {
      await ApiService.saveActivity(
        userId: widget.user!.id,
        activityType: 'game',
        activityName: 'จับคู่',
        score: (100 - moves * 2).clamp(0, 100),
        durationMinutes: duration > 0 ? duration : 1,
      );
    }

    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 ชนะแล้ว!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('คุณจับคู่ได้ครบทั้งหมดแล้ว!', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('จำนวนการเปิด: $moves ครั้ง'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _initGame());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: const Text('เล่นอีกครั้ง', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'เกมจับคู่',
          style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('จำนวนการเปิด: $moves', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                Text('จับคู่ได้: $matchedPairs/6', style: TextStyle(fontSize: 16, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: matched[index]
                            ? Colors.green.withValues(alpha: 0.3)
                            : (revealed[index] ? AppColors.primaryBlue.withValues(alpha: 0.1) : AppColors.primaryBlue),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          revealed[index] || matched[index] ? emojis[index] : '?',
                          style: TextStyle(
                            fontSize: 32,
                            color: revealed[index] || matched[index] ? null : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() => _initGame()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('เริ่มใหม่', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

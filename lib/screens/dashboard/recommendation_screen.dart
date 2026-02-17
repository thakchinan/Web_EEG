import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../services/tts_service.dart';
import '../../services/stt_service.dart';
import 'settings_screen.dart';

class RecommendationScreen extends StatefulWidget {
  final User? user;
  
  const RecommendationScreen({super.key, this.user});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final TTSService _ttsService = TTSService();
  final STTService _sttService = STTService();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _autoSpeak = true; // เปิด auto-speak เป็นค่าเริ่มต้น
  int? _speakingMessageIndex;
  
  // STT States
  bool _isVoiceMode = false; // กำลังอยู่ในโหมดพูดหรือไม่
  String _partialText = ''; // ข้อความที่กำลังรับรู้ (ยังไม่จบ)
  
  // Animation controllers
  late AnimationController _micPulseController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _initServices();
    _loadChatHistory();
    
    // Mic pulse animation
    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    // Sound wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  Future<void> _initServices() async {
    await _ttsService.init();
    await _sttService.init();
    
    // ตั้งค่า STT callbacks
    _sttService.onResult = _onSpeechResult;
    _sttService.onPartialResult = _onPartialResult;
    _sttService.onListeningStarted = _onListeningStarted;
    _sttService.onListeningStopped = _onListeningStopped;
    _sttService.onError = _onSpeechError;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _ttsService.dispose();
    _sttService.dispose();
    _micPulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  // ==================== STT CALLBACKS ====================

  void _onSpeechResult(String text) {
    if (text.isNotEmpty && mounted) {
      setState(() {
        _partialText = '';
        _isVoiceMode = false;
      });
      // ส่งข้อความอัตโนมัติหลังรับเสียงเสร็จ
      _messageController.text = text;
      _sendMessage();
    }
  }

  void _onPartialResult(String text) {
    if (mounted) {
      setState(() => _partialText = text);
    }
  }

  void _onListeningStarted() {
    if (mounted) {
      setState(() => _isVoiceMode = true);
      _micPulseController.repeat(reverse: true);
      _waveController.repeat(reverse: true);
    }
  }

  void _onListeningStopped() {
    if (mounted) {
      setState(() => _isVoiceMode = false);
      _micPulseController.stop();
      _waveController.stop();
      _micPulseController.reset();
      _waveController.reset();
    }
  }

  void _onSpeechError(String error) {
    if (mounted) {
      setState(() {
        _isVoiceMode = false;
        _partialText = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red[400],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ==================== VOICE TOGGLE ====================

  Future<void> _toggleVoiceInput() async {
    if (_sttService.isListening) {
      // กำลังฟัง → หยุดแล้วส่ง Whisper แปลงเสียง
      await _sttService.stopListening();
    } else {
      // ถ้า STT ยังไม่พร้อม ลอง init
      if (!_sttService.isAvailable) {
        final success = await _sttService.init();
        if (!success) return;
        // ตั้งค่า callbacks
        _sttService.onResult = _onSpeechResult;
        _sttService.onPartialResult = _onPartialResult;
        _sttService.onListeningStarted = _onListeningStarted;
        _sttService.onListeningStopped = _onListeningStopped;
        _sttService.onError = _onSpeechError;
      }
      // หยุด TTS ก่อน (ถ้ากำลังพูดอยู่)
      if (_ttsService.isSpeaking) {
        await _ttsService.stop();
        setState(() => _speakingMessageIndex = null);
      }
      await _sttService.startListening();
    }
  }

  // ==================== CHAT FUNCTIONS ====================

  Future<void> _loadChatHistory() async {
    if (widget.user == null) {
      setState(() {
        _isLoading = false;
        _messages = [
          ChatMessage(
            text: 'สวัสดีครับ! ผมสมาร์ทเบรน AI ผู้เชี่ยวชาญด้านคลื่นสมองและสุขภาพจิต พร้อมให้คำแนะนำครับ 🧠\n\nคุณสามารถพิมพ์หรือ กดปุ่มไมค์เพื่อพูดกับผมได้เลยครับ 🎤',
            isBot: true,
            time: '09:00',
          ),
        ];
      });
      return;
    }

    final result = await ApiService.getChatHistory(widget.user!.id);
    
    if (result['success'] == true && result['messages'] != null) {
      setState(() {
        _messages = (result['messages'] as List).map((m) {
          return ChatMessage(
            text: m['message'],
            isBot: m['is_bot'] == true || m['is_bot'] == 1,
            time: m['sent_at']?.toString().substring(11, 16) ?? '',
          );
        }).toList();
        
        if (_messages.isEmpty) {
          _messages.add(ChatMessage(
            text: 'สวัสดีครับ! ผมสมาร์ทเบรน AI ผู้เชี่ยวชาญด้านคลื่นสมองและสุขภาพจิต พร้อมให้คำแนะนำครับ 🧠\n\nคุณสามารถพิมพ์หรือ กดปุ่มไมค์เพื่อพูดกับผมได้เลยครับ 🎤',
            isBot: true,
            time: TimeOfDay.now().format(context),
          ));
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _messages = [
          ChatMessage(
            text: 'สวัสดีครับ! ผมสมาร์ทเบรน AI ผู้เชี่ยวชาญด้านคลื่นสมองและสุขภาพจิต พร้อมให้คำแนะนำครับ 🧠\n\nคุณสามารถพิมพ์หรือ กดปุ่มไมค์เพื่อพูดกับผมได้เลยครับ 🎤',
            isBot: true,
            time: TimeOfDay.now().format(context),
          ),
        ];
      });
    }
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _speakMessage(int index) async {
    final message = _messages[index];
    
    if (_speakingMessageIndex == index && _ttsService.isSpeaking) {
      await _ttsService.stop();
      setState(() => _speakingMessageIndex = null);
    } else {
      await _ttsService.stop();
      setState(() => _speakingMessageIndex = index);
      await _ttsService.speak(message.text);
      if (mounted) setState(() => _speakingMessageIndex = null);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: messageText,
        isBot: false,
        time: TimeOfDay.now().format(context),
      ));
      _isSending = true;
    });
    
    _scrollToBottom();

    // เตรียม chat history สำหรับส่งไป API
    final chatHistory = _messages.map((m) => {
      'message': m.text,
      'is_bot': m.isBot,
    }).toList();

    if (widget.user != null) {
      // ใช้ ChatGPT API + บันทึกลง Supabase
      final result = await ApiService.sendChatGPTMessage(
        userId: widget.user!.id,
        message: messageText,
        chatHistory: chatHistory,
      );

      if (result['success'] == true && result['bot_response'] != null) {
        final botResponse = result['bot_response'];
        
        setState(() {
          _messages.add(ChatMessage(
            text: botResponse,
            isBot: true,
            time: TimeOfDay.now().format(context),
          ));
          _isSending = false;
        });
        _scrollToBottom();
        
        // Auto-speak ถ้าเปิดไว้ → bot จะพูดตอบกลับอัตโนมัติ
        if (_autoSpeak) {
          setState(() => _speakingMessageIndex = _messages.length - 1);
          await _ttsService.speak(botResponse);
          if (mounted) setState(() => _speakingMessageIndex = null);
        }
        return;
      }
    }

    // Fallback response
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      final fallbackResponse = _getLocalBotResponse(messageText);
      setState(() {
        _messages.add(ChatMessage(
          text: fallbackResponse,
          isBot: true,
          time: TimeOfDay.now().format(context),
        ));
        _isSending = false;
      });
      _scrollToBottom();
      
      if (_autoSpeak) {
        setState(() => _speakingMessageIndex = _messages.length - 1);
        await _ttsService.speak(fallbackResponse);
        if (mounted) setState(() => _speakingMessageIndex = null);
      }
    }
  }

  String _getLocalBotResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('alpha') || lowerMessage.contains('อัลฟา')) {
      return 'คลื่น Alpha (8-12 Hz) เป็นคลื่นแห่งการผ่อนคลายและตื่นตัวอย่างสงบครับ มักเกิดขึ้นเมื่อเราผ่อนคลายแต่ยังตื่นอยู่ครับ';
    }
    if (lowerMessage.contains('นอน') || lowerMessage.contains('หลับ')) {
      return 'สำหรับการนอนหลับที่ดี แนะนำให้เข้านอนเวลาเดียวกันทุกวัน หลีกเลี่ยงกาแฟหลังบ่าย และทำกิจกรรมผ่อนคลายก่อนนอนครับ';
    }
    if (lowerMessage.contains('เครียด') || lowerMessage.contains('กังวล')) {
      return 'เมื่อรู้สึกเครียด ลองหายใจลึกๆ ช้าๆ หรือทำสมาธิสั้นๆ 5 นาที การออกกำลังกายเบาๆ ก็ช่วยได้ครับ';
    }
    if (lowerMessage.contains('คลื่นสมอง') || lowerMessage.contains('brainwave')) {
      return 'คลื่นสมองมี 5 ประเภทหลัก: Delta (นอนหลับลึก), Theta (สมาธิลึก), Alpha (ผ่อนคลาย), Beta (ทำงาน), Gamma (สมาธิสูง) ครับ';
    }
    
    return 'ขอบคุณสำหรับคำถามครับ ผมพร้อมช่วยเรื่องคลื่นสมองและสุขภาพจิต ลองถามเกี่ยวกับ Alpha, Beta, Delta หรือเรื่องความเครียด การนอน สมาธิ ได้เลยครับ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context) ? IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ) : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.psychology, color: AppColors.primaryBlue, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'สมาร์ทเบรน AI',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _isVoiceMode ? '🎤 กำลังฟัง...' : 'ผู้เชี่ยวชาญคลื่นสมอง',
                  style: TextStyle(
                    color: _isVoiceMode ? Colors.red[400] : Colors.grey[500],
                    fontSize: 11,
                    fontWeight: _isVoiceMode ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Toggle Auto-Speak
          IconButton(
            onPressed: () {
              setState(() => _autoSpeak = !_autoSpeak);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        _autoSpeak ? Icons.volume_up : Icons.volume_off,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(_autoSpeak ? 'เปิดพูดอัตโนมัติ 🔊' : 'ปิดพูดอัตโนมัติ 🔇'),
                    ],
                  ),
                  duration: const Duration(seconds: 1),
                  backgroundColor: _autoSpeak ? Colors.green : Colors.grey,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            icon: Icon(
              _autoSpeak ? Icons.volume_up : Icons.volume_off,
              color: _autoSpeak ? Colors.green : Colors.grey,
            ),
          ),
          IconButton(
            onPressed: () {
              if (widget.user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsScreen(user: widget.user!)),
                );
              }
            },
            icon: Icon(Icons.settings, color: AppColors.primaryBlue),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message, index);
                    },
                  ),
                ),
                
                // Typing indicator
                if (_isSending)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(Icons.psychology, color: AppColors.primaryBlue, size: 14),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'สมาร์ทเบรน กำลังคิด...',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Voice listening overlay
                if (_isVoiceMode) _buildVoiceListeningBar(),
                
                const SizedBox(height: 8),
                
                // Input area
                _buildInputArea(),
              ],
            ),
    );
  }

  /// แถบแสดงสถานะกำลังฟังเสียง
  Widget _buildVoiceListeningBar() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.withValues(alpha: 0.1),
                Colors.orange.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              // Animated mic icon
              AnimatedBuilder(
                animation: _micPulseController,
                builder: (context, child) {
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(
                        alpha: 0.3 + (_micPulseController.value * 0.4),
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic, color: Colors.red, size: 20),
                  );
                },
              ),
              const SizedBox(width: 12),
              
              // Voice text or status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _partialText.isNotEmpty ? _partialText : 'กำลังฟัง... พูดได้เลย',
                      style: TextStyle(
                        color: _partialText.isNotEmpty ? Colors.black87 : Colors.grey[600],
                        fontSize: 14,
                        fontWeight: _partialText.isNotEmpty ? FontWeight.w500 : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_partialText.isEmpty)
                      Row(
                        children: List.generate(5, (i) => 
                          AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, child) {
                              final height = 4.0 + (8.0 * _waveController.value * (i % 2 == 0 ? 1 : 0.5));
                              return Container(
                                width: 3,
                                height: height,
                                margin: const EdgeInsets.only(right: 3, top: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Cancel button
              GestureDetector(
                onTap: () async {
                  await _sttService.cancelListening();
                  setState(() {
                    _isVoiceMode = false;
                    _partialText = '';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.red, size: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Input area ด้านล่าง
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mic button
          GestureDetector(
            onTap: _isSending ? null : _toggleVoiceInput,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isVoiceMode 
                    ? Colors.red 
                    : AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: _isVoiceMode ? [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: Icon(
                _isVoiceMode ? Icons.mic : Icons.mic_none,
                color: _isVoiceMode ? Colors.white : AppColors.primaryBlue,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Text input
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'พิมพ์หรือกดไมค์เพื่อพูด...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Send button
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isSending ? Colors.grey : AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isSpeaking = _speakingMessageIndex == index;
    
    return Align(
      alignment: message.isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: message.isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isBot
                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                    : AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: message.isBot ? const Radius.circular(4) : null,
                  bottomRight: message.isBot ? null : const Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isBot ? AppColors.textDark : Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                  ),
                ),
                // ปุ่ม Speaker สำหรับ bot messages
                if (message.isBot) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _speakMessage(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSpeaking 
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: isSpeaking 
                            ? Border.all(color: Colors.green.withValues(alpha: 0.5))
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSpeaking ? Icons.stop_circle : Icons.volume_up,
                            size: 16,
                            color: isSpeaking ? Colors.green : Colors.grey[500],
                          ),
                          if (isSpeaking) ...[
                            const SizedBox(width: 4),
                            Text(
                              'กำลังพูด',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isBot;
  final String time;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.time,
  });
}

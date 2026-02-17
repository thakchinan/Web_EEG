import 'package:flutter/material.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import '../../services/muse_service.dart';
import '../../services/api_service.dart';
import '../../services/supabase_service.dart';
import 'history_screen.dart';
import 'test_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MuseService _museService = MuseService();
  bool _isLoading = false;

  // ข้อมูลสุขภาพจริงจาก Supabase (Realtime)
  Map<String, dynamic>? _latestTestResult;
  Map<String, dynamic>? _latestBrainwave;
  bool _healthLoaded = false;

  // Realtime subscriptions
  StreamSubscription? _testResultSub;
  StreamSubscription? _brainwaveSub;

  @override
  void initState() {
    super.initState();
    _museService.addListener(_onMuseDataUpdate);
    _subscribeRealtime();
  }

  /// ✅ Supabase Realtime — stream ข้อมูลแบบ real-time
  void _subscribeRealtime() {
    final userId = widget.user.id;

    // 🧪 Stream ผลทดสอบ PHQ-9 (test_results)
    _testResultSub = SupabaseService.client
        .from('test_results')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('test_date', ascending: false)
        .limit(1)
        .listen((data) {
      if (!mounted) return;
      setState(() {
        _healthLoaded = true;
        if (data.isNotEmpty) {
          _latestTestResult = data.first;
          print('🔴 [Realtime] test_results updated: $_latestTestResult');
        }
      });
    }, onError: (e) {
      print('❌ [Realtime] test_results error: $e');
      // Fallback: โหลดแบบ one-shot
      _loadTestResultFallback();
    });

    // 🧠 Stream คลื่นสมอง (brainwave_data)
    _brainwaveSub = SupabaseService.client
        .from('brainwave_data')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('recorded_at', ascending: false)
        .limit(1)
        .listen((data) {
      if (!mounted) return;
      setState(() {
        _healthLoaded = true;
        if (data.isNotEmpty) {
          _latestBrainwave = data.first;
          print('🔴 [Realtime] brainwave_data updated: $_latestBrainwave');
        }
      });
    }, onError: (e) {
      print('❌ [Realtime] brainwave_data error: $e');
      _loadBrainwaveFallback();
    });
  }

  /// Fallback: ถ้า realtime ไม่ทำงาน ให้โหลดแบบเดิม
  Future<void> _loadTestResultFallback() async {
    try {
      final result = await ApiService.getTestResults(widget.user.id);
      if (!mounted) return;
      setState(() {
        _healthLoaded = true;
        if (result['success'] == true &&
            result['results'] != null &&
            (result['results'] as List).isNotEmpty) {
          _latestTestResult = (result['results'] as List).first;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _healthLoaded = true);
    }
  }

  Future<void> _loadBrainwaveFallback() async {
    try {
      final result = await ApiService.getBrainwaveData(widget.user.id);
      if (!mounted) return;
      setState(() {
        if (result['success'] == true &&
            result['data'] != null &&
            (result['data'] as List).isNotEmpty) {
          _latestBrainwave = (result['data'] as List).first;
        }
      });
    } catch (_) {}
  }

  /// โหลดข้อมูลใหม่จาก Supabase (เรียกเมื่อกลับจากหน้าทดสอบ/หน้าอื่น)
  Future<void> _reloadHealthData() async {
    try {
      final testResult = await ApiService.getTestResults(widget.user.id);
      final brainResult = await ApiService.getBrainwaveData(widget.user.id);

      if (!mounted) return;
      setState(() {
        if (testResult['success'] == true &&
            testResult['results'] != null &&
            (testResult['results'] as List).isNotEmpty) {
          _latestTestResult = (testResult['results'] as List).first;
          print('🔄 [Reload] test_results: $_latestTestResult');
        }
        if (brainResult['success'] == true &&
            brainResult['data'] != null &&
            (brainResult['data'] as List).isNotEmpty) {
          _latestBrainwave = (brainResult['data'] as List).first;
          print('🔄 [Reload] brainwave_data: $_latestBrainwave');
        }
      });
    } catch (e) {
      print('❌ [Reload] error: $e');
    }
  }

  @override
  void dispose() {
    // ยกเลิก Realtime subscriptions
    _testResultSub?.cancel();
    _brainwaveSub?.cancel();
    // ต้อง removeListener ก่อน! เพราะ stopSimulation() เรียก notifyListeners()
    _museService.removeListener(_onMuseDataUpdate);
    _museService.stopSimulation();
    _museService.dispose();
    super.dispose();
  }

  void _onMuseDataUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _scanAndConnect() async {
    setState(() => _isLoading = true);
    
    final isAvailable = await _museService.isBluetoothAvailable();
    
    if (!isAvailable) {
      // Show dialog to use simulation
      _showNoBluetoothDialog();
    } else {
      // Start scanning 
      await _museService.startScan();
      
      // Show device selection dialog
      if (mounted) {
        _showDeviceSelectionDialog();
      }
    }
    
    setState(() => _isLoading = false);
  }

  void _showNoBluetoothDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.bluetooth_disabled, color: Colors.orange),
            SizedBox(width: 8),
            Text('Bluetooth ไม่พร้อมใช้งาน'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ไม่สามารถใช้ Bluetooth บนแพลตฟอร์มนี้ได้'),
            SizedBox(height: 8),
            Text('คุณสามารถ:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• ใช้โหมดจำลองเพื่อทดสอบ'),
            Text('• รันแอปบน iOS/Android เพื่อเชื่อมต่อจริง'),
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
              _museService.startSimulation();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: const Text('ใช้โหมดจำลอง', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeviceSelectionDialog() {
    VoidCallback? modalListener;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          // Create listener and store it for cleanup
          modalListener ??= () {
            if (modalContext.mounted) setModalState(() {});
          };
          _museService.addListener(modalListener!);
          
          return Container(
            padding: const EdgeInsets.all(20),
            height: MediaQuery.of(modalContext).size.height * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bluetooth_searching, color: AppColors.primaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      'เลือกอุปกรณ์ Muse',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const Spacer(),
                    if (_museService.isScanning)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _museService.status,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                
                // Scan Results
                Expanded(
                  child: _museService.scanResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _museService.isScanning ? Icons.bluetooth_searching : Icons.bluetooth_disabled,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _museService.isScanning 
                                    ? 'กำลังค้นหาอุปกรณ์...'
                                    : 'ไม่พบอุปกรณ์ Muse',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              if (!_museService.isScanning) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'ตรวจสอบว่า Muse S เปิดอยู่และอยู่ใกล้ๆ',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _museService.scanResults.length,
                          itemBuilder: (modalContext, index) {
                            final result = _museService.scanResults[index];
                            final device = result.device;
                            final rssi = result.rssi;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                                  child: Icon(Icons.bluetooth, color: AppColors.primaryBlue),
                                ),
                                title: Text(
                                  device.platformName.isNotEmpty 
                                      ? device.platformName 
                                      : 'Unknown Device',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  'สัญญาณ: $rssi dBm',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: _museService.isConnecting
                                      ? null
                                      : () async {
                                          Navigator.pop(modalContext);
                                          await _museService.connectToDevice(device);
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  child: Text(
                                    _museService.isConnecting ? 'กำลังเชื่อมต่อ...' : 'เชื่อมต่อ',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _museService.isScanning
                            ? () => _museService.stopScan()
                            : () => _museService.startScan(),
                        icon: Icon(
                          _museService.isScanning ? Icons.stop : Icons.refresh,
                          color: AppColors.primaryBlue,
                        ),
                        label: Text(
                          _museService.isScanning ? 'หยุดค้นหา' : 'ค้นหาใหม่',
                          style: TextStyle(color: AppColors.primaryBlue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(modalContext);
                          _museService.startSimulation();
                        },
                        icon: const Icon(Icons.play_arrow, color: Colors.orange),
                        label: const Text('โหมดจำลอง', style: TextStyle(color: Colors.orange)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() {
      // Clean up listener when modal closes
      if (modalListener != null) {
        _museService.removeListener(modalListener!);
      }
    });
  }

  Future<void> _disconnectMuse() async {
    await _museService.disconnect();
  }

  Future<void> _saveBrainwaveData() async {
    if (_museService.latestData == null) return;
    
    final data = _museService.latestData!;
    final result = await ApiService.saveMuseBrainwave(
      userId: widget.user.id,
      alphaWave: data.alpha,
      betaWave: data.beta,
      thetaWave: data.theta,
      deltaWave: data.delta,
      gammaWave: data.gamma,
      attentionScore: data.attention,
      meditationScore: data.meditation,
      deviceName: _museService.deviceName ?? 'Muse S',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success'] == true ? 'บันทึกข้อมูลสำเร็จ' : 'ไม่สามารถบันทึกได้'),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.apps, color: AppColors.primaryBlue, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('สวัสดี!', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      Text(
                        widget.user.fullName ?? widget.user.username,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(user: widget.user)));
                    },
                    icon: Icon(Icons.settings, color: AppColors.primaryBlue),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Muse S Connection Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _museService.isConnected
                        ? [Colors.green.shade100, Colors.green.shade50]
                        : [AppColors.primaryBlue.withOpacity(0.1), AppColors.primaryBlue.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _museService.isConnected
                        ? Colors.green.withOpacity(0.3)
                        : AppColors.primaryBlue.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _museService.isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                          color: _museService.isConnected ? Colors.green : AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Muse S Headband',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _museService.isConnected ? Colors.green.shade700 : AppColors.primaryBlue,
                          ),
                        ),
                        const Spacer(),
                        if (_museService.isConnected)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 8, spreadRadius: 2),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_museService.status, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    if (_museService.deviceName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.devices, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text('${_museService.deviceName}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading || _museService.isConnecting
                                ? null
                                : (_museService.isConnected ? _disconnectMuse : _scanAndConnect),
                            icon: _isLoading || _museService.isConnecting
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Icon(
                                    _museService.isConnected ? Icons.bluetooth_disabled : Icons.bluetooth_searching,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              _museService.isConnecting 
                                  ? 'กำลังเชื่อมต่อ...' 
                                  : (_museService.isConnected ? 'ยกเลิกเชื่อมต่อ' : 'เชื่อมต่อ Muse S'),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _museService.isConnected ? Colors.red : AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        if (_museService.isConnected && _museService.latestData != null) ...[
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _saveBrainwaveData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('บันทึก', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Brainwave Data Card
              if (_museService.isConnected && _museService.latestData != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.psychology, color: AppColors.primaryBlue, size: 20),
                          const SizedBox(width: 8),
                          Text('คลื่นสมอง (EEG)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                          const Spacer(),
                          if (_museService.isSimulating)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                              child: const Text('จำลอง', style: TextStyle(fontSize: 10, color: Colors.orange)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildWaveRow('Delta (0.5-4 Hz)', _museService.latestData!.delta, Colors.purple, 'การนอนหลับลึก'),
                      _buildWaveRow('Theta (4-8 Hz)', _museService.latestData!.theta, Colors.green, 'ผ่อนคลาย/สมาธิ'),
                      _buildWaveRow('Alpha (8-12 Hz)', _museService.latestData!.alpha, Colors.blue, 'ตื่นตัว ผ่อนคลาย'),
                      _buildWaveRow('Beta (12-30 Hz)', _museService.latestData!.beta, Colors.orange, 'คิดวิเคราะห์'),
                      _buildWaveRow('Gamma (30+ Hz)', _museService.latestData!.gamma, Colors.red, 'สมาธิสูง'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Brain Health Summary (ดึงข้อมูลจริงจาก Supabase)
              _buildHealthSummaryCard(),

              const SizedBox(height: 20),

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(context, icon: Icons.history, label: 'ประวัติ', onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(user: widget.user)));
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(context, icon: Icons.quiz_outlined, label: 'แบบทดสอบ', onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TestScreen(user: widget.user)),
                      ).then((_) {
                        // โหลดข้อมูลใหม่ทันทีเมื่อกลับจากหน้าทดสอบ
                        _reloadHealthData();
                      });
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaveRow(String name, double value, Color color, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(name, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value / 100,
                    backgroundColor: color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text('${value.round()}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.right),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 120),
            child: Text(desc, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text('$value%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // ==================== HEALTH SUMMARY (ข้อมูลจริงจาก Supabase) ====================

  /// แปลง stress_level จาก DB เป็นข้อมูลแสดงผล
  Map<String, dynamic> _getStressDisplay(String? stressLevel, int? score) {
    switch (stressLevel) {
      case 'normal':
        return {'label': 'ปกติ', 'emoji': '😊', 'color': const Color(0xFF4CAF50)};
      case 'mild':
        return {'label': 'ซึมเศร้าเล็กน้อย', 'emoji': '😐', 'color': const Color(0xFFFFC107)};
      case 'moderate':
        return {'label': 'ซึมเศร้าปานกลาง', 'emoji': '😟', 'color': const Color(0xFFFF9800)};
      case 'high':
        return {'label': 'ค่อนข้างรุนแรง', 'emoji': '😰', 'color': const Color(0xFFFF5722)};
      case 'severe':
        return {'label': 'รุนแรง', 'emoji': '🆘', 'color': const Color(0xFFF44336)};
      default:
        return {'label': 'ยังไม่ได้ทดสอบ', 'emoji': '❓', 'color': Colors.grey};
    }
  }

  Widget _buildHealthSummaryCard() {
    final stressLevel = _latestTestResult?['stress_level'];
    final stressScore = _latestTestResult?['stress_score'] as int?;
    final depressionScore = _latestTestResult?['depression_score'] as int?;
    final display = _getStressDisplay(stressLevel, stressScore);
    final Color statusColor = display['color'];

    // ข้อมูลคลื่นสมอง
    final alpha = (_latestBrainwave?['alpha_wave'] as num?)?.toDouble();
    final beta = (_latestBrainwave?['beta_wave'] as num?)?.toDouble();
    final attention = (_latestBrainwave?['attention_score'] as num?)?.toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.08), statusColor.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_graph, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text('สรุปสุขภาพสมอง', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor)),
              const Spacer(),
              if (!_healthLoaded)
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 8),

          // สถานะจากผล PHQ-9 จริง
          if (_latestTestResult != null) ...[
            Row(
              children: [
                Text(display['emoji'], style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        display['label'],
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: statusColor),
                      ),
                      Text(
                        'PHQ-9: ${stressScore ?? depressionScore ?? '-'}/27 คะแนน',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // วันที่ทดสอบ
            if (_latestTestResult?['test_date'] != null)
              Text(
                'ทดสอบล่าสุด: ${_formatDate(_latestTestResult!['test_date'])}',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
          ] else ...[
            Row(
              children: [
                const Text('❓', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ยังไม่ได้ทดสอบ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    Text('ทำแบบทดสอบ PHQ-9 เพื่อประเมินผล', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ],

        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildStatCard({required IconData icon, required String label, required Color iconColor, String? value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700]), overflow: TextOverflow.ellipsis),
                  if (value != null)
                    Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: iconColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryBlue)),
          ],
        ),
      ),
    );
  }
}

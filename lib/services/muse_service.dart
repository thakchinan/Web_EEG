import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'fft_calculator.dart';

/// Muse S Brainwave Data
class BrainwaveData {
  final double alpha;
  final double beta;
  final double theta;
  final double delta;
  final double gamma;
  final double attention;
  final double meditation;
  final DateTime timestamp;

  BrainwaveData({
    required this.alpha,
    required this.beta,
    required this.theta,
    required this.delta,
    required this.gamma,
    this.attention = 0,
    this.meditation = 0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'alpha': alpha,
    'beta': beta,
    'theta': theta,
    'delta': delta,
    'gamma': gamma,
    'attention': attention,
    'meditation': meditation,
  };
}

/// Muse S Bluetooth Service (Clean & Robust V3)
class MuseService extends ChangeNotifier {
  BluetoothDevice? _connectedDevice;
  List<ScanResult> _scanResults = [];
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  final List<StreamSubscription> _dataSubscriptions = [];
  
  bool _isScanning = false;
  bool _isConnected = false;
  bool _isConnecting = false;
  String _status = 'ไม่ได้เชื่อมต่อ';
  String? _deviceName;
  
  BrainwaveData? _latestData;
  final List<BrainwaveData> _dataHistory = [];
  
  // Floating buffers for FFT
  final int _windowSize = 256;
  final List<double> _tp9Window = [];
  final List<double> _af7Window = [];
  final List<double> _af8Window = [];
  final List<double> _tp10Window = [];

  // Simulated data
  Timer? _simulationTimer;
  bool _isSimulating = false;
  bool _isDisposed = false;

  // Getters
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  bool get isSimulating => _isSimulating;
  String get status => _status;
  String? get deviceName => _deviceName;
  BrainwaveData? get latestData => _latestData;
  List<BrainwaveData> get dataHistory => _dataHistory;
  List<ScanResult> get scanResults => _scanResults;

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  /// Check availability
  Future<bool> isBluetoothAvailable() async {
    if (kIsWeb) return false;
    try {
      return await FlutterBluePlus.isSupported;
    } catch (e) {
      return false;
    }
  }

  /// Start scanning
  Future<void> startScan() async {
    if (_isScanning) return;
    if (kIsWeb) return;

    try {
      // 1. Permissions Check
    if (!await _checkPermissions()) {
      _status = 'ต้องการสิทธิ์ Bluetooth/Location';
      _safeNotify();
      return;
    }

      if (!await FlutterBluePlus.isSupported) return;

      // Ensure Bluetooth is On
      if (Platform.isAndroid) {
         try { await FlutterBluePlus.turnOn(); } catch (e) {}
      }

      _isScanning = true;
      _scanResults = [];
  _status = 'กำลังค้นหาอุปกรณ์ Muse...';
  _safeNotify();

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        _scanResults = results.where((r) {
          final name = r.device.platformName.toLowerCase();
          return name.contains('muse') || name.contains('headband');
        }).toList();

        if (_scanResults.isNotEmpty) {
          _status = 'พบอุปกรณ์ ${_scanResults.length} เครื่อง';
        }
        _safeNotify();
      });

      FlutterBluePlus.isScanning.where((val) => val == false).first.then((_) {
        _isScanning = false;
        if (_scanResults.isEmpty && !_isConnected) {
          _status = 'ไม่พบอุปกรณ์ - ลองใหม่';
        }
        _safeNotify();
      });

    } catch (e) {
      _isScanning = false;
      _status = 'Error: $e';
      _safeNotify();
    }
  }

  /// Stop scanning
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    _isScanning = false;
    _safeNotify();
  }

  Timer? _dataWatchdog;
  bool _dataReceivedRecently = false;
  List<BluetoothCharacteristic> _writableChars = [];

  /// Connect
  Future<void> connectToDevice(BluetoothDevice device) async {
    await stopScan();
    
    try {
  _isConnecting = true;
  _status = 'เชื่อมต่อ ${device.platformName}...';
  _safeNotify();

      if (Platform.isAndroid) {
          try { await device.clearGattCache(); } catch (e) {}
      }

      await device.connect(timeout: const Duration(seconds: 20), autoConnect: false);
      
  _connectedDevice = device;
  _deviceName = device.platformName;
  _isConnected = true;
  _isConnecting = false;
  _status = 'เชื่อมต่อแล้ว (รอ Set up)...';
  _safeNotify();

      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          disconnect();
        }
      });

      await Future.delayed(const Duration(seconds: 1)); // Stability waiting
      await _setupMuseConnection();

    } catch (e) {
      _isConnecting = false;
      _isConnected = false;
      _status = 'เชื่อมต่อล้มเหลว: $e';
      _safeNotify();
    }
  }

  /// Setup logic (Universal Listener)
  Future<void> _setupMuseConnection() async {
    if (_connectedDevice == null) return;

    try {
  _status = 'Discovering Services...';
  _safeNotify();

      List<BluetoothService> services = await _connectedDevice!.discoverServices();
      
      // Request MTU
      try { if (Platform.isAndroid) await _connectedDevice!.requestMtu(512); } catch (e) {}

      List<BluetoothCharacteristic> eegChars = [];
      List<BluetoothCharacteristic> allNotifyChars = [];
      _writableChars = [];

      for (var service in services) {
        for (var c in service.characteristics) {
           final uuid = c.uuid.toString().toLowerCase();
           
           if (c.properties.notify) {
              allNotifyChars.add(c);
              // Standard EEG check
              if (uuid.contains('273e0003') || uuid.contains('273e0004') || 
                  uuid.contains('273e0005') || uuid.contains('273e0006')) {
                 eegChars.add(c);
              }
           }
           
           if (c.properties.write || c.properties.writeWithoutResponse) {
              _writableChars.add(c);
           }
        }
      }

      // Universal Fallback: Use all notify chars if no specific EEG chars found
      if (eegChars.isEmpty) {
         eegChars = allNotifyChars;
      }

    if (eegChars.isEmpty) {
      _status = 'Error: ไม่พบช่องสัญญาณ (Notify=0)';
      _safeNotify();
      // But keep trying to write commands just in case
    } else {
      _status = 'Found ${eegChars.length} Channels. Subscribing...';
      _safeNotify();
    }

      // Subscribe to all
      int subs = 0;
      for (var c in eegChars) {
         try {
            await c.setNotifyValue(true);
            var sub = c.lastValueStream.listen((value) {
                _processEEGData(c.uuid.toString(), value);
            });
            _dataSubscriptions.add(sub); // Use the REAL subscription
            subs++;
            await Future.delayed(const Duration(milliseconds: 50)); 
         } catch (e) {}
      }
      
  _status = 'Ready (Subs:$subs). Sending Start...';
  _safeNotify();

      // Initial Command Burst
      for (var char in _writableChars) {
          _sendStartCommands(char);
          await Future.delayed(const Duration(milliseconds: 50));
      }
      
      // Start Watchdog
      _dataWatchdog?.cancel();
      _dataWatchdog = Timer.periodic(const Duration(seconds: 2), (t) {
          if (!_isConnected) { t.cancel(); return; }
          
          if (!_dataReceivedRecently) {
             _status = 'กำลังปลุก... (Wakeup ${t.tick})';
             _safeNotify();
             for (var char in _writableChars) {
                _sendStartCommands(char);
             }
          } else {
             _dataReceivedRecently = false; // Reset for next check
          }
      });

    } catch (e) {
      _status = 'Setup Error: $e';
      _safeNotify();
    }
  }

  Future<void> _sendStartCommands(BluetoothCharacteristic c) async {
     // Try all formats
     await _writeRaw(c, [0x02, 0x64, 0x0a]); // Keep Alive 'd'
     await _writeRaw(c, [0x02, 0x73, 0x0a]); // 's' (V2)
     await _writeRaw(c, [0x73, 0x0a]);       // 's\n'
     await _writeRaw(c, [0x73, 0x0d]);       // 's\r'
     await _writeRaw(c, [0x70, 0x32, 0x31, 0x0a]); // 'p21'
  }

  Future<void> _writeRaw(BluetoothCharacteristic c, List<int> cmd) async {
    try { await c.write(cmd, withoutResponse: true); } catch (e) {} 
    // Prefer withoutResponse for speed/compatibility
  }

  void _processEEGData(String uuid, List<int> rawData) {
     if (rawData.isEmpty) return;
     _dataReceivedRecently = true;
     _status = 'รับข้อมูล... (${rawData.length} bytes)';

     try {
       List<double> samples = _parseMuseEEGPacket(rawData);
       
       // Add to Window (Simple Round Robin or Mapping)
       // If universal, map by order or hash? Let's just fill RR for now to get graph moving
       if (_tp9Window.length < _windowSize) _addToWindow(_tp9Window, samples);
       else if (_af7Window.length < _windowSize) _addToWindow(_af7Window, samples);
       else if (_af8Window.length < _windowSize) _addToWindow(_af8Window, samples);
       else _addToWindow(_tp10Window, samples); // Overflow to last

       // Just calculate!
       if (_tp9Window.isNotEmpty) _calculateFFT();

     } catch (e) {}
  }

  void _addToWindow(List<double> window, List<double> newSamples) {
    window.addAll(newSamples);
    if (window.length > _windowSize) window.removeRange(0, window.length - _windowSize);
  }

  List<double> _parseMuseEEGPacket(List<int> rawData) {
    List<double> samples = [];
    if (rawData.length >= 6) { // At least header + 1 sample
      for (int i = 2; i < rawData.length - 1; i += 2) {
         int s = (rawData[i] << 8) | rawData[i+1];
         samples.add( (s / 65535.0) * 1682.0 );
      }
    }
    return samples;
  }

  void _calculateFFT() {
     // Helper
     Map<String, double> getPower(List<double> buf) {
        if (buf.isEmpty) return {};
        List<double> p = List.from(buf);
        if (p.length < _windowSize) p.addAll(List.filled(_windowSize - p.length, 0.0));
        try {
           var mags = FFTCalculator.computeMagnitudes(p);
           return FFTCalculator.calculateBandPowers(mags, 256);
        } catch (e) { return {}; }
     }

     var p1 = getPower(_tp9Window);
     var p2 = getPower(_tp10Window); // Use two valid windows for now
     
     if (p1.isEmpty && p2.isEmpty) return;
     
     double totalAlpha = (p1['alpha'] ?? 0) + (p2['alpha'] ?? 0);
     double totalBeta = (p1['beta'] ?? 0) + (p2['beta'] ?? 0);
     double totalTheta = (p1['theta'] ?? 0) + (p2['theta'] ?? 0);
     double totalDelta = (p1['delta'] ?? 0) + (p2['delta'] ?? 0);
     double totalGamma = (p1['gamma'] ?? 0) + (p2['gamma'] ?? 0);
     
     double sum = totalAlpha + totalBeta + totalTheta + totalDelta + totalGamma;
     if (sum == 0) sum = 1;

     _latestData = BrainwaveData(
        alpha: (totalAlpha/sum)*100,
        beta: (totalBeta/sum)*100,
        theta: (totalTheta/sum)*100,
        delta: (totalDelta/sum)*100,
        gamma: (totalGamma/sum)*100,
        attention: 50, // Dummy for stability first
        meditation: 50
     );
     
     _dataHistory.add(_latestData!);
     if (_dataHistory.length > 100) _dataHistory.removeAt(0);
    _safeNotify();
  }

  Future<void> disconnect() async {
    _dataWatchdog?.cancel();
    _scanSubscription?.cancel();
    stopSimulation();
    try { await _connectedDevice?.disconnect(); } catch (e) {}
    _isConnected = false;
    _connectedDevice = null;
    _status = 'ไม่ได้เชื่อมต่อ';
    _safeNotify();
  }

  void startSimulation() {
     if(_isSimulating) return;
     _isSimulating = true;
     _isConnected = true;
     _status = 'Simulation Mode';
     _safeNotify();
     _simulationTimer = Timer.periodic(const Duration(milliseconds: 500), (t) {
         _latestData = BrainwaveData(alpha: Random().nextDouble()*100, beta: Random().nextDouble()*100, theta: 20, delta: 10, gamma: 5);
         _safeNotify();
     });
  }

  void stopSimulation() {
     _simulationTimer?.cancel();
     _isSimulating = false;
     if(_deviceName == null) _isConnected = false;
     _safeNotify();
  }
  
  @override
  void dispose() {
    // mark disposed so any async callbacks won't call notifyListeners
    _isDisposed = true;
    // best-effort cleanup
    _dataWatchdog?.cancel();
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    for (var s in _dataSubscriptions) {
      try { s.cancel(); } catch (e) {}
    }
    _dataSubscriptions.clear();
    _simulationTimer?.cancel();
    try { _connectedDevice?.disconnect(); } catch (e) {}
    super.dispose();
  }

  Future<bool> _checkPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.bluetoothScan.request().isGranted &&
          await Permission.bluetoothConnect.request().isGranted &&
          await Permission.location.request().isGranted) {
            return true;
      }
      return false;
    }
    return true;
  }
}

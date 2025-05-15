import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';

class NavigateScreen extends StatefulWidget {
  const NavigateScreen({super.key});

  @override
  State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen> {
  BluetoothConnection? connection;
  bool isConnected = false;

  // 목표·허용 오차
  final double targetX = 2.43;
  final double targetY = -0.28;
  final double tolerance = 1;

  // 현재 좌표
  double? currentX, currentY, currentZ;

  // 음성·플래그
  final FlutterTts tts = FlutterTts();
  bool instructionGiven = false;
  bool arrivedNotified = false;
  bool obstacleNotified = false;
  bool cornerNotified = false;

  // 장애물·코너
  final double obstacleX = 1.0, obstacleY = -0.5, obstacleRange = 0.5;
  final List<Map<String, double>> cornerPositions = [
    {'x': 0.0, 'y': 0.0},
    {'x': 0.0, 'y': -2.0},
    {'x': 4.0, 'y': 0.0},
    {'x': 4.0, 'y': -2.0},
  ];
  final double cornerRange = 0.5;

  // 작품 ID (이전 / 현재)
  final int lastSeenArtworkId = 0;
  final int currentArtworkId = 1;

  // Bluetooth 수신 버퍼
  String _buffer = '';

  @override
  void initState() {
    super.initState();
    _initTts();
    connectToHC06();
  }

  Future<void> _initTts() async {
    await tts.setLanguage('ko-KR');
    await tts.setSpeechRate(0.4);
  }

  /* ------------------------------------------------------------------ */
  /* 1. HC-06 연결                                                      */
  /* ------------------------------------------------------------------ */
  Future<void> connectToHC06() async {
    try {
      final bonded = await FlutterBluetoothSerial.instance.getBondedDevices();
      final device = bonded.firstWhere((d) => d.name?.contains('HC') ?? false);

      connection = await BluetoothConnection.toAddress(device.address);
      setState(() => isConnected = true);

      _startListen(); // ★ 스트림 구독 시작
    } catch (e) {
      debugPrint('연결 실패: $e');
    }
  }

  /* ------------------------------------------------------------------ */
  /* 2. 스트림 버퍼링 → 줄 단위 파싱                                    */
  /* ------------------------------------------------------------------ */
  void _startListen() {
    connection!.input!
        .cast<List<int>>()       // Uint8List → List<int>
        .transform(utf8.decoder) // 바이트 → 문자열
        .listen((chunk) {
      _buffer += chunk;         // 누적

      int idx;
      while ((idx = _buffer.indexOf('\n')) != -1) {
        final line = _buffer.substring(0, idx).trim();
        _buffer = _buffer.substring(idx + 1);

        if (line.contains('Position')) {
          final pos = _parsePosition(line);
          if (pos != null) _updatePosition(pos);
        }
      }
    }, onDone: () {
      setState(() => isConnected = false);
    });
  }

  /* ------------------------------------------------------------------ */
  /* 3. “Position …” 문자열 → 좌표 Map                                   */
  /* ------------------------------------------------------------------ */
  Map<String, double>? _parsePosition(String line) {
    // 예) “Position:1.14,-0.25,2.00”
    final reg = RegExp(r'[-+]?\d+(\.\d+)?');
    final nums = reg.allMatches(line).map((m) => m.group(0)!).toList();
    if (nums.length < 2) return null; // x·y 최소
    return {
      'x': double.parse(nums[0]),
      'y': double.parse(nums[1]),
      'z': nums.length > 2 ? double.parse(nums[2]) : 0,
    };
  }

  /* ------------------------------------------------------------------ */
  /* 4. 좌표 갱신 + 안내 로직                                           */
  /* ------------------------------------------------------------------ */
  void _updatePosition(Map<String, double> pos) {
    setState(() {
      currentX = pos['x'];
      currentY = pos['y'];
      currentZ = pos['z'];
    });

    // 도착 여부
    if (!arrivedNotified &&
        (pos['x']! - targetX).abs() < tolerance &&
        (pos['y']! - targetY).abs() < tolerance) {
      _vibrate();
      arrivedNotified = true;
      tts.speak('도착했습니다. 작품 해설 듣기 버튼을 눌러주세요.');
    }

    // 장애물
    if (!obstacleNotified &&
        (pos['x']! - obstacleX).abs() < obstacleRange &&
        (pos['y']! - obstacleY).abs() < obstacleRange) {
      obstacleNotified = true;
      tts.speak('장애물 근처입니다. 주의하세요.');
    }

    // 코너
    if (!cornerNotified) {
      for (final c in cornerPositions) {
        if ((pos['x']! - c['x']!).abs() < cornerRange &&
            (pos['y']! - c['y']!).abs() < cornerRange) {
          cornerNotified = true;
          tts.speak('코너에 접근했습니다. 주의해서 이동하세요.');
          break;
        }
      }
    }
  }

  /* ------------------------------------------------------------------ */
  /* 5. 유틸 함수                                                       */
  /* ------------------------------------------------------------------ */
  void _vibrate() async {
    if (await Vibration.hasVibrator() ?? false) Vibration.vibrate();
  }

  void _onDoubleTap() {
    if (instructionGiven) return;

    final guide = (lastSeenArtworkId < currentArtworkId)
        ? '오른쪽으로 이동하세요. 벽에 왼손을 대고 따라가세요.'
        : '왼쪽으로 이동하세요. 벽에 오른손을 대고 따라가세요.';
    tts.speak(guide);
    setState(() => instructionGiven = true);
  }

  @override
  void dispose() {
    tts.stop();
    connection?.dispose();
    super.dispose();
  }

  /* ------------------------------------------------------------------ */
  /* 6. UI                                                              */
  /* ------------------------------------------------------------------ */
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('작품 길찾기'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Text(
                  currentX != null
                      ? '현재 좌표  x:${currentX!.toStringAsFixed(2)}  '
                        'y:${currentY!.toStringAsFixed(2)}  '
                        'z:${currentZ!.toStringAsFixed(2)}'
                      : isConnected
                          ? '좌표 수신 대기 중...'
                          : '블루투스 연결 중...',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/explanation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD600),
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('작품 해설 듣기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

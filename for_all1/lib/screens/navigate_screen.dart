import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:provider/provider.dart';
import '../providers/tour_state.dart';

class NavigateScreen extends StatefulWidget {
  const NavigateScreen({super.key});

  @override
  State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen> {
  BluetoothConnection? connection;
  StreamSubscription<String>? _subscription;
  bool isConnected = false;

  // 목표·허용 오차
  late double targetX;
  late double targetY;
  final double tolerance = 0.5;

  // 현재 좌표
  double? currentX, currentY, currentZ;

  // 음성·플래그
  final FlutterTts tts = FlutterTts();
  bool instructionGiven = false;
  bool arrivedNotified = false;
  bool obstacleNotified = false;
  bool cornerNotified = false;
  bool needsOriginReset = false;
  bool hasValidPosition = false;

  // 장애물·코너
  final double obstacleX = 1.0, obstacleY = -0.5, obstacleRange = 0.5;
  final List<Map<String, double>> cornerPositions = [
    {'x': 0.0, 'y': 0.0},
    {'x': 0.0, 'y': -2.0},
    {'x': 4.0, 'y': 0.0},
    {'x': 4.0, 'y': -2.0},
  ];
  final double cornerRange = 0.5;

  final int lastSeenArtworkId = 0;
  final int currentArtworkId = 1;

  String _buffer = '';

  @override
  void initState() {
    super.initState();

    // 플래그 초기화
    instructionGiven = false;
    arrivedNotified = false;
    obstacleNotified = false;
    cornerNotified = false;
    needsOriginReset = false;
    hasValidPosition = false;
    currentX = null;
    currentY = null;
    currentZ = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tourState = Provider.of<TourState>(context, listen: false);
      final artwork = tourState.artworks[tourState.currentArtworkIndex];
      targetX = artwork.x;
      targetY = artwork.y;

      _initTts();
      if (connection != null) {
        connection!.dispose();
        connection = null;
      }
      connectToHC06();
    });
  }

  Future<void> _initTts() async {
    await tts.setLanguage('ko-KR');
    await tts.setSpeechRate(0.4);
    await tts.awaitSpeakCompletion(true);
  }

  Future<void> connectToHC06() async {
    try {
      final bonded = await FlutterBluetoothSerial.instance.getBondedDevices();
      final device = bonded.firstWhere((d) => d.name?.contains('HC') ?? false);

      connection = await BluetoothConnection.toAddress(device.address);
      setState(() => isConnected = true);

      _speakInitialDirection();

      _startListen();
    } catch (e) {
      debugPrint('연결 실패: $e');
    }
  }

  void _startListen() {
    _subscription = connection!.input!
        .cast<List<int>>()
        .transform(utf8.decoder)
        .listen((chunk) {
      _buffer += chunk;

      int idx;
      while ((idx = _buffer.indexOf('\n')) != -1) {
        final line = _buffer.substring(0, idx).trim();
        _buffer = _buffer.substring(idx + 1);

        if (line.toLowerCase().contains('outlier ignored') && !hasValidPosition) {
          setState(() => needsOriginReset = true);
          debugPrint('초기화 필요!!! invalid!!!!');
        }

        if (line.toLowerCase().contains('position')) {
          final pos = _parsePosition(line);
          if (pos != null) {
            hasValidPosition = true;
            setState(() => needsOriginReset = false);
            _updatePosition(pos);
          }
        }
      }
    }, onDone: () {
      setState(() => isConnected = false);
    }, onError: (e) {
      debugPrint('스트림 에러: $e');
    });
  }

  Map<String, double>? _parsePosition(String line) {
    final reg = RegExp(r'[-+]?\d+(\.\d+)?');
    final nums = reg.allMatches(line).map((m) => m.group(0)!).toList();
    if (nums.length < 2) return null;
    return {
      'x': double.parse(nums[0]),
      'y': double.parse(nums[1]),
      'z': nums.length > 2 ? double.parse(nums[2]) : 0,
    };
  }

  void _updatePosition(Map<String, double> pos) {
    final x = pos['x']!;
    final y = pos['y']!;
    final z = pos['z']!;

    bool newlyArrived = !arrivedNotified &&
        (x - targetX).abs() < tolerance &&
        (y - targetY).abs() < tolerance;

    bool newlyObstacle = !obstacleNotified &&
        (x - obstacleX).abs() < obstacleRange &&
        (y - obstacleY).abs() < obstacleRange;

    bool newlyCorner = false;
    for (final c in cornerPositions) {
      if ((x - c['x']!).abs() < cornerRange &&
          (y - c['y']!).abs() < cornerRange) {
        newlyCorner = true;
        break;
      }
    }

    setState(() {
      currentX = x;
      currentY = y;
      currentZ = z;
      hasValidPosition = true;
      needsOriginReset = false;

      if (newlyArrived) arrivedNotified = true;
      if (newlyObstacle) obstacleNotified = true;
      if (newlyCorner) cornerNotified = true;
    });

    debugPrint('📍 현재 위치: x=$x, y=$y');
    debugPrint('🎯 목표 위치: x=$targetX, y=$targetY');

    if (newlyArrived) {
      _vibrate();
      tts.speak('도착했습니다. 작품 해설 듣기 버튼을 눌러주세요.');
    }

    if (newlyObstacle) {
      tts.speak('장애물 근처입니다. 주의하세요.');
    }

    if (newlyCorner) {
      tts.speak('코너에 접근했습니다. 주의해서 이동하세요.');
    }
  }

  void _vibrate() async {
    if (await Vibration.hasVibrator() ?? false) Vibration.vibrate();
  }

  void _speakInitialDirection() {
    if (instructionGiven) return;

    final guide = (lastSeenArtworkId < currentArtworkId)
        ? '오른쪽으로 이동하세요. 벽에 왼손을 대고 따라가세요.'
        : '왼쪽으로 이동하세요. 벽에 오른손을 대고 따라가세요.';
    tts.speak(guide);
    instructionGiven = true;
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
    debugPrint('[dispose] 스트림 중단 및 리소스 해제');
    _subscription?.cancel();
    _subscription = null;

    connection?.dispose();
    connection = null;

    tts.stop();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: ExcludeSemantics(
            child: Text('작품 길찾기'),
          ),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
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
                  if (needsOriginReset) const SizedBox(height: 12),
                  if (needsOriginReset)
                    const Text(
                      '⚠️ 원점 위치 초기화 필요',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: () {
                    _subscription?.cancel();
                    _subscription = null;
                    connection?.dispose();
                    connection = null;

                    Navigator.pushNamed(context, '/explanation');
                  },

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

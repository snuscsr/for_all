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

  final double targetX = 2.43;
  final double targetY = -0.28;
  final double tolerance = 0.2;

  double? currentX;
  double? currentY;
  double? currentZ;

  final FlutterTts tts = FlutterTts();
  bool instructionGiven = false;
  bool arrivedNotified = false;
  bool obstacleNotified = false;

  final double obstacleX = 1.0;
  final double obstacleY = -0.5;
  final double obstacleRange = 0.5;

  final int lastSeenArtworkId = 0;
  final int currentArtworkId = 1;

  @override
  void initState() {
    super.initState();
    connectToHC06();
    tts.setLanguage("ko-KR");
    tts.setSpeechRate(0.4); // Natural speed on Android
  }

  Future<void> connectToHC06() async {
    try {
      List<BluetoothDevice> bondedDevices =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      final device =
          bondedDevices.firstWhere((d) => d.name?.contains("HC") ?? false);
      connection = await BluetoothConnection.toAddress(device.address);
      setState(() => isConnected = true);

      connection!.input!.listen((data) {
        final line = utf8.decode(data).trim();
        if (line.contains("Position:")) {
          final pos = parsePosition(line);
          if (pos != null) {
            setState(() {
              currentX = pos['x'];
              currentY = pos['y'];
              currentZ = pos['z'];
            });

            final dx = (pos['x']! - targetX).abs();
            final dy = (pos['y']! - targetY).abs();

            if (!arrivedNotified && dx < tolerance && dy < tolerance) {
              triggerVibration();
              arrivedNotified = true;
              tts.speak("도착했습니다. 작품 해설 듣기 버튼을 눌러주세요.");
            }

            final obsDx = (pos['x']! - obstacleX).abs();
            final obsDy = (pos['y']! - obstacleY).abs();
            if (!obstacleNotified &&
                obsDx < obstacleRange &&
                obsDy < obstacleRange) {
              obstacleNotified = true;
              tts.speak("장애물 근처입니다. 주의하세요.");
            }
          }
        }
      });
    } catch (e) {
      print("연결 실패: $e");
    }
  }

  Map<String, double>? parsePosition(String line) {
    try {
      final data = line.split('Position:').last.trim();
      final parts = data.split(',');
      if (parts.length < 6) return null;
      return {
        'x': double.parse(parts[3]),
        'y': double.parse(parts[4]),
        'z': double.parse(parts[5]),
      };
    } catch (_) {
      return null;
    }
  }

  void triggerVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate();
    }
  }

  void handleDoubleTap() {
    if (instructionGiven) return;

    if (lastSeenArtworkId < currentArtworkId) {
      tts.speak("오른쪽으로 이동하세요. 벽에 왼손을 대고 따라가세요.");
    } else {
      tts.speak("왼쪽으로 이동하세요. 벽에 오른손을 대고 따라가세요.");
    }
    instructionGiven = true;
  }

  @override
  void dispose() {
    tts.stop();
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: handleDoubleTap,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('작품 길찾기'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Text(
                  currentX != null
                      ? '현재 좌표: x=${currentX!.toStringAsFixed(2)}, y=${currentY!.toStringAsFixed(2)}, z=${currentZ!.toStringAsFixed(2)}'
                      : isConnected
                          ? '좌표 수신 대기 중...'
                          : '블루투스 연결 중...',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/explanation');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD600),
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
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

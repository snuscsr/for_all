import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../providers/tour_state.dart';
import 'package:permission_handler/permission_handler.dart';

class NavigateScreen extends StatefulWidget {
  const NavigateScreen({super.key});

  @override
  State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen> {
  final AudioPlayer player = AudioPlayer();
  BluetoothDevice? device;
  BluetoothCharacteristic? notifyChar;

  // 도착 위치 기준 좌표 (예시)
  final targetX = 2.43;
  final targetY = -0.28;
  final tolerance = 0.2; // 도착 판단 거리 오차범위

  double? currentX;
  double? currentY;
  double? currentZ;


  @override
  void initState() {
    super.initState();
    requestBluetoothPermissions().then((_) {
      startBluetooth();      // 권한 받은 뒤에 스캔 시작
      playNavigationAudio(); // 기존 오디오 재생도 포함
    });
  }

  void triggerVibration() async {
  if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate();
  }
}

  Future<void> requestBluetoothPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location, // 일부 BLE 기기에서는 여전히 필요함
    ].request();

    // 디버깅용 로그
    for (var entry in statuses.entries) {
      print('${entry.key}: ${entry.value}');
    }
  }

  void playNavigationAudio() {
    final tourState = Provider.of<TourState>(context, listen: false);
    final curindex = tourState.currentArtworkIndex;
    final preindex = tourState.previousArtworkIndex;
    final entry = tourState.entryPoint;

    String audioPath;
    if (entry == 1 || entry == 2) {
      audioPath = 'audio/routes/$preindex$curindex.mp3';
    } else {
      audioPath = 'audio/routes/9$curindex.mp3';
    }
    player.play(AssetSource(audioPath));
  }

  Future<void> startBluetooth() async {
    // 1. 스캔 시작
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    // 2. 원하는 장치 찾기 (예: 이름이 'UWB'인 장치)
    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.name.contains('UWB')) {
          await FlutterBluePlus.stopScan();
          device = r.device;
          await device!.connect();

          // 3. 서비스 & 특성 탐색
          final services = await device!.discoverServices();
          for (var service in services) {
            for (var characteristic in service.characteristics) {
              if (characteristic.properties.notify) {
                notifyChar = characteristic;
                await notifyChar!.setNotifyValue(true);
                notifyChar!.value.listen(handleData);
                break;
              }
            }
          }
          break;
        }
      }
    });
  }

  void handleData(List<int> data) {
    try {
      final line = utf8.decode(data);
      if (!line.contains("Position:")) return;
      final pos = parsePosition(line);
      if (pos != null) {
        setState(() {
          currentX = pos['x'];
          currentY = pos['y'];
          currentZ = pos['z'];
        });

        final dx = (pos['x']! - targetX).abs();
        final dy = (pos['y']! - targetY).abs();

        if (dx < tolerance && dy < tolerance) {
          triggerVibration();
          player.play(AssetSource("audio/arrived.mp3")); // 도착 알림 음성
        }
      }
    } catch (e) {
      print("Data error: $e");
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
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    player.dispose();
    notifyChar?.setNotifyValue(false);
    device?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('작품 길찾기')),
      body: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentX != null
                  ? '현재 좌표: x=${currentX!.toStringAsFixed(2)}, y=${currentY!.toStringAsFixed(2)}, z=${currentZ!.toStringAsFixed(2)}'
                  : '좌표 수신 대기 중...',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/explanation');
              },
              child: const Text('작품 해설 듣기'),
            ),
          ],
        ),
      ),
    );
  }
}

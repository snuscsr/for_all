import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class NavigateScreen extends StatefulWidget {
  const NavigateScreen({super.key});

  @override
  State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen> {
  final AudioPlayer player = AudioPlayer();
  BluetoothConnection? connection;
  bool isConnected = false;

  final targetX = 2.43;
  final targetY = -0.28;
  final tolerance = 0.2;

  double? currentX;
  double? currentY;
  double? currentZ;

  @override
  void initState() {
    super.initState();
    connectToHC06();
  }

  Future<void> connectToHC06() async {
    try {
      List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();

      // HC-06 기기 찾기
      final device = bondedDevices.firstWhere((d) => d.name?.contains("HC") ?? false);
      print("연결 시도 중: ${device.name}");

      connection = await BluetoothConnection.toAddress(device.address);
      print("연결 성공!");

      setState(() => isConnected = true);

      connection!.input!.listen((data) {
        final line = utf8.decode(data).trim();
        print("수신 데이터: $line");
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

            if (dx < tolerance && dy < tolerance) {
              triggerVibration();
              // player.play(AssetSource("audio/Day6.mp3"));
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

  @override
  void dispose() {
    player.dispose();
    connection?.dispose();
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
                  : isConnected
                      ? '좌표 수신 대기 중...'
                      : '블루투스 연결 중...',
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

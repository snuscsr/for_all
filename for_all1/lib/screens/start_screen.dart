import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('전시 관람'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '이어폰을 연결한 후,\n버튼을 눌러 관람을 시작하세요.',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildButton(
              context,
              '관람 시작하기',
              () {
                Navigator.pushNamed(context, '/options');
              },
              false,
              Icons.play_arrow,
            ),
          ],
        ),
      ),
    );
  }

  // 버튼 공통 위젯
  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed,
      [bool isDisabled = false, IconData? icon]) {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD600),
          disabledBackgroundColor: Colors.grey[700],
          foregroundColor: Colors.black,
          disabledForegroundColor: Colors.white70,
          textStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 24),
              const SizedBox(width: 12),
            ],
            Text(isDisabled ? '처리 중... ($text)' : text),
          ],
        ),
      ),
    );
  }
}

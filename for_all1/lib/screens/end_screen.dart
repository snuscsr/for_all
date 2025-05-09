import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tour_state.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tourState = Provider.of<TourState>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('관람 종료'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: _buildButton(
            context,
            '초기화면으로 돌아가기',
            () {
              tourState.resetTour(); // 상태 초기화
              Navigator.pushNamedAndRemoveUntil(context, '/start', (_) => false);
            },
            false,
            Icons.home,
          ),
        ),
      ),
    );
  }

  // 버튼 공통 위젯
  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed,
      [bool isDisabled = false, IconData? icon]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
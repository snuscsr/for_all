import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tour_state.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tourState = Provider.of<TourState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('관람 종료')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            tourState.resetTour(); // 상태 초기화
            Navigator.pushNamedAndRemoveUntil(context, '/start', (_) => false);
          },
          child: const Text('초기화면으로 돌아가기'),
        ),
      ),
    );
  }
}

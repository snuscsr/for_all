import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tour_state.dart';

class OptionScreen extends StatelessWidget {
  const OptionScreen({super.key});

  final List<String> options = const [
    '작품 크기',
    '작가 소개',
    '작품 배경'
  ];

  @override
  Widget build(BuildContext context) {
    final tourState = Provider.of<TourState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('관람 옵션 선택')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = tourState.selectedOptions.contains(option);

                  return ListTile(
                    title: Text(option, style: const TextStyle(fontSize: 18)),
                    trailing: Switch(
                      value: isSelected,
                      onChanged: (_) {
                        tourState.toggleOption(option);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/artworks');
              },
              child: const Text('관람할 작품 선택하기'),
            ),
          ],
        ),
      ),
    );
  }
}

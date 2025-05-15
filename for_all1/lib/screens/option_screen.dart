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
    final artwork = tourState.artworks[tourState.currentArtworkIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          '관람 옵션 선택',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            const SizedBox(height: 16),
            const Text(
              '관심있는 설명 항목을 선택하세요',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = tourState.selectedOptions.contains(option);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () {
                        tourState.toggleOption(option);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey[900],
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFFD600) : Colors.grey[800]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                option,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: isSelected ? const Color(0xFFFFD600) : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: isSelected ? const Color(0xFFFFD600) : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFFFD600) : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.black,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD600),
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/artworks');
                },
                child: const Text('다음'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

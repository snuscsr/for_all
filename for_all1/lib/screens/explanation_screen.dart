import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tour_state.dart';
import '../models/artwork.dart';

class ExplanationScreen extends StatelessWidget {
  const ExplanationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tourState = Provider.of<TourState>(context);
    final Artwork artwork = tourState.artworks[tourState.currentArtworkIndex];
    final selectedOptions = tourState.selectedOptions;

    return Scaffold(
      appBar: AppBar(title: Text(artwork.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: selectedOptions.map((option) {
                  final content = artwork.details[option] ?? '정보 없음';
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(option, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(content),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (tourState.currentArtworkIndex < tourState.artworks.length - 1) {
                      tourState.goToNextArtwork();
                      Navigator.pushNamed(context, '/navigate');
                    } else {
                      Navigator.pushNamed(context, '/end');
                    }
                  },
                  child: const Text('다음 작품 보러가기'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/artworks');
                  },
                  child: const Text('작품 리스트로 돌아가기'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/end');
                  },
                  child: const Text('관람 종료하기'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tour_state.dart';
import '../models/artwork.dart';

class ArtworkListScreen extends StatelessWidget {
  const ArtworkListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tourState = Provider.of<TourState>(context);
    final List<Artwork> artworks = tourState.artworks;

    return Scaffold(
      appBar: AppBar(title: const Text('작품 리스트')),
      body: artworks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: artworks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final artwork = artworks[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artwork.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '작가: ${artwork.artist}',
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              tourState.previousArtworkIndex = tourState.currentArtworkIndex;
                              tourState.currentArtworkIndex = index;
                              Navigator.pushNamed(context, '/navigate');
                            },
                            child: const Text('작품 보러가기'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

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
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final artwork = artworks[index];
                return ListTile(
                  title: Text(artwork.title, style: const TextStyle(fontSize: 18)),
                  subtitle: Text(artwork.description),
                  trailing: ElevatedButton(
                    onPressed: () {
                      tourState.previousArtworkIndex = tourState.currentArtworkIndex;
                      tourState.currentArtworkIndex = index;
                      Navigator.pushNamed(context, '/navigate');
                    },
                    child: const Text('작품 보러가기'),
                  ),
                );
              },
            ),
    );
  }
}

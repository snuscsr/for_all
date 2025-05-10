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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          '작품 리스트',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: artworks.isEmpty
        ? const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFFD600),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '관람할 작품을 선택하세요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: artworks.length,
                    itemBuilder: (context, index) {
                      final artwork = artworks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey[900],
                            border: Border.all(
                              color: Colors.grey[800]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      artwork.title,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      artwork.description,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        height: 1.4,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 65,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          tourState.currentArtworkIndex = index;
                                          Navigator.pushNamed(context, '/navigate');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFFD600),
                                          foregroundColor: Colors.black,
                                          textStyle: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('작품 보러가기'),
                                            SizedBox(width: 12),
                                            Icon(Icons.arrow_forward, size: 24),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
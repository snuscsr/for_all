import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/artwork.dart';
import 'dart:developer';

class TourState with ChangeNotifier {
  List<String> selectedOptions = [];
  int currentArtworkIndex = 0;
  List<Artwork> artworks = [];

  void toggleOption(String option) {
    if (selectedOptions.contains(option)) {
      selectedOptions.remove(option);
    } else {
      selectedOptions.add(option);
    }
    notifyListeners();
  }

  void goToNextArtwork() {
    if (currentArtworkIndex < artworks.length - 1) {
      currentArtworkIndex++;
      notifyListeners();
    }
  }

  void resetTour() {
    currentArtworkIndex = 0;
    selectedOptions.clear();
    notifyListeners();
  }

  Future<void> loadArtworks() async {
    final String jsonStr = await rootBundle.loadString('assets/artworks.json');
    final List jsonList = json.decode(jsonStr);
    artworks = jsonList.map((e) => Artwork.fromJson(e)).toList();
    log('Loaded ${artworks.length} artworks', name: 'TourState');
    notifyListeners();
  }
}

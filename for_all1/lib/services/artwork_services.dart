import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/artwork.dart';

class ArtworkService {
  static Future<List<Artwork>> loadArtworks() async {
    final String jsonStr = await rootBundle.loadString('assets/artworks.json');
    final List jsonList = json.decode(jsonStr);
    return jsonList.map((e) => Artwork.fromJson(e)).toList();
  }
}

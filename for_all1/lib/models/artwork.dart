class Artwork {
  final int id;
  final String title;
  final String description;
  final String artist;
  final Map<String, String> details;
  final String audioAssetPath; // 예: 'audio/explanation1.mp3'
  final List<Duration> blockTimestamps; // 블록 단위 시간

  final double x;
  final double y;
  final double z;

  Artwork({
    required this.id,
    required this.title,
    required this.description,
    required this.artist,
    required this.details,
    required this.audioAssetPath,
    required this.blockTimestamps,
    required this.x,
    required this.y,
    required this.z,
  });

  factory Artwork.fromJson(Map<String, dynamic> json) {
    return Artwork(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      artist: json['artist'],
      details: Map<String, String>.from(json['details']),
      audioAssetPath: json['audioAssetPath'],
      blockTimestamps: (json['blockTimestamps'] as List<dynamic>)
          .map((seconds) => Duration(seconds: seconds as int))
          .toList(),
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      z: json['z'].toDouble(),
    );
  }
}

class Artwork {
  final int id;
  final String title;
  final String description;
  final Map<String, String> details;
  final String audioAssetPath; // 예: 'audio/explanation1.mp3'
  final List<Duration> blockTimestamps; // 블록 단위 시간

  Artwork({
    required this.id,
    required this.title,
    required this.description,
    required this.details,
    required this.audioAssetPath,
    required this.blockTimestamps,
  });

  factory Artwork.fromJson(Map<String, dynamic> json) {
    return Artwork(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      details: Map<String, String>.from(json['details']),
      audioAssetPath: json['audioAssetPath'],
      blockTimestamps: (json['blockTimestamps'] as List<dynamic>)
          .map((seconds) => Duration(seconds: seconds as int))
          .toList(),
    );
  }
}

class Artwork {
  final int id;
  final String title;
  final String description;
  final Map<String, String> details;

  Artwork({
    required this.id,
    required this.title,
    required this.description,
    required this.details,
  });

  factory Artwork.fromJson(Map<String, dynamic> json) {
    return Artwork(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      details: Map<String, String>.from(json['details']),
    );
  }
}

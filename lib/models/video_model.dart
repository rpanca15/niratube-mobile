class Video {
  final int id;
  final String title;
  final String description;
  final String videoUrl;
  final int likes;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.likes,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['video'],
      likes: json['likes_count'] ?? 0,
    );
  }
}

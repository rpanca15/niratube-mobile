class Video {
  final int id;
  final String video;
  final String title;
  final String description;
  final String privacy;
  final int categoryId;
  final int uploaderId;
  final int views;
  final int likesCount;

  Video({
    required this.id,
    required this.video,
    required this.title,
    required this.description,
    required this.privacy,
    required this.categoryId,
    required this.uploaderId,
    required this.views,
    required this.likesCount,
  });

  // Factory method untuk membuat instance dari JSON
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? 0, // Menangani kemungkinan null untuk 'id'
      video: json['video'] ?? '', // Menangani kemungkinan null untuk 'video'
      title: json['title'] ?? '', // Menangani kemungkinan null untuk 'title'
      description: json['description'] ?? '', // Menangani kemungkinan null untuk 'description'
      privacy: json['privacy'] ?? '', // Menangani kemungkinan null untuk 'privacy'
      categoryId: json['category_id'] ?? 0, // Menangani kemungkinan null untuk 'category_id'
      uploaderId: json['uploader_id'] ?? 0, // Menangani kemungkinan null untuk 'uploader_id'
      views: json['views'] ?? 0, // Menangani kemungkinan null untuk 'views'
      likesCount: json['likes_count'] ?? 0, // Menangani kemungkinan null untuk 'likes_count'
    );
  }

  // Method untuk mengonversi objek Video menjadi Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video': video,
      'title': title,
      'description': description,
      'privacy': privacy,
      'category_id': categoryId,
      'uploader_id': uploaderId,
      'views': views,
      'likes_count': likesCount,
    };
  }
}

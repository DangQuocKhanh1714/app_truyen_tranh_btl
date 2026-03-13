class MangaModel {
  final int id;
  final String title;
  final String imageUrl;
  final String author;
  final String description;
  final String latestChapter;

  MangaModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.author,
    required this.description,
    required this.latestChapter,
  });

  // Chuyển object thành Map để truyền sang trang Edit
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'author': author,
      'description': description,
      'latest_chapter': latestChapter,
      'genres': '', // Khởi tạo trống để trang Edit xử lý split()
    };
  }

  factory MangaModel.fromMap(Map<String, dynamic> map) {
    return MangaModel(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      imageUrl: map['image_url'] ?? '',
      author: map['author'] ?? 'Đang cập nhật',
      description: map['description'] ?? '',
      latestChapter: map['latest_chapter']?.toString() ?? 'Đang cập nhật',
    );
  }
}
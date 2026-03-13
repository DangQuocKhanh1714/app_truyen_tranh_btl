class ChapterModel {
  final int id;
  final int mangaId;
  final String chapterName;
  final List<String> contentImages;
  final String createdAt;

  ChapterModel({
    required this.id,
    required this.mangaId,
    required this.chapterName,
    required this.contentImages,
    required this.createdAt,
  });

  // Chuyển đổi từ Map (dữ liệu Supabase) sang Model
  factory ChapterModel.fromMap(Map<String, dynamic> map) {
    // Xử lý an toàn cho cột content_images (lưu dưới dạng string ngăn cách bằng dấu phẩy)
    List<String> images = [];
    if (map['content_images'] != null && map['content_images'].toString().isNotEmpty) {
      try {
        // content_images được lưu dưới dạng: "url1,url2,url3"
        // Cần split bằng dấu phẩy để convert thành List<String>
        String imageString = map['content_images'].toString();
        images = imageString.split(',').map((url) => url.trim()).toList();
        
        // Debug: In ra để kiểm tra
        print("=== ChapterModel Debug ===");
        print("Chapter: ${map['chapter_name']}");
        print("Raw content_images: ${map['content_images']}");
        print("Parsed images count: ${images.length}");
        print("First image: ${images.isNotEmpty ? images.first : 'Không có ảnh'}");
        print("=========================");
      } catch (e) {
        print("Lỗi parse content_images: $e");
      }
    }

    return ChapterModel(
      id: map['id'] ?? 0,
      mangaId: map['manga_id'] ?? 0,
      chapterName: map['chapter_name'] ?? 'Không có tên chương',
      contentImages: images,
      createdAt: map['created_at'] ?? '',
    );
  }

  // Phương thức helper nếu bạn cần chuyển ngược lại thành Map để insert/update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'manga_id': mangaId,
      'chapter_name': chapterName,
      'content_images': contentImages,
      'created_at': createdAt,
    };
  }
}
/// Model cho một chương truyện
class Chapter {
  final int id;
  final String name;
  final List<String> images;

  const Chapter({
    required this.id,
    required this.name,
    required this.images,
  });
}

/// Quản lý tất cả các chương của Sưu Quyển Rú 2.5D
class SuuQuyenRu25dChapters {
  static const List<Chapter> chapters = [
    // TODO: Thêm chapters tương ứng
  ];

  /// Lấy chương theo ID
  static Chapter? getChapterById(int id) {
    try {
      return chapters.firstWhere((chapter) => chapter.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Lấy tất cả các chương
  static List<Chapter> getAllChapters() {
    return chapters;
  }

  /// Tổng số chương
  static int getTotalChapters() {
    return chapters.length;
  }
}

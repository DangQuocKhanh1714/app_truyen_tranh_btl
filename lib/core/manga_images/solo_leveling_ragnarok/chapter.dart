import 'images.dart';

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

/// Quản lý tất cả các chương của Solo Leveling: Ragnarok
class SoloLevelingRagnarokChapters {
  static final List<Chapter> chapters = [
    Chapter(
      id: 1,
      name: 'Chương 1',
      images: SoloLevelingRagnarokImages.chapter1Images,
    ),
    Chapter(
      id: 2,
      name: 'Chương 2',
      images: SoloLevelingRagnarokImages.chapter2Images,
    ),
    Chapter(
      id: 3,
      name: 'Chương 3',
      images: SoloLevelingRagnarokImages.chapter3Images,
    ),
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

  /// Tổng số chương hiện có
  static int getTotalChapters() {
    return chapters.length;
  }
}
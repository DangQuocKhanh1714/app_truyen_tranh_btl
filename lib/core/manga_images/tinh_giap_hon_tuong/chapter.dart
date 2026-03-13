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

/// Quản lý tất cả các chương của Tinh Giáp Hồn Tướng
class TinhGiapHonTuongChapters {
  static final List<Chapter> chapters = [
    Chapter(id: 0, name: 'Chương 0', images: TinhGiapHonTuongImages.chapter0Images),
    Chapter(id: 1, name: 'Chương 1', images: TinhGiapHonTuongImages.chapter1Images),
    Chapter(id: 2, name: 'Chương 2', images: TinhGiapHonTuongImages.chapter2Images),
    Chapter(id: 3, name: 'Chương 3', images: TinhGiapHonTuongImages.chapter3Images),
    Chapter(id: 4, name: 'Chương 4', images: TinhGiapHonTuongImages.chapter4Images),
  ];

  static Chapter? getChapterById(int id) {
    try {
      return chapters.firstWhere((chapter) => chapter.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Chapter> getAllChapters() => chapters;
  static int getTotalChapters() => chapters.length;
}
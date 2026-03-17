import 'package:app_truyen_tranh/core/manga_images/chainsaw_man/images.dart';

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

/// Quản lý tất cả các chương của Chainsaw Man
class ChainsawManChapters {
  static final List<Chapter> chapters = [
    Chapter(id: 1, name: 'Chương 1', images: ChainsawManImages.chapter1Images),
    Chapter(id: 2, name: 'Chương 2', images: ChainsawManImages.chapter2Images),
    Chapter(id: 3, name: 'Chương 3', images: ChainsawManImages.chapter3Images),
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
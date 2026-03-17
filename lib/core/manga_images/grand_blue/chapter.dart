import 'package:app_truyen_tranh/core/manga_images/grand_blue/images.dart';

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

/// Quản lý tất cả các chương của Grand Blue
class GrandBlueChapters {
  static final List<Chapter> chapters = [
    Chapter(id: 1, name: 'Chương 1: Deep Blue', images: GrandBlueImages.chapter1Images),
    Chapter(id: 2, name: 'Chương 2: Chào mừng đến với PAB', images: GrandBlueImages.chapter2Images),
    Chapter(id: 3, name: 'Chương 3: Tiệc lặn', images: GrandBlueImages.chapter3Images),
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
import 'package:app_truyen_tranh/core/manga_images/ong_chong_yakuza/images.dart';

class Chapter {
  final double id;
  final String name;
  final List<String> images;

  const Chapter({
    required this.id,
    required this.name,
    required this.images,
  });
}


/// Quản lý tất cả các chương của bộ Ông Chồng Yakuza
class YakuzaHusbandChapters {
  static final List<Chapter> chapters = [
    Chapter(id: 1.0, name: 'Chương 1', images: YakuzaHusbandImages.chapter1Images),
    Chapter(id: 2.0, name: 'Chương 2', images: YakuzaHusbandImages.chapter2Images),
    Chapter(id: 3.0, name: 'Chương 3', images: YakuzaHusbandImages.chapter3Images),
  ];

  static Chapter? getChapterById(double id) {
    try {
      return chapters.firstWhere((chapter) => chapter.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Chapter> getAllChapters() => chapters;
}
import 'package:app_truyen_tranh/core/manga_images/shuumatsu_no_valkyrie/images.dart';

/// Model cho một chương truyện
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

/// Quản lý tất cả các chương của Shuumatsu no Valkyrie
class ValkyrieChapters {
  static final List<Chapter> chapters = [
    Chapter(id: 1.0, name: 'Chương 1: Ragnarok', images: ValkyrieImages.chapter1Images),
    Chapter(id: 2.0, name: 'Chương 2: Đỉnh cao', images: ValkyrieImages.chapter2Images),
    Chapter(id: 2.5, name: 'Chương 2.5: Ngoại truyện', images: ValkyrieImages.chapter2_5Images),
  ];

  static Chapter? getChapterById(double id) {
    try {
      return chapters.firstWhere((chapter) => chapter.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Chapter> getAllChapters() => chapters;
  static int getTotalChapters() => chapters.length;
}
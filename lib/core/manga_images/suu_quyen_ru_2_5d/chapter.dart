import 'package:app_truyen_tranh/core/manga_images/suu_quyen_ru_2_5d/images.dart';


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


/// Quản lý tất cả các chương của Sự Quyến Rũ Của 2.5D
class Cosplay25dChapters {
  static final List<Chapter> chapters = [
    Chapter(id: 1, name: 'Chương 1: Nhân Vật Khác Biệt', images: Cosplay25dImages.chapter1Images),
    Chapter(id: 2, name: 'Chương 2: Tiềm Năng Cosplay', images: Cosplay25dImages.chapter2Images),
    Chapter(id: 3, name: 'Chương 3: Cùng Nhau Chế Tạo', images: Cosplay25dImages.chapter3Images),
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
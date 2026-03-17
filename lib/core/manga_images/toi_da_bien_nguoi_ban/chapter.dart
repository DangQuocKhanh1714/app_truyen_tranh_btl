import 'package:app_truyen_tranh/core/manga_images/suu_quyen_ru_2_5d/images.dart';
import 'package:app_truyen_tranh/core/manga_images/toi_da_bien_nguoi_ban/images.dart';


/// Model cho một chương truyện
class Chapter {
  final double id; // Chuyển từ int sang double
  final String name;
  final List<String> images;

  const Chapter({
    required this.id,
    required this.name,
    required this.images,
  });
}



/// Quản lý tất cả các chương của bộ Childhood Friend
class ChildhoodFriendChapters {
  static final List<Chapter> chapters = [
    Chapter(id: 1.0, name: 'Chương 1', images: ChildhoodFriendImages.chapter1Images),
    Chapter(id: 2.0, name: 'Chương 2', images: ChildhoodFriendImages.chapter2Images),
    Chapter(id: 2.1, name: 'Chương 2.1', images: ChildhoodFriendImages.chapter2_1Images),
    Chapter(id: 2.2, name: 'Chương 2.2', images: ChildhoodFriendImages.chapter2_2Images),
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
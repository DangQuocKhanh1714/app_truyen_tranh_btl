import 'package:app_truyen_tranh/core/manga_images/jojo_bizarre_adventure/images.dart';
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
/// Quản lý tất cả các chương của Jojo
class JojoChapters {
  static final List<Chapter> chapters = [
    Chapter(
      id: 199, 
      name: 'Chương 199', 
      images: JojoImages.chapter199Images
    ),
    Chapter(
      id: 200, 
      name: 'Chương 200', 
      images: JojoImages.chapter200Images
    ),
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
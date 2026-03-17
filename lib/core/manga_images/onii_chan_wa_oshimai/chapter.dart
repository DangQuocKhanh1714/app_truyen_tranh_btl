import 'package:app_truyen_tranh/core/manga_images/onii_chan_wa_oshimai/images.dart';

/// Model cho một chương truyện
class Chapter {
  final double id; // Sử dụng double để hỗ trợ chương 1.5
  final String name;
  final List<String> images;

  const Chapter({
    required this.id,
    required this.name,
    required this.images,
  });
}
/// Quản lý tất cả các chương của Onii-Chan Wa Oshimai!
class OniichanChapters {
  static final List<Chapter> chapters = [
    Chapter(id: 1.0, name: 'Chương 1: Mahiro và cơ thể mới', images: OniichanImages.chapter1Images),
    Chapter(id: 1.5, name: 'Chương 1.5: Ngoại truyện', images: OniichanImages.chapter1_5Images),
    Chapter(id: 2.0, name: 'Chương 2: Mahiro và tháng đó', images: OniichanImages.chapter2Images),
    Chapter(id: 3.0, name: 'Chương 3: Mahiro và việc giặt giũ', images: OniichanImages.chapter3Images),
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
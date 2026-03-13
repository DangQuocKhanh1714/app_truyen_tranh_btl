import 'manga_model.dart';

class HistoryModel {
  final int id;
  final String userId;
  final int mangaId;
  final int lastChapterId; // Tên biến trong Class
  final DateTime updatedAt;
  final MangaModel? manga;
  final String? lastChapterName;

  HistoryModel({
    required this.id,
    required this.userId,
    required this.mangaId,
    required this.lastChapterId, // Đây là tên tham số đúng
    required this.updatedAt,
    this.manga,
    this.lastChapterName,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      mangaId: map['manga_id'] as int,
      // Sửa từ last_chapter_id thành lastChapterId để khớp với Constructor bên trên
      lastChapterId: map['last_chapter_id'] as int, 
      updatedAt: DateTime.parse(map['updated_at'] as String),
      
      manga: map['manga_title'] != null ? MangaModel(
      id: map['manga_id'],
      title: map['manga_title'],
      imageUrl: map['manga_image'],
      author: map['manga_author'] ?? 'Đang cập nhật',
      description: map['manga_desc'] ?? '',
      latestChapter: '', 
    ) : null,
          
      lastChapterName: map['last_chapter_name'] as String?,
    );
  }
}
import 'package:app_truyen_tranh/core/manga_images/tinh_giap_hon_tuong/chapter.dart' as tgiht;
import 'package:app_truyen_tranh/core/manga_images/chainsaw_man/chapter.dart' as csm;
import 'package:app_truyen_tranh/core/manga_images/solo_leveling_ragnarok/chapter.dart' as slr;
import 'package:app_truyen_tranh/data/models/chapter_model.dart';
import 'package:app_truyen_tranh/data/services/database_helper.dart'; 
import 'package:flutter/foundation.dart';

class MangaChaptersManager {
  static final Map<int, List<dynamic> Function()> _fileDataRegistry = {
    1: () => tgiht.TinhGiapHonTuongChapters.getAllChapters(),
    2: () => csm.ChainsawManChapters.getAllChapters(),
    3: () => slr.SoloLevelingRagnarokChapters.getAllChapters(),
  };

  // Cập nhật số lượng chương vào bảng mangas
  static Future<void> _updateMangaChapterCount(int mangaId) async {
    try {
      final db = await DatabaseHelper().database;
      final List<Map<String, dynamic>> countResult = await db.rawQuery(
        'SELECT COUNT(*) as total FROM chapters WHERE manga_id = ?',
        [mangaId],
      );
      int totalChapters = countResult.first['total'] as int;

      await db.update(
  'mangas',
  {'latest_chapter': 'Chương $totalChapters'}, // Chỗ này sẽ đổi số 4 thành số 5 trong DB
  where: 'id = ?',
  whereArgs: [mangaId],
);
    } catch (e) {
      debugPrint("⚠️ Lỗi update count: $e");
    }
  }

  static Future<List<ChapterModel>> getChapters(int mangaId) async {
    try {
      final data = await DatabaseHelper().fetchChapters(mangaId);
      if (data.isNotEmpty) {
        return data.map((map) => ChapterModel.fromMap(map)).toList();
      }
      return _getChaptersFromFile(mangaId);
    } catch (e) {
      return _getChaptersFromFile(mangaId);
    }
  }

  static List<ChapterModel> _getChaptersFromFile(int mangaId) {
    final getFileData = _fileDataRegistry[mangaId];
    if (getFileData == null) return [];
    final data = getFileData();
    return data.map((ch) {
      List<String> imagesList = (ch.images is List) ? List<String>.from(ch.images) : [];
      return ChapterModel(
        id: ch.id,
        mangaId: mangaId,
        chapterName: ch.name,
        contentImages: imagesList,
        createdAt: DateTime.now().toIso8601String(),
      );
    }).toList();
  }

  static Future<void> addChapter({required int mangaId, required String name, required String images}) async {
    final db = await DatabaseHelper().database;
    await db.insert('chapters', {
      'manga_id': mangaId,
      'chapter_name': name,
      'content_images': images,
    });
    await _updateMangaChapterCount(mangaId);
  }

  // HÀM GÂY LỖI: Bây giờ đã nhận 2 tham số đồng bộ với UI
  static Future<void> deleteChapter(int chapterId, int mangaId) async {
    final db = await DatabaseHelper().database;
    await db.delete('chapters', where: 'id = ?', whereArgs: [chapterId]);
    await _updateMangaChapterCount(mangaId);
  }

  static Future<void> updateChapter({required int chapterId, required String name, required String images}) async {
    final db = await DatabaseHelper().database;
    await db.update('chapters', 
      {'chapter_name': name, 'content_images': images},
      where: 'id = ?', whereArgs: [chapterId]
    );
  }

  static Future<ChapterModel?> getChapterById(int mangaId, int chapterId) async {
    final chapters = await getChapters(mangaId);
    try {
      return chapters.firstWhere((ch) => ch.id == chapterId);
    } catch (e) {
      return null;
    }
  }
}
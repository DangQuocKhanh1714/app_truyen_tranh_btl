import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../../core/manga_images/tinh_giap_hon_tuong/chapter.dart';
import '../../core/manga_images/solo_leveling_ragnarok/chapter.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    late DatabaseFactory dbFactory;
    String path;

    if (kIsWeb) {
      dbFactory = databaseFactoryFfiWeb;
      // Đổi v5 thành v6 để ép trình duyệt tạo mới bảng có cột genres
      path = 'manga_app_v8_persistent.db';
    } else {
      dbFactory = databaseFactory;
      path = join(await getDatabasesPath(), 'manga_app_v8.db');
    }

    print("DATABASE PATH: $path");

    return await dbFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1, // Reset version về 1 cho db mới
        onCreate: _onCreate,
      ),
    );
  }

  Future<void> _dropAllTables(Database db) async {
    final tables = [
      'chapters',
      'mangas',
      'manga_categories',
      'categories',
      'favorites',
      'history',
      'comments',
      'users',
    ];
    for (var table in tables) {
      await db.execute('DROP TABLE IF EXISTS $table');
    }
  }

  // --- 1. KHỞI TẠO CẤU TRÚC BẢNG ---
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT,
        username TEXT,
        avatar_url TEXT,
        firebase_uid TEXT,
        role TEXT DEFAULT 'user',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute(
      'CREATE TABLE categories (id INTEGER PRIMARY KEY, name TEXT NOT NULL)',
    );

    await db.execute('''
  CREATE TABLE mangas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    alt_title TEXT,
    image_url TEXT,
    description TEXT,
    author TEXT,
    status TEXT,
    genres TEXT, -- THÊM DÒNG NÀY ĐỂ LƯU THỂ LOẠI
    views INTEGER DEFAULT 0,
    likes INTEGER DEFAULT 0
  )
''');

    await db.execute('''
      CREATE TABLE manga_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        manga_id INTEGER,
        category_id INTEGER,
        FOREIGN KEY (manga_id) REFERENCES mangas (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE chapters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        manga_id INTEGER,
        chapter_name TEXT NOT NULL,
        content_images TEXT, 
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (manga_id) REFERENCES mangas (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        manga_id INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (manga_id) REFERENCES mangas (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
  CREATE TABLE history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT,
    manga_id INTEGER,
    last_chapter_id INTEGER,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, manga_id) ON CONFLICT REPLACE -- THÊM DÒNG NÀY
  )
''');

    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        manga_id INTEGER,
        user_id TEXT,
        content TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (manga_id) REFERENCES mangas (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- 2. HÀM ĐỔ DỮ LIỆU MẪU (SEED DATA) ---
  Future<void> seedData() async {
    final db = await database;

    final allCats = [
      {"id": 1, "name": "Action"},
      {"id": 2, "name": "Romance"},
      {"id": 3, "name": "Manga"},
      {"id": 4, "name": "Manhua"},
      {"id": 5, "name": "Manhwa"},
      {"id": 6, "name": "Drama"},
      {"id": 7, "name": "Yaoi"},
      {"id": 8, "name": "Yuri"},
      {"id": 9, "name": "Slice of life"},
      {"id": 10, "name": "Saygex"},
      {"id": 11, "name": "Isekai"},
      {"id": 12, "name": "Harem"},
      {"id": 13, "name": "Ecchi"},
      {"id": 14, "name": "Comedy"},
      {"id": 15, "name": "Supernatural"},
      {"id": 16, "name": "School Life"},
      {"id": 17, "name": "Adventure"},
      {"id": 18, "name": "Shounen"},
      {"id": 19, "name": "Truyện Màu"},
      {"id": 20, "name": "Shoujo"},
      {"id": 21, "name": "Gender Bender"},
    ];

    for (var c in allCats) {
      await db.insert(
        'categories',
        c,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await _seedMangaList(db);

    await _seedChaptersForManga(
      db,
      1,
      TinhGiapHonTuongChapters.getAllChapters(),
    );
    await _seedChaptersForManga(
      db,
      3,
      SoloLevelingRagnarokChapters.getAllChapters(),
    );

    await _seedMangaCategoryMapping(db);
    // Kiểm tra xem đã có truyện nào chưa
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM mangas'),
    );

    if (count == 0) {
      print("Database trống, đang nạp dữ liệu mẫu...");
      // Thực hiện các lệnh insert manga, categories...
    } else {
      print("Đã có $count bộ truyện, bỏ qua bước nạp dữ liệu mẫu.");
    }
  }

  Future<void> _seedChaptersForManga(
    Database db,
    int mangaId,
    List<dynamic> apiChapters,
  ) async {
    for (var chapter in apiChapters) {
      final alreadyInDb = await db.query(
        'chapters',
        where: 'manga_id = ? AND chapter_name = ?',
        whereArgs: [mangaId, chapter.name],
      );

      if (alreadyInDb.isEmpty) {
        await db.insert('chapters', {
          'manga_id': mangaId,
          'chapter_name': chapter.name,
          'content_images': chapter.images.join(','),
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  Future<void> _seedMangaList(Database db) async {
    final List<Map<String, dynamic>> mangaData = [
      {
        "id": 1,
        "title": "Tinh Giáp Hồn Tướng",
        "genres": "Action, Manhua, Isekai", // Thêm dòng này vào
        "image_url":
            "https://assets.leetcode.com/users/images/31f8c3f1-1127-4164-a7de-239488675f0c_1755835680.4616673.jpeg",
        "description": "Vị hoàng hồn sư cuối cùng...",
        "author": "Đang cập nhật",
        "status": "Đang cập nhật",
      },
      {
        "id": 2,
        "title": "Chainsaw Man",
        "alt_title": "Thợ Săn Quỷ",
        "image_url":
            "https://upload.wikimedia.org/wikipedia/vi/2/24/Chainsawman.jpg",
        "description": "Cậu thiếu niên Denji...",
        "author": "Đang cập nhật",
        "status": "Đang cập nhật",
      },
      {
        "id": 3,
        "title": "Solo Leveling Ragnarok",
        "alt_title": "Tôi Thăng Cấp Một Mình",
        "image_url":
            "https://i0.wp.com/graphicpolicy.com/wp-content/uploads/2024/11/Solo-Leveling-Ragnarok.jpg?ssl=1",
        "description": "Sự tồn tại của Trái Đất...",
        "author": "Đang cập nhật",
        "status": "Đang cập nhật",
      },
      {
        "id": 4,
        "title": "Citrus",
        "image_url":
            "https://i5.walmartimages.com/seo/Citrus-Citrus-Plus-Vol-3-Paperback-9781648279256_f736bc29-5f66-4919-8c37-1bac595a0511.b7c7d9a8deb4e6df09c4725c9ab5e503.jpeg",
        "description": "Nhân vật chính Yuzuko...",
        "author": "Đang cập nhật",
        "status": "Đang cập nhật",
      },
      {
        "id": 5,
        "title": "Jojo's Bizarre Adventure",
        "alt_title": "Cuộc Phiêu Lưu Bí Ẩn",
        "image_url":
            "https://upload.wikimedia.org/wikipedia/en/d/d0/Weekly_Sh%C5%8Dnen_Jump_1987_issue_1-2.jpg",
        "description": "Series truyện tranh ăn khách...",
        "author": "Araki Hirohiko",
        "status": "Đang cập nhật",
      },
      {
        "id": 6,
        "title": "Boku No Pico",
        "alt_title": "Pico Của Tôi",
        "image_url":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTtxBllJnASyoJqgk2QFL2y4rwvB746RVqwxQ&s",
        "description": "Một huyền thoại...",
        "author": "Đang cập nhật",
        "status": "Đang cập nhật",
      },
      {
        "id": 7,
        "title": "Onii-Chan Wa Oshimai!",
        "alt_title": "Onii-chan is done for",
        "image_url":
            "https://jpbookstore.com/cdn/shop/products/71lvNFCHjiL_493x700.jpg?v=1651503751",
        "description": "Thấy Neet Onii-chan...",
        "author": "Nekotoufu",
        "status": "Đang cập nhật",
      },
      {
        "id": 8,
        "title": "Sự Quyến Rũ Của 2.5D",
        "image_url":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSUN-wl2dCWNx9XZTeIlduiPU1C9xOiT0bj2w&s",
        "description": "Cosplay , gái cute...",
        "author": "Atsushi Hashimoto",
        "status": "Đang cập nhật",
      },
      {
        "id": 9,
        "title": "Grand Blue",
        "image_url":
            "https://upload.wikimedia.org/wikipedia/vi/e/e4/Grand_Blue_volume_1_cover.jpg",
        "description": "Giữa thị trấn ven biển...",
        "author": "Đang cập nhật",
        "status": "Đang cập nhật",
      },
    ];

    for (var m in mangaData) {
      final exists = await db.query(
        'mangas',
        where: 'id = ?',
        whereArgs: [m['id']],
      );
      if (exists.isEmpty) {
        await db.insert('mangas', m);
      }
    }
  }

  Future<void> _seedMangaCategoryMapping(Database db) async {
    final list = [
      {"manga_id": 1, "category_id": 1},
      {"manga_id": 1, "category_id": 4},
      {"manga_id": 1, "category_id": 11},
      {"manga_id": 1, "category_id": 18},
      {"manga_id": 1, "category_id": 19},
      {"manga_id": 2, "category_id": 1},
      {"manga_id": 2, "category_id": 15},
      {"manga_id": 2, "category_id": 18},
      {"manga_id": 3, "category_id": 1},
      {"manga_id": 3, "category_id": 5},
      {"manga_id": 3, "category_id": 11},
      {"manga_id": 4, "category_id": 8},
      {"manga_id": 4, "category_id": 14},
      {"manga_id": 4, "category_id": 16},
      {"manga_id": 4, "category_id": 20},
      {"manga_id": 5, "category_id": 1},
      {"manga_id": 5, "category_id": 3},
      {"manga_id": 5, "category_id": 7},
      {"manga_id": 5, "category_id": 12},
      {"manga_id": 5, "category_id": 15},
      {"manga_id": 5, "category_id": 17},
      {"manga_id": 5, "category_id": 18},
      {"manga_id": 6, "category_id": 1},
      {"manga_id": 6, "category_id": 7},
      {"manga_id": 6, "category_id": 10},
      {"manga_id": 6, "category_id": 13},
      {"manga_id": 7, "category_id": 8},
      {"manga_id": 7, "category_id": 9},
      {"manga_id": 7, "category_id": 14},
      {"manga_id": 7, "category_id": 16},
      {"manga_id": 7, "category_id": 21},
      {"manga_id": 8, "category_id": 12},
      {"manga_id": 8, "category_id": 13},
      {"manga_id": 8, "category_id": 14},
      {"manga_id": 8, "category_id": 16},
      {"manga_id": 9, "category_id": 3},
      {"manga_id": 9, "category_id": 9},
      {"manga_id": 9, "category_id": 13},
      {"manga_id": 9, "category_id": 16},
    ];

    for (var mc in list) {
      final exists = await db.query(
        'manga_categories',
        where: 'manga_id = ? AND category_id = ?',
        whereArgs: [mc['manga_id'], mc['category_id']],
      );
      if (exists.isEmpty) {
        await db.insert('manga_categories', mc);
      }
    }
  }

  // --- 3. CÁC HÀM NGHIỆP VỤ (GIỮ NGUYÊN) ---

  String get currentUserId =>
      fb.FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  Future<List<Map<String, dynamic>>> fetchMangas() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT m.*, (SELECT chapter_name FROM chapters WHERE manga_id = m.id ORDER BY id DESC LIMIT 1) as latest_chapter
      FROM mangas m
    ''');
  }

  Future<void> saveHistory(int mangaId, int chapterId) async {
    final db = await database;
    await db.insert('history', {
      'user_id': currentUserId,
      'manga_id': mangaId,
      'last_chapter_id': chapterId,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> toggleFavorite(int mangaId) async {
    final db = await database;
    final userId = currentUserId;
    final maps = await db.query(
      'favorites',
      where: 'user_id = ? AND manga_id = ?',
      whereArgs: [userId, mangaId],
    );
    if (maps.isNotEmpty) {
      await db.delete(
        'favorites',
        where: 'user_id = ? AND manga_id = ?',
        whereArgs: [userId, mangaId],
      );
    } else {
      await db.insert('favorites', {'user_id': userId, 'manga_id': mangaId});
    }
  }

  Future<void> removeFavorite(int mangaId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'user_id = ? AND manga_id = ?',
      whereArgs: [currentUserId, mangaId],
    );
  }

  // Thay thế hàm cũ (khoảng dòng 348) bằng hàm này:
  Future<int> updateManga(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'mangas',
      data, // Chấp nhận tất cả các trường: title, description, genres, image_url...
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> fetchMangasByCategory(
    String categoryName,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT m.*, (SELECT chapter_name FROM chapters WHERE manga_id = m.id ORDER BY id DESC LIMIT 1) as latest_chapter
      FROM mangas m
      JOIN manga_categories mc ON m.id = mc.manga_id
      JOIN categories c ON mc.category_id = c.id
      WHERE c.name = ?
    ''',
      [categoryName],
    );
  }

  Future<List<Map<String, dynamic>>> fetchFavorites() async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT m.*, (SELECT chapter_name FROM chapters WHERE manga_id = m.id ORDER BY id DESC LIMIT 1) as latest_chapter
      FROM mangas m
      JOIN favorites f ON m.id = f.manga_id
      WHERE f.user_id = ?
    ''',
      [currentUserId],
    );
  }

  Future<List<Map<String, dynamic>>> fetchHistory() async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT h.*, m.title as manga_title, m.image_url as manga_image, m.author as manga_author, 
             m.description as manga_desc, c.chapter_name as last_chapter_name
      FROM history h
      JOIN mangas m ON h.manga_id = m.id
      JOIN chapters c ON h.last_chapter_id = c.id
      WHERE h.user_id = ?
      ORDER BY h.updated_at DESC
    ''',
      [currentUserId],
    );
  }

  Future<List<Map<String, dynamic>>> searchMangas(String query) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT m.*, (SELECT chapter_name FROM chapters WHERE manga_id = m.id ORDER BY id DESC LIMIT 1) as latest_chapter
      FROM mangas m
      WHERE m.title LIKE ?
    ''',
      ['%$query%'],
    );
  }

  Future<void> deleteHistory(int mangaId) async {
    final db = await database;
    await db.delete(
      'history',
      where: 'user_id = ? AND manga_id = ?',
      whereArgs: [currentUserId, mangaId],
    );
  }

  Future<List<Map<String, dynamic>>> fetchComments(int mangaId) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT c.*, u.username FROM comments c
      LEFT JOIN users u ON c.user_id = u.id
      WHERE c.manga_id = ?
      ORDER BY c.created_at DESC
    ''',
      [mangaId],
    );
  }

  Future<void> addComment(int mangaId, String content) async {
    final db = await database;
    await db.insert('comments', {
      'manga_id': mangaId,
      'user_id': currentUserId,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<String>> fetchCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => maps[i]['name'] as String);
  }

  Future<Map<String, dynamic>?> getMangaById(int id) async {
    final db = await database;
    final results = await db.query('mangas', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> fetchChapters(int mangaId) async {
    final db = await database;
    return await db.query(
      'chapters',
      where: 'manga_id = ?',
      whereArgs: [mangaId],
      orderBy: 'id ASC',
    );
  }

  Future<bool> isFavorite(int mangaId) async {
    final db = await database;
    final maps = await db.query(
      'favorites',
      where: 'user_id = ? AND manga_id = ?',
      whereArgs: [currentUserId, mangaId],
    );
    return maps.isNotEmpty;
  }

  Future<List<String>> fetchMangaCategories(int mangaId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT DISTINCT c.name FROM categories c
      JOIN manga_categories mc ON c.id = mc.category_id
      WHERE mc.manga_id = ?
    ''',
      [mangaId],
    );
    return List.generate(maps.length, (i) => maps[i]['name'] as String);
  }

  Future<int> insertChapter(
    int mangaId,
    String chapterName,
    String images,
  ) async {
    final db = await database;
    return await db.insert('chapters', {
      'manga_id': mangaId,
      'chapter_name': chapterName,
      'content_images': images,
    });
  }

  // CREATE: Thêm truyện mới
  Future<int> insertManga(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('mangas', row);
  }

  // DELETE: Xóa truyện (Nhớ dùng CASCADE cho chapters nếu cần)
  Future<int> deleteManga(int id) async {
    final db = await database;
    return await db.delete('mangas', where: 'id = ?', whereArgs: [id]);
  }

  // --- QUẢN LÝ THỂ LOẠI (CATEGORIES) ---

  // 1. Lấy toàn bộ thông tin thể loại (gồm cả ID và Name)
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories', orderBy: 'name ASC');
  }

  // 2. Thêm thể loại mới
  Future<int> insertCategory(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(
      'categories',
      row,
      conflictAlgorithm:
          ConflictAlgorithm.ignore, // Tránh trùng tên nếu bạn đặt UNIQUE
    );
  }

  // 3. Xóa thể loại theo ID
  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Thêm vào DatabaseHelper
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'created_at DESC');
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> syncAllCounts() async {
    final db = await DatabaseHelper().database;
    // Lấy danh sách ID truyện
    final List<Map<String, dynamic>> mangas = await db.query('mangas');

    for (var manga in mangas) {
      int id = manga['id'];
      final List<Map<String, dynamic>> count = await db.rawQuery(
        'SELECT COUNT(*) as total FROM chapters WHERE manga_id = ?',
        [id],
      );
      int total = count.first['total'] as int;

      await db.update(
        'mangas',
        {'latest_chapter': 'Chương $total'},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // Bạn có thể tạm thời viết hàm này để sửa database hiện tại
  Future<void> addGenresColumn() async {
    final db = await database;
    try {
      await db.execute("ALTER TABLE mangas ADD COLUMN genres TEXT;");
      print("Đã thêm cột genres thành công!");
    } catch (e) {
      print("Cột đã tồn tại hoặc có lỗi: $e");
    }
  }
}

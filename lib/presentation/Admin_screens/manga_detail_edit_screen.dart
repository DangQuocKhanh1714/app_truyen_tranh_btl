import 'package:app_truyen_tranh/core/constants.dart';
import 'package:app_truyen_tranh/data/models/manga_model.dart';
import 'package:app_truyen_tranh/data/services/database_helper.dart';
import 'package:app_truyen_tranh/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:app_truyen_tranh/presentation/Admin_screens/manga_chapter_screen.dart';

class MangaDetailEditScreen extends StatefulWidget {
  final Map<String, dynamic> manga;

  const MangaDetailEditScreen({super.key, required this.manga});

  @override
  State<MangaDetailEditScreen> createState() => _MangaDetailEditScreenState();
}

class _MangaDetailEditScreenState extends State<MangaDetailEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descController;

  List<String> selectedGenres = [];
  List<String> allGenres = [];
  bool _isLoadingGenres = true;

  @override
void initState() {
  super.initState();
  _titleController = TextEditingController(text: widget.manga['title']);
  _authorController = TextEditingController(text: widget.manga['author']);
  _descController = TextEditingController(text: widget.manga['description']);

  // 1. Khởi tạo danh sách các thể loại đã được chọn của truyện
  if (widget.manga['genres'] != null && widget.manga['genres'].toString().isNotEmpty) {
    selectedGenres = widget.manga['genres'].toString().split(', ').toList();
  } else {
    selectedGenres = [];
  }

  // 2. QUAN TRỌNG: Phải gọi hàm này để tải danh sách nhãn dán từ DB lên
  _loadGenresFromDatabase(); 
}

  Future<void> _loadGenresFromDatabase() async {
    try {
      final db = await DatabaseHelper().database;
      final List<Map<String, dynamic>> maps = await db.query('categories');

      setState(() {
        allGenres = maps.map((item) => item['name'] as String).toList();
        _isLoadingGenres = false;
      });
    } catch (e) {
      debugPrint("Lỗi tải thể loại: $e");
      setState(() => _isLoadingGenres = false);
    }
  }

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty) {
      // Thông báo lỗi...
      return;
    }

    try {
      final db = await DatabaseHelper().database;
      
      // Chuyển List thành String để lưu vào cột TEXT trong SQLite
      String genresToSave = selectedGenres.join(', ');
      debugPrint("Đang lưu thể loại: $genresToSave"); // Xem nó có in ra đúng không

      final Map<String, dynamic> updatedData = {
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'description': _descController.text.trim(),
        'genres': genresToSave, 
      };

      int result = await db.update(
        'mangas',
        updatedData,
        where: 'id = ?',
        whereArgs: [widget.manga['id']],
      );

      if (mounted && result > 0) {
        Navigator.pop(context, true); // Quay lại và báo cho Admin load lại
      }
    } catch (e) {
      debugPrint("Lỗi Database: $e");
    }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      // Giới hạn AppBar để không bị tràn màn hình
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxContentWidth,
            ),
            child: const CustomAppBar(),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.maxContentWidth,
          ),
          child: Column(
            children: [
              // Nút back và tiêu đề màn hình nằm trong giới hạn không gian
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: isDark ? Colors.white : Colors.black87,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopSection(theme, isDark),
                        const SizedBox(height: 30),
                        const Text(
                          "Thể loại",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildGenreSection(theme),
                        const SizedBox(height: 30),
                        _buildDescriptionSection(theme, isDark),
                        const SizedBox(height: 40),
                        _buildBottomButtons(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(ThemeData theme, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            widget.manga['image_url'] ?? '',
            width: 110,
            height: 160,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(
              width: 110,
              height: 160,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Tên bộ truyện",
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: "Tác giả",
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenreSection(ThemeData theme) {
  if (_isLoadingGenres) {
    return const Center(child: CircularProgressIndicator());
  }
  
  if (allGenres.isEmpty) {
    return const Text("Không có thể loại nào trong hệ thống", style: TextStyle(color: Colors.grey));
  }

  return Wrap(
    spacing: 8.0,
    runSpacing: 4.0,
    children: allGenres.map((genre) {
      // Chuẩn hóa tên để so sánh chính xác
      final isSelected = selectedGenres.any((element) => element.trim() == genre.trim());
      
      return FilterChip(
        label: Text(genre),
        selected: isSelected,
        selectedColor: Colors.green.withOpacity(0.3),
        checkmarkColor: Colors.green,
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              if (!selectedGenres.contains(genre)) selectedGenres.add(genre);
            } else {
              selectedGenres.removeWhere((element) => element.trim() == genre.trim());
            }
          });
        },
      );
    }).toList(),
  );
}

  Widget _buildDescriptionSection(ThemeData theme, bool isDark) {
    return TextField(
      controller: _descController,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: "Mô tả nội dung",
        alignLabelWithHint: true,
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _handleSave,
            icon: const Icon(Icons.save_rounded, size: 20),
            label: const Text("Lưu thay đổi"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageChaptersScreen(
                    manga: MangaModel(
                      id: widget.manga['id'] ?? 0,
                      title: _titleController.text,
                      imageUrl: widget.manga['image_url'] ?? '',
                      author: _authorController.text,
                      description: _descController.text,
                      latestChapter:
                          widget.manga['latest_chapter'] ?? 'Chưa rõ',
                    ),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Icon(Icons.format_list_bulleted_rounded),
          ),
        ),
      ],
    );
  }
}

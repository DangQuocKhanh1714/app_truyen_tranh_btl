import 'package:app_truyen_tranh/core/constants.dart'; // Đảm bảo có AppConstants.maxContentWidth
import 'package:app_truyen_tranh/data/models/chapter_model.dart';
import 'package:app_truyen_tranh/data/models/manga_model.dart';
import 'package:app_truyen_tranh/core/manga_chapters_manager.dart';
import 'package:app_truyen_tranh/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class ManageChaptersScreen extends StatefulWidget {
  final MangaModel manga;
  const ManageChaptersScreen({super.key, required this.manga});

  @override
  State<ManageChaptersScreen> createState() => _ManageChaptersScreenState();
}

class _ManageChaptersScreenState extends State<ManageChaptersScreen> {
  List<ChapterModel> _chapters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    setState(() => _isLoading = true);
    final data = await MangaChaptersManager.getChapters(widget.manga.id);
    setState(() {
      _chapters = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          // Giới hạn khoảng cách bề ngang cho cả AppBar và Nội dung
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxContentWidth,
            ),
            child: Column(
              children: [
                const CustomAppBar(),

                _buildModernHeader(theme, isDark),

                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _chapters.isEmpty
                      ? Center(
                          child: Text(
                            "Chưa có chương nào",
                            style: TextStyle(color: theme.hintColor),
                          ),
                        )
                      : _buildChapterList(theme, isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  "Chương: ${widget.manga.title}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
              ),
              IconButton(
                onPressed: _showAddChapterDialog,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: theme.primaryColor,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Tổng số: ${_chapters.length} chương",
            style: TextStyle(
              color: theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(height: 25),
        ],
      ),
    );
  }

  Widget _buildChapterList(ThemeData theme, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _chapters.length,
      itemBuilder: (context, index) {
        final chapter = _chapters[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 45,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? Colors.white10 : Colors.grey[200],
              ),
              child: chapter.contentImages.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        chapter.contentImages[0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 20),
                      ),
                    )
                  : const Icon(Icons.image_not_supported),
            ),
            title: Text(
              chapter.chapterName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${chapter.contentImages.length} trang ảnh"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () => _editChapter(chapter),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _confirmDelete(chapter),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Giữ nguyên các hàm Logic (Dialogs) bên dưới của bạn ---
  // (Lưu ý: Bạn có thể cập nhật style các ElevatedButton trong Dialog sang theme.primaryColor)

  void _showAddChapterDialog() {
    final nameController = TextEditingController();
    final urlsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thêm chương mới"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Tên chương (VD: Chương 10)",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: urlsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Link ảnh (mỗi link 1 dòng)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              // Xử lý chuỗi từ TextField thành List<String>
              List<String> images = urlsController.text
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              // Tạo Object ChapterModel khớp với hàm addChapter của bạn
              final newChapter = ChapterModel(
                id: 0, // SQLite tự tăng nên để 0
                mangaId: widget.manga.id,
                chapterName: nameController.text.trim(),
                contentImages: images,
                createdAt: DateTime.now().toIso8601String(),
              );

              await MangaChaptersManager.addChapter(newChapter);

              if (mounted) {
                Navigator.pop(context);
                _loadChapters(); // Hàm reload lại danh sách của bạn
              }
            },
            child: const Text("Lưu chương"),
          ),
        ],
      ),
    );
  }

  void _editChapter(ChapterModel chapter) {
    final nameController = TextEditingController(text: chapter.chapterName);
    // Hiển thị các link ảnh hiện có, mỗi link một dòng
    final urlsController = TextEditingController(
      text: chapter.contentImages.join('\n'),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sửa chương"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Tên chương"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: urlsController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: "Link ảnh"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              List<String> updatedImages = urlsController.text
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              // Tạo Object mới từ dữ liệu đã sửa
              final updatedChapter = ChapterModel(
                id: chapter.id,
                mangaId: chapter.mangaId,
                chapterName: nameController.text.trim(),
                contentImages: updatedImages,
                createdAt: chapter.createdAt,
              );

              await MangaChaptersManager.updateChapter(updatedChapter);

              if (mounted) {
                Navigator.pop(context);
                _loadChapters();
              }
            },
            child: const Text("Cập nhật"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ChapterModel chapter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text(
          "Bạn có chắc chắn muốn xóa ${chapter.chapterName} không?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              // Truyền 2 tham số theo đúng khai báo static Future<void> deleteChapter(int chapterId, int mangaId)
              await MangaChaptersManager.deleteChapter(
                chapter.id,
                widget.manga.id,
              );

              if (mounted) {
                Navigator.pop(context);
                _loadChapters();
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

import 'package:app_truyen_tranh/data/models/chapter_model.dart';
import 'package:app_truyen_tranh/data/models/manga_model.dart';
import 'package:app_truyen_tranh/core/manga_chapters_manager.dart';
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
    // Gọi hàm lấy dữ liệu từ MangaChaptersManager
    final data = await MangaChaptersManager.getChapters(widget.manga.id);
    setState(() {
      _chapters = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quản lý: ${widget.manga.title}", 
          style: const TextStyle(fontSize: 16, color: Colors.white)),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showAddChapterDialog,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _chapters.isEmpty 
                    ? const Center(child: Text("Chưa có chương nào"))
                    : _buildChapterList(),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.grey.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.collections_bookmark_outlined, size: 20, color: Colors.redAccent),
          const SizedBox(width: 10),
          Text("Tổng số: ${_chapters.length} chương", 
            style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChapterList() {
    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemCount: _chapters.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final chapter = _chapters[index];
        return ListTile(
          leading: Container(
            width: 50,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[200],
            ),
            // Sử dụng contentImages theo model mới của bạn
            child: chapter.contentImages.isNotEmpty 
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      chapter.contentImages[0], 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.broken_image, size: 20),
                    ),
                  )
                : const Icon(Icons.image_not_supported),
          ),
          title: Text(chapter.chapterName, 
            style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("ID: ${chapter.id} • ${chapter.contentImages.length} ảnh"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editChapter(chapter),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(chapter),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddChapterDialog() {
    final nameController = TextEditingController();
    final urlsController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Thêm chương mới"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Tên chương",
                  hintText: "Ví dụ: Chương 1",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: urlsController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: "Danh sách Link ảnh",
                  hintText: "Dán mỗi link một dòng...",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  helperText: "Nhập các URL ảnh, ngăn cách bằng xuống dòng",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              
              // Chuyển nội dung TextField thành chuỗi ngăn cách bằng dấu phẩy để lưu DB
              String imagesString = urlsController.text
                  .split('\n')
                  .where((url) => url.trim().isNotEmpty)
                  .map((url) => url.trim())
                  .join(',');

              // Gọi hàm từ Manager đã đồng bộ với DatabaseHelper của bạn
              await MangaChaptersManager.addChapter(
                mangaId: widget.manga.id, 
                name: nameController.text.trim(), 
                images: imagesString
              );

              if (mounted) {
                Navigator.pop(context);
                _loadChapters(); 
              }
            },
            child: const Text("Lưu chương", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editChapter(ChapterModel chapter) {
    final nameController = TextEditingController(text: chapter.chapterName);
    // Chuyển list ảnh ngược lại thành chuỗi có dấu xuống dòng để dễ sửa
    final urlsController = TextEditingController(text: chapter.contentImages.join('\n'));

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
                decoration: const InputDecoration(labelText: "Tên chương", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: urlsController,
                maxLines: 6,
                decoration: const InputDecoration(labelText: "Danh sách Link ảnh", border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              String imagesString = urlsController.text.split('\n').map((e) => e.trim()).join(',');
              await MangaChaptersManager.updateChapter(
                chapterId: chapter.id,
                name: nameController.text,
                images: imagesString,
              );
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
        content: Text("Bạn có chắc chắn muốn xóa ${chapter.chapterName}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Hủy")
          ),
          TextButton(
            onPressed: () async {
              // SỬA TẠI ĐÂY: Truyền cả chapter.id và widget.manga.id
              await MangaChaptersManager.deleteChapter(chapter.id, widget.manga.id);
              
              if (mounted) {
                Navigator.pop(context);
                _loadChapters(); // Load lại danh sách sau khi xóa
              }
            }, 
            child: const Text("Xóa", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}
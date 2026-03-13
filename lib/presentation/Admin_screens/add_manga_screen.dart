import 'package:app_truyen_tranh/core/constants.dart'; // Đảm bảo bạn có file constants chứa maxContentWidth
import 'package:app_truyen_tranh/logic/manga_bloc/manga_bloc.dart';
import 'package:app_truyen_tranh/logic/manga_bloc/manga_event.dart';
import 'package:app_truyen_tranh/presentation/widgets/custom_app_bar.dart'; // Import CustomAppBar của bạn
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_truyen_tranh/data/services/database_helper.dart';
import 'manage_mangas_screen.dart';

class AddMangaScreen extends StatefulWidget {
  const AddMangaScreen({super.key});

  @override
  State<AddMangaScreen> createState() => _AddMangaScreenState();
}

class _AddMangaScreenState extends State<AddMangaScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _urlController.clear(); 
      });
    }
  }

  Future<void> _handleSaveManga() async {
    final String title = _nameController.text.trim();
    String imageUrl = _urlController.text.trim();

    if (_imageFile != null) {
      imageUrl = _imageFile!.path;
    }

    if (title.isEmpty || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên và chọn ảnh cho truyện!")),
      );
      return;
    }

    try {
      await DatabaseHelper().insertManga({
        'title': title,
        'image_url': imageUrl,
        'description': 'Truyện mới được thêm bởi người dùng.',
        'author': 'Đang cập nhật',
        'status': 'Đang cập nhật',
        'views': 0,
        'likes': 0,
      });

      if (mounted) {
        context.read<MangaBloc>().add(LoadMangaEvent());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã tạo truyện thành công!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ManageMangasScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lưu: $e")),
      );
    }
  }

  // ... các phần import giữ nguyên ...

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: null, 
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Để các thành phần con căn lề trái
              children: [
                // 1. AppBar ở trên cùng
                const CustomAppBar(),

                // 2. Nút Back nằm ở hàng riêng bên dưới AppBar
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // 3. Phần nội dung nhập liệu
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Đã có nút Back ở trên nên có thể giảm bớt khoảng cách này nếu cần
                        const SizedBox(height: 10),

                        const Text("Tên truyện", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: "Nhập tên truyện...",
                            filled: true,
                            fillColor: theme.cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.dividerColor),
                            ),
                          ),
                        ),
                        
                        // ... Giữ nguyên toàn bộ phần chọn ảnh và nút lưu bên dưới ...
                        const SizedBox(height: 25),
                        const Text("Ảnh bìa truyện", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              height: 160,
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: _imageFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(11),
                                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                                    )
                                  : (_urlController.text.isNotEmpty 
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(11),
                                          child: Image.network(
                                            _urlController.text, 
                                            fit: BoxFit.cover, 
                                            errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 40)
                                          ),
                                        )
                                      : const Icon(Icons.image_outlined, size: 40)),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.photo_library),
                                    label: const Text("Chọn thư viện"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.primaryColor,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 45),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text("Hoặc dán URL"),
                                  ),
                                  TextField(
                                    controller: _urlController,
                                    onChanged: (value) => setState(() {}),
                                    decoration: InputDecoration(
                                      hintText: "https://...",
                                      isDense: true,
                                      filled: true,
                                      fillColor: theme.cardColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: theme.dividerColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _handleSaveManga,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            child: const Text(
                              "TẠO TRUYỆN & TIẾP TỤC",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
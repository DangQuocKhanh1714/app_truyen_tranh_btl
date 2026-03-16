import 'package:app_truyen_tranh/core/constants.dart';
import 'package:app_truyen_tranh/logic/manga_bloc/manga_bloc.dart';
import 'package:app_truyen_tranh/logic/manga_bloc/manga_event.dart';
import 'package:app_truyen_tranh/logic/manga_bloc/manga_state.dart';
import 'package:app_truyen_tranh/presentation/Admin_screens/manga_detail_edit_screen.dart';
import 'package:app_truyen_tranh/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_truyen_tranh/logic/auth_bloc/auth_bloc.dart';
import 'package:app_truyen_tranh/logic/auth_bloc/auth_state.dart';
import 'package:app_truyen_tranh/data/services/database_helper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ManageMangasScreen extends StatefulWidget {
  const ManageMangasScreen({super.key});

  @override
  State<ManageMangasScreen> createState() => _ManageMangasScreenState();
}

class _ManageMangasScreenState extends State<ManageMangasScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      if (authState.role != "admin") {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
        });
      }
    }
  }

  // Hàm xử lý khi nhấn Cập nhật - Đợi kết quả trả về để refresh
  Future<void> _navigateToEdit(BuildContext context, dynamic manga) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MangaDetailEditScreen(manga: manga.toJson()),
      ),
    );

    // Nếu quay lại và có tín hiệu thành công (result == true)
    if (result == true && mounted) {
      context.read<MangaBloc>().add(LoadMangaEvent()); // Refresh lại danh sách
    }
  }

  Future<void> _showComments(BuildContext context, int mangaId) async {
    final comments = await DatabaseHelper().fetchComments(mangaId);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Bình luận"),
          content: SizedBox(
            width: 400,
            height: 300,
            child: comments.isEmpty
                ? const Center(child: Text("Chưa có bình luận"))
                : ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final c = comments[index];

                      final authState = context.read<AuthBloc>().state;
                      final bool isAdmin =
                          authState is AuthAuthenticated &&
                          authState.role == "admin";

                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(c['username'] ?? "User"),
                        subtitle: Text(c['content']),
                        trailing: isAdmin
                            ? IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await DatabaseHelper().deleteComment(c['id']);
                                  Navigator.pop(context);
                                  _showComments(context, mangaId);
                                },
                              )
                            : null,
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Đóng"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadMangaImage(BuildContext context, dynamic manga) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      try {
        final db = await DatabaseHelper().database;
        await db.update(
          'mangas',
          {'image_url': image.path},
          where: 'id = ?',
          whereArgs: [manga.id],
        );

        if (mounted) {
          context.read<MangaBloc>().add(LoadMangaEvent()); // Refresh danh sách
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cập nhật ảnh thành công!")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi cập nhật ảnh: $e")),
          );
        }
      }
    }
  }

  Widget _buildMangaImage(String path) {
    if (path.isEmpty) {
      return const SizedBox(
        width: 80,
        height: 110,
        child: Icon(Icons.broken_image),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      child: path.startsWith('http')
          ? Image.network(
              path,
              width: 80,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image),
            )
          : Image.file(
              File(path),
              width: 80,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: null,
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxContentWidth,
            ),
            child: Column(
              children: [
                const CustomAppBar(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    "QUẢN LÝ HỆ THỐNG TRUYỆN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                      letterSpacing: 1.2,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<MangaBloc, MangaState>(
                    builder: (context, state) {
                      if (state is MangaLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is MangaLoaded) {
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultPadding,
                          ),
                          itemCount: state.mangas.length,
                          itemBuilder: (context, index) {
                            final manga = state.mangas[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.dividerColor.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildMangaImage(manga.imageUrl),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
             
             
                                      mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            manga.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            manga.latestChapter ??
                                                'Chưa có chương',
                                            style: TextStyle(
                                              color: theme.primaryColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton.icon(
                                                onPressed: () => _uploadMangaImage(
                                                  context,
                                                  manga,
                                                ),
                                                icon: const Icon(Icons.photo_camera, size: 16),
                                                label: const Text("Upload Ảnh"),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.blue,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () => _showComments(
                                                  context,
                                                  manga.id,
                                                ),
                                                child: const Text(
                                                  "Bình luận",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    _navigateToEdit(
                                                      context,
                                                      manga,
                                                    ),
                                                child: Text(
                                                  "Cập nhật >",
                                                  style: TextStyle(
                                                    color: theme.primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: Text("Lỗi tải dữ liệu"));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.brightness == Brightness.dark
                            ? Colors.grey.shade900
                            : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "QUAY LẠI TRANG QUẢN TRỊ",
                        style: TextStyle(color: Colors.white),
                      ),
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

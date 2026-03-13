import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io'; // Cần thiết để đọc file từ bộ nhớ máy
import '../../data/models/manga_model.dart';
import '../../logic/favorite_bloc/favorite_bloc.dart';
import '../../logic/favorite_bloc/favorite_event.dart';
import '../screens/manga_detail_screen.dart';

class MangaCard extends StatelessWidget {
  final MangaModel manga;
  final String? customSubtitle;

  const MangaCard({super.key, required this.manga, this.customSubtitle});

  // HÀM HIỂN THỊ ẢNH THÔNG MINH: Tự nhận diện URL hoặc Local File
  Widget _buildMangaImage(ThemeData theme) {
    final String path = manga.imageUrl;

    // Kiểm tra nếu đường dẫn rỗng
    if (path.isEmpty) {
      return _buildErrorPlaceholder(theme);
    }

    // Nếu là link web (http/https)
    if (path.startsWith('http') || path.startsWith('https')) {
      return Image.network(
        path,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        // Hiển thị loading khi đang tải ảnh từ web
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(theme),
      );
    } 
    // Nếu là đường dẫn file cục bộ (sau khi dùng ImagePicker)
    else {
      return Image.file(
        File(path),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(theme),
      );
    }
  }

  // Widget hiển thị khi ảnh lỗi hoặc không tìm thấy
  Widget _buildErrorPlaceholder(ThemeData theme) {
    return Container(
      color: theme.dividerColor.withOpacity(0.1),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 40, color: Colors.grey),
          SizedBox(height: 4),
          Text("No Image", style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaDetailScreen(manga: manga),
          ),
        );

        // Nếu quay lại từ màn hình chi tiết và có thay đổi (like/fav), load lại danh sách yêu thích
        if (result == true && context.mounted) {
          context.read<FavoriteBloc>().add(LoadFavoritesEvent());
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Phần hình ảnh (Chiếm 4 phần)
              Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    _buildMangaImage(theme), // Gọi hàm hiển thị ảnh thông minh
                    
                    // Lớp phủ Gradient mờ ở đáy ảnh để làm nổi bật text (nếu cần)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Phần thông tin chữ
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên truyện
                    Text(
                      manga.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // Hiển thị Chương mới nhất
                    Row(
                      children: [
                        Icon(
                          Icons.chrome_reader_mode_outlined,
                          size: 12,
                          color: theme.colorScheme.primary.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            customSubtitle ?? manga.latestChapter,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:app_truyen_tranh/core/app_state.dart';
import 'package:app_truyen_tranh/core/constants.dart';
import 'package:app_truyen_tranh/core/manga_chapters_manager.dart';
import 'package:app_truyen_tranh/presentation/screens/category_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/manga_model.dart';
import '../../data/models/chapter_model.dart';
import '../../data/services/database_helper.dart';
import '../../logic/history_bloc/history_bloc.dart';
import '../../logic/history_bloc/history_event.dart';
import '../widgets/quick_menu.dart';
import '../widgets/custom_app_bar.dart';
import 'chapter_detail_screen.dart';

class MangaDetailScreen extends StatefulWidget {
  final MangaModel manga;
  const MangaDetailScreen({super.key, required this.manga});

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  bool _showQuickMenu = false;
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final status = await DatabaseHelper().isFavorite(widget.manga.id);
    if (mounted) {
      setState(() {
        _isFavorite = status;
      });
    }
  }

  void _showAllCategoriesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder<List<String>>(
          future: DatabaseHelper().fetchCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("Chưa có thể loại nào"),
              );
            }

            final categories = snapshot.data!;
            return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, controller) => Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      "Khám phá thể loại",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) => ListTile(
                        title: Text(
                          categories[index],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryResultScreen(
                                categoryName: categories[index],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleToggleFavorite() async {
    if (_isLoadingFavorite) return;

    setState(() => _isLoadingFavorite = true);
    await DatabaseHelper().toggleFavorite(widget.manga.id);
    final newStatus = await DatabaseHelper().isFavorite(widget.manga.id);

    if (mounted) {
      setState(() {
        _isFavorite = newStatus;
        _isLoadingFavorite = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? "Đã thêm vào yêu thích" : "Đã xóa khỏi yêu thích",
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: _isFavorite ? Colors.redAccent : Colors.grey[800],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, true);
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxContentWidth,
            ),
            child: Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPersistentHeader(
                      floating: true,
                      delegate: _SliverHeaderDelegate(
                        child: Container(
                          color: const Color(0xFFFF5252),
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top,
                          ),
                          child: CustomAppBar(
                            searchController: _searchController,
                            onCategoryTap: _showAllCategoriesSheet,
                          ),
                        ),
                        height: 70 + MediaQuery.of(context).padding.top,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Image.network(
                                widget.manga.imageUrl,
                                width: double.infinity,
                                fit: BoxFit.fitWidth,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: 450,
                                      color: Colors.grey[900],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.white24,
                                        size: 50,
                                      ),
                                    ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        backgroundColor.withOpacity(0.8),
                                        backgroundColor,
                                      ],
                                      stops: const [0.6, 0.9, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 32,
                                left: 15,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context, true),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          _buildMangaInfo(widget.manga),
                        ],
                      ),
                    ),
                    _buildChapterListSliver(),
                    _buildCommentSection(),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
                QuickMenu(
                  show: _showQuickMenu,
                  onHomeTap: () {
                    Navigator.pop(context, true);
                    AppState.changeTab(0, context);
                  },
                  onFavoriteTap: () {
                    Navigator.pop(context, true);
                    AppState.changeTab(1, context);
                  },
                  onHistoryTap: () {
                    Navigator.pop(context, true);
                    AppState.changeTab(2, context);
                  },
                  onProfileTap: () {
                    Navigator.pop(context, true);
                    AppState.changeTab(3, context);
                  },
                  onCloseTap: () => setState(() => _showQuickMenu = false),
                ),
                if (!_showQuickMenu)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      heroTag: 'manga_detail_fab',
                      backgroundColor: Colors.redAccent,
                      onPressed: () => setState(() => _showQuickMenu = true),
                      child: const Icon(
                        Icons.menu_open_rounded,
                        color: Colors.white,
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

  Widget _buildMangaInfo(MangaModel manga) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            manga.title,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: Colors.redAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "Tác giả: ${manga.author}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.update, color: Colors.blueAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                (widget.manga.latestChapter.isEmpty ||
                        widget.manga.latestChapter == 'null')
                    ? "Trạng thái: Đang cập nhật"
                    : "Mới nhất: ${widget.manga.latestChapter}",
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCategories(),
          const SizedBox(height: 20),
          _buildFavoriteButton(),
          const SizedBox(height: 30),
          const Text(
            "Giới thiệu",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            manga.description,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Danh sách chương",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.redAccent, height: 40, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _handleToggleFavorite,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _isFavorite
              ? Colors.redAccent
              : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFavorite
                ? Colors.redAccent
                : (isDark ? Colors.white24 : Colors.black12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite
                  ? Colors.white
                  : Theme.of(context).iconTheme.color,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              _isFavorite ? "Đã theo dõi" : "Thêm vào yêu thích",
              style: TextStyle(
                color: _isFavorite
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterListSliver() {
    return FutureBuilder<List<ChapterModel>>(
      future: MangaChaptersManager.getChapters(widget.manga.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: Colors.redAccent),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Text(
                "Chưa có chương nào",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final chapters = snapshot.data!;
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final chapter = chapters[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black.withOpacity(0.05),
                ),
              ),
              child: ListTile(
                title: Text(
                  chapter.chapterName,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).hintColor,
                  size: 20,
                ),
                onTap: () async {
                  await DatabaseHelper().saveHistory(
                    widget.manga.id,
                    chapter.id,
                  );
                  if (mounted) {
                    context.read<HistoryBloc>().add(LoadHistoryEvent());
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChapterDetailScreen(chapter: chapter),
                      ),
                    );
                    if (result == true) _checkFavoriteStatus();
                  }
                },
              ),
            );
          }, childCount: chapters.length),
        );
      },
    );
  }

  Widget _buildCategories() {
    return FutureBuilder<List<String>>(
      future: DatabaseHelper().fetchMangaCategories(widget.manga.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const SizedBox.shrink();
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: snapshot.data!.map((cat) => _categoryChip(cat)).toList(),
        );
      },
    );
  }

  Widget _categoryChip(String label) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryResultScreen(categoryName: label),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildCommentSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bình luận",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            FutureBuilder(
              future: DatabaseHelper().fetchComments(widget.manga.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final comments = snapshot.data as List;

                if (comments.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Chưa có bình luận"),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final c = comments[index];

                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(c['username'] ?? "User"),
                      subtitle: Text(c['content']),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Nhập bình luận...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.redAccent,
                  onPressed: () async {
                    if (_commentController.text.trim().isEmpty) return;

                    final userId = DatabaseHelper().currentUserId;

                    await DatabaseHelper().addComment(
                      widget.manga.id,
                      userId,
                      _commentController.text.trim(),
                    );

                    _commentController.clear();

                    setState(() {});
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  _SliverHeaderDelegate({required this.child, required this.height});
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox.expand(child: child);
  @override
  double get maxExtent => height;
  @override
  double get minExtent => height;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

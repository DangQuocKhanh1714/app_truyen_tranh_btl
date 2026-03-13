import 'package:app_truyen_tranh/core/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth_bloc/auth_bloc.dart';
import '../../logic/auth_bloc/auth_state.dart';
import '../../logic/favorite_bloc/favorite_bloc.dart';
import '../../logic/favorite_bloc/favorite_event.dart';
import '../../logic/favorite_bloc/favorite_state.dart';
import '../../presentation/widgets/manga_card.dart';
import '../widgets/custom_app_bar.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FavoriteBloc>().add(LoadFavoritesEvent());
    }
  }

  void _showDeleteDialog(BuildContext context, dynamic manga) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Bỏ yêu thích"),
          content: Text("Bạn có muốn xóa '${manga.title}' khỏi danh sách yêu thích?"),
          actions: [
            TextButton(
              child: const Text("Hủy"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Bỏ yêu thích", style: TextStyle(color: Colors.red)),
              onPressed: () {
                context.read<FavoriteBloc>().add(RemoveFavoriteQuickEvent(manga.id));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã xóa khỏi yêu thích")),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthAuthenticated) {
            _loadData();
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is AuthAuthenticated) {
              return BlocConsumer<FavoriteBloc, FavoriteState>(
                listener: (context, state) {
                  if (state is FavoriteError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message), 
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, favoriteState) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadData();
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    color: Colors.redAccent,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverAppBar(
                          floating: true,
                          snap: true,
                          backgroundColor: const Color(0xFFFF5252),
                          expandedHeight: 65,
                          flexibleSpace: const CustomAppBar(),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        
                        if (favoriteState is FavoriteLoading)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
                          )
                        else if (favoriteState is FavoriteLoaded) ...[
                          if (favoriteState.favoriteMangas.isEmpty)
                            _buildEmptyState()
                          else
                            _buildFavoriteGrid(favoriteState.favoriteMangas),
                        ] else ...[
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: Text("Có lỗi xảy ra, vui lòng thử lại.", style: TextStyle(color: Colors.grey))),
                          )
                        ],
                      ],
                    ),
                  );
                },
              );
            }
            return _buildLoginNotice(context, "Yêu thích");
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text(
              "Chưa có truyện nào trong danh sách", 
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteGrid(List favoriteMangas) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final manga = favoriteMangas[index];
            return Stack(
              children: [
                MangaCard(
                  key: ValueKey(manga.id),
                  manga: manga,
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () => _showDeleteDialog(context, manga),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite, color: Colors.red, size: 20),
                    ),
                  ),
                ),
              ],
            );
          },
          childCount: favoriteMangas.length,
        ),
      ),
    );
  }

  Widget _buildLoginNotice(BuildContext context, String feature) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            "Vui lòng đăng nhập để xem\ndanh sách $feature",
            textAlign: TextAlign.center, 
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, 
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => AppState.changeTab(3, context),
            child: const Text("Đăng nhập ngay", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
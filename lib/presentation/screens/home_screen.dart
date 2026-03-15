// import 'package:app_truyen_tranh/presentation/Admin_screens/admin_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/app_state.dart';
import '../../core/constants.dart';
import '../../data/models/manga_model.dart';
import '../../data/services/database_helper.dart';
import '../../logic/auth_bloc/auth_bloc.dart';
import '../../logic/auth_bloc/auth_state.dart';
import '../../logic/manga_bloc/manga_bloc.dart';
import '../../logic/manga_bloc/manga_event.dart';
import '../../logic/manga_bloc/manga_state.dart';
import '../../logic/search_bloc/search_bloc.dart';
import '../../logic/search_bloc/search_event.dart';
import '../../logic/search_bloc/search_state.dart';
import '../widgets/manga_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import 'favorite_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'category_result_screen.dart';
import 'manga_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    DatabaseHelper().seedData().then((_) {
      if (mounted) {
        context.read<MangaBloc>().add(LoadMangaEvent());
      }
    });

    AppState.navigationIndex.addListener(_updateUIFromAppState);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    AppState.navigationIndex.removeListener(_updateUIFromAppState);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _updateUIFromAppState() {
    if (mounted) {
      setState(() {
        _selectedIndex = AppState.navigationIndex.value;
      });
    }
  }

  void _onSearchChanged() {
    context.read<SearchBloc>().add(OnQueryChanged(_searchController.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        bool isAdmin = false;
        if (authState is AuthAuthenticated) {
          isAdmin = authState.role == 'admin';
        }

        final List<Widget> _screens = [
          _buildHomeContent(isAdmin),
          const FavoriteScreen(),
          const HistoryScreen(),
          const ProfileScreen(),
        ];

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxContentWidth,
              ),
              child: Stack(
                children: [
                  IndexedStack(index: _selectedIndex, children: _screens),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: CustomBottomNav(
                          currentIndex: _selectedIndex,
                          onTap: (index) {
                            setState(() {
                              _selectedIndex = index;
                              AppState.navigationIndex.value = index;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- NỘI DUNG TRANG CHỦ ---
  Widget _buildHomeContent(bool isAdmin) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, searchState) {
        final showSuggestions =
            _searchController.text.isNotEmpty && searchState is SearchLoaded;

        return Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  elevation: 0,
                  toolbarHeight: 75,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: CustomAppBar(
                    searchController: _searchController,
                    onCategoryTap: () => _showCategoryBottomSheet(context),
                  ),
                ),

                if (isAdmin)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                      child: InkWell(
                        onTap: () {
                          // --- ĐIỀU HƯỚNG ĐẾN ADMIN MANAGEMENT ---
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (_) => const AdminManagementScreen()),
                          // );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings,
                                  color: Colors.amber,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Bảng điều khiển Admin",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Quản lý truyện, chương và người dùng",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white54,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                _buildMangaSection(),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
            if (showSuggestions)
              Positioned(
                top: 75,
                left: 10,
                right: 10,
                child: _buildSuggestionsDropdown(searchState.results),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSuggestionsDropdown(List<MangaModel> results) {
    if (results.isEmpty) return const SizedBox.shrink();
    final displayResults = results.take(5).toList();

    return Material(
      elevation: 12,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      color: Theme.of(context).cardColor,
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayResults.length,
        itemBuilder: (context, index) {
          final manga = displayResults[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                manga.imageUrl,
                width: 35,
                height: 35,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 35),
              ),
            ),
            title: Text(manga.title, style: const TextStyle(fontSize: 13)),
            onTap: () {
              _searchController.clear();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MangaDetailScreen(manga: manga),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMangaSection() {
    return BlocBuilder<MangaBloc, MangaState>(
      builder: (context, mangaState) {
        if (mangaState is MangaLoaded) {
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => MangaCard(manga: mangaState.mangas[index]),
                childCount: mangaState.mangas.length,
              ),
            ),
          );
        }
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  void _showCategoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
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
              padding: EdgeInsets.all(15),
              child: Text(
                "Khám phá thể loại",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: DatabaseHelper().fetchCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  return ListView.builder(
                    controller: controller,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(snapshot.data![index]),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryResultScreen(
                              categoryName: snapshot.data![index],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

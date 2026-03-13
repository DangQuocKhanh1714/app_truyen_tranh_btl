import 'package:app_truyen_tranh/core/constants.dart';
import 'package:app_truyen_tranh/data/services/database_helper.dart';
import 'package:app_truyen_tranh/logic/manga_bloc/manga_bloc.dart';
import 'package:app_truyen_tranh/logic/manga_bloc/manga_event.dart';
import 'package:app_truyen_tranh/logic/search_bloc/search_bloc.dart';
import 'package:app_truyen_tranh/logic/search_bloc/search_event.dart';
import 'package:app_truyen_tranh/logic/theme_bloc/theme_bloc.dart';
import 'package:app_truyen_tranh/presentation/screens/category_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final VoidCallback? onCategoryTap;

  const CustomAppBar({
    super.key,
    this.searchController,
    this.onSearchChanged,
    this.onCategoryTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(65.0);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
  duration: const Duration(milliseconds: 120), // tốc độ chuyển màu nhanh
  color: theme.primaryColor,
  child: SafeArea(
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 120), // tốc độ chuyển màu nhanh
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
          child: Row(
            children: [
              // Logo
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      'https://api.dicebear.com/7.x/bottts/png?seed=Paimon&backgroundColor=ff4d4d',
                      height: 45,
                      width: 45,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          width: 45,
                          height: 45,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 45,
                          height: 45,
                          color: Colors.grey,
                          child: const Icon(Icons.error, color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 5),

              // Search TextField
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        context.read<SearchBloc>().add(ClearSearch());
                        context.read<MangaBloc>().add(LoadMangaEvent()); 
                      } else {
                        context.read<SearchBloc>().add(OnQueryChanged(value));
                      }
                    },
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "Tìm truyện...",
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white70,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),

              // Category Button
              IconButton(
                icon: const Icon(
                  Icons.format_list_bulleted_rounded,
                  color: Colors.white,
                ),
                onPressed: () => _showCategoryBottomSheet(context),
              ),

              // Theme Toggle
              BlocBuilder<ThemeBloc, ThemeMode>(
                builder: (context, mode) {
                  return IconButton(
                    icon: Icon(
                      mode == ThemeMode.dark
                          ? Icons.lightbulb
                          : Icons.lightbulb_outline,
                      color: mode == ThemeMode.dark
                          ? Colors.yellow
                          : Colors.white,
                    ),
                    onPressed: () {
                      context.read<ThemeBloc>().add(ToggleThemeEvent());
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => DraggableScrollableSheet(
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
              child: FutureBuilder<List<String>>(
                future: DatabaseHelper().fetchCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.separated(
                    controller: controller,
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) => ListTile(
                      title: Text(
                        snapshot.data![index],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 20),
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


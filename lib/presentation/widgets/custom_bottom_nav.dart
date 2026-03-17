import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isAdmin;
  final VoidCallback? onAdminTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isAdmin = false,
    this.onAdminTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Định nghĩa các item cố định
    const exploreItem = BottomNavigationBarItem(
      icon: Icon(Icons.explore_outlined),
      activeIcon: Icon(Icons.explore),
      label: "Khám phá",
    );
    const favoriteItem = BottomNavigationBarItem(
      icon: Icon(Icons.favorite_outline),
      activeIcon: Icon(Icons.favorite),
      label: "Yêu thích",
    );
    const historyItem = BottomNavigationBarItem(
      icon: Icon(Icons.history),
      label: "Lịch sử",
    );
    const profileItem = BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: "Hồ sơ",
    );
    const spaceItem = BottomNavigationBarItem(
      icon: SizedBox(width: 48),
      label: "",
    );

    // Tạo danh sách item linh hoạt
    List<BottomNavigationBarItem> navItems;
    int displayIndex;

    if (isAdmin) {
      // Nếu là Admin: 5 items (có slot trống ở giữa)
      navItems = [exploreItem, favoriteItem, spaceItem, historyItem, profileItem];
      // Điều chỉnh index hiển thị để bỏ qua slot thứ 2
      displayIndex = currentIndex >= 2 ? currentIndex + 1 : currentIndex;
    } else {
      // Nếu là User: 4 items (không có khoảng trống)
      navItems = [exploreItem, favoriteItem, historyItem, profileItem];
      displayIndex = currentIndex;
    }

    return SizedBox(
      height: 70,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: displayIndex,
                onTap: (index) {
                  if (isAdmin) {
                    if (index == 2) return; // Chặn click vào slot trống
                    final adjustedIndex = index > 2 ? index - 1 : index;
                    onTap(adjustedIndex);
                  } else {
                    onTap(index); // User click bình thường
                  }
                },
                backgroundColor: theme.cardColor,
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.5),
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                showUnselectedLabels: true,
                items: navItems,
              ),
            ),
          ),

          // Nút Admin tròn (Chỉ hiện khi isAdmin = true)
          if (isAdmin)
            Positioned(
              top: -16,
              child: GestureDetector(
                onTap: onAdminTap,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: theme.cardColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.amber,
                    size: 26,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
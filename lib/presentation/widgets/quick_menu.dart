// lib/presentation/widgets/quick_menu.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class QuickMenu extends StatelessWidget {
  final bool show;
  final VoidCallback onHomeTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onProfileTap;
  final VoidCallback onCloseTap;

  const QuickMenu({
    super.key,
    required this.show,
    required this.onHomeTap,
    required this.onFavoriteTap,
    required this.onHistoryTap,
    required this.onProfileTap,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400), // Tăng nhẹ thời gian để mượt hơn
      curve: Curves.easeInOutQuart,
      bottom: show ? 0 : -120, // Đẩy sâu hơn một chút để ẩn hẳn bóng đổ
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Tăng độ nhòe để hiệu ứng kính rõ hơn
          child: Container(
            height: 110,
            padding: const EdgeInsets.only(bottom: 10), // Tránh sát mép dưới màn hình
            decoration: BoxDecoration(
              // Tự động đổi màu nền theo Theme
              color: isDark 
                  ? const Color(0xFF1A1A1A).withOpacity(0.85) 
                  : Colors.white.withOpacity(0.85),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
            ),
            child: Row(
              children: [
                Expanded(child: _buildItem(context, Icons.home_rounded, "Trang chủ", onHomeTap)),
                Expanded(child: _buildItem(context, Icons.favorite_rounded, "Yêu thích", onFavoriteTap)),
                Expanded(child: _buildItem(context, Icons.history_rounded, "Lịch sử", onHistoryTap)),
                Expanded(child: _buildItem(context, Icons.person_rounded, "Tài khoản", onProfileTap)),
                
                // Vùng nút đóng
                VerticalDivider( // Thêm vạch ngăn cách nhẹ
                  color: isDark ? Colors.white10 : Colors.black12, 
                  indent: 25, 
                  endIndent: 25, 
                  width: 1
                ),
                SizedBox(
                  width: 70,
                  child: IconButton(
                    icon: Icon(
                      Icons.close_fullscreen_rounded, // Icon này trông "Quick Menu" hơn
                      color: isDark ? Colors.white54 : Colors.black45, 
                      size: 24
                    ),
                    onPressed: onCloseTap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            color: isDark ? Colors.white : theme.primaryColor, 
            size: 28
          ),
          const SizedBox(height: 6),
          Text(
            label, 
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87, 
              fontSize: 11,
              fontWeight: FontWeight.w500
            )
          ),
        ],
      ),
    );
  }
}
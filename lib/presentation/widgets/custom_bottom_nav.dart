import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            // Đổ bóng nhẹ hơn ở chế độ tối để không bị thô
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: theme.cardColor,
        // Sử dụng màu chủ đạo (Primary) cho item được chọn
        selectedItemColor: theme.colorScheme.primary, 
        // Màu cho item chưa chọn dựa trên màu chữ/icon mặc định
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 0, // Đã có Container đổ bóng nên để 0 cho mượt
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true, // Hiển thị nhãn ngay cả khi không chọn
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined), 
            activeIcon: Icon(Icons.explore), // Icon đậm hơn khi chọn
            label: "Khám phá"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline), 
            activeIcon: Icon(Icons.favorite),
            label: "Yêu thích"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history), 
            label: "Lịch sử"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), 
            activeIcon: Icon(Icons.person),
            label: "Hồ sơ"
          ),
        ],
      ),
    );
  }
}
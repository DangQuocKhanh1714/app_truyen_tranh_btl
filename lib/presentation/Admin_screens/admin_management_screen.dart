import 'package:app_truyen_tranh/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:app_truyen_tranh/core/constants.dart'; 
import 'add_manga_screen.dart';
import 'manage_mangas_screen.dart';
import 'manage_users_screen.dart';
import 'manage_categories_screen.dart';

class AdminManagementScreen extends StatelessWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Sửa lỗi: Dùng theme để tự động đổi màu khi ấn bóng đèn
      backgroundColor: theme.scaffoldBackgroundColor, 
      
      // AppBar giới hạn chiều dài
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
            child: const CustomAppBar(),
          ),
        ),
      ),
      
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nút Back nằm dưới AppBar, không đè lên thanh tìm kiếm
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 15),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        )
                      ]
                    ),
                    child: Icon(Icons.arrow_back_ios_new, 
                      size: 18, 
                      color: theme.brightness == Brightness.dark ? Colors.white : Colors.black
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildMenuItem(context, Icons.add_circle_outline, "Thêm Truyện", "Cơ bản", theme.primaryColor, const AddMangaScreen()),
                    _buildMenuItem(context, Icons.edit_note, "Quản Lý Truyện", "Chi tiết & Chương", theme.primaryColor, const ManageMangasScreen()),
                    _buildMenuItem(context, Icons.category_outlined, "Thể Loại", "Thêm/Xóa nhãn", theme.primaryColor, const ManageCategoriesScreen()),
                    _buildMenuItem(context, Icons.supervised_user_circle_outlined, "Người Dùng", "Danh sách User", theme.primaryColor, const ManageUsersScreen()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String subtitle, Color color, Widget screen) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor, // Ô menu sẽ đổi màu theo theme
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(title, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87
              )
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
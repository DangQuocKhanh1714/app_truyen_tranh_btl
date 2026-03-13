import 'package:app_truyen_tranh/core/constants.dart';
import 'package:app_truyen_tranh/data/services/database_helper.dart'; // Đảm bảo bạn có helper này
import 'package:app_truyen_tranh/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  List<Map<String, dynamic>> _categories = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Lấy dữ liệu từ database
  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper()
        .getCategories(); // Giả định hàm lấy thể loại của bạn
    setState(() {
      _categories = data;
      _isLoading = false;
    });
  }

  Future<void> _deleteCategory(int id) async {
    await DatabaseHelper().deleteCategory(id);
    _loadCategories();
  }

  // Hàm hiển thị thông báo SnackBar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Hàm thêm thể loại với thông báo
  Future<void> _addCategory() async {
    if (_controller.text.isNotEmpty) {
      final name = _controller.text.trim();
      await DatabaseHelper().insertCategory({'name': name});

      _controller.clear();
      _loadCategories();

      // Thông báo thành công
      _showSnackBar("Đã thêm thể loại '$name' thành công!", Colors.green);
    }
  }

  // Hàm hỏi xác nhận trước khi xóa
  Future<void> _confirmDelete(int id, String name) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Xác nhận xóa"),
        content: Text(
          "Bạn có chắc chắn muốn xóa thể loại '$name' không? Hành động này không thể hoàn tác.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("HỦY", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "XÓA",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper().deleteCategory(id);
      _loadCategories();
      _showSnackBar("Đã xóa thể loại thành công", Colors.blueGrey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: null, // Xóa AppBar đỏ cũ
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Custom AppBar của bạn
                const CustomAppBar(),

                // 2. Nút Back riêng biệt bên dưới AppBar
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // 3. Nội dung quản lý
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Ô nhập thêm thể loại
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: "Tên thể loại mới...",
                                  filled: true,
                                  fillColor: theme.cardColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.dividerColor,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _addCategory,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Thêm"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // Danh sách thể loại từ Database
                        Expanded(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _categories.isEmpty
                              ? const Center(
                                  child: Text("Chưa có thể loại nào"),
                                )
                              : ListView.builder(
                                  itemCount: _categories.length,
                                  itemBuilder: (context, index) {
                                    final item = _categories[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          item['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () => _confirmDelete(
                                            item['id'],
                                            item['name'],
                                          ), // Đổi từ _deleteCategory sang _confirmDelete
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
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

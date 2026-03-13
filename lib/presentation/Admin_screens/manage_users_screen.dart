import 'package:app_truyen_tranh/core/constants.dart';
import 'package:app_truyen_tranh/data/services/database_helper.dart';
import 'package:app_truyen_tranh/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;
  bool _isAiAnalyzing = false;
  String _aiAnalysis = "Nhấn 'Làm mới' để AI phân tích dữ liệu người dùng của bạn.";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper().getUsers();
    setState(() {
      _users = data;
      _filteredUsers = data;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    setState(() {
      _filteredUsers = _users
          .where((user) =>
              (user['username'] ?? '').toLowerCase().contains(_searchController.text.toLowerCase()) ||
              (user['email'] ?? '').toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _analyzeWithAi() async {
    setState(() => _isAiAnalyzing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _aiAnalysis = "Hệ thống ghi nhận ${_users.length} thành viên. Tỷ lệ tương tác ổn định. Gợi ý: Tổ chức sự kiện tri ân cho nhóm hoạt động tích cực.";
      _isAiAnalyzing = false;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
            child: Column(
              children: [
                // 1. Custom AppBar điều khiển màu theo bóng đèn
                const CustomAppBar(),

                // 2. Header & Search
                _buildModernHeader(theme, isDark),

                // 3. Main Content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildMainList(theme, isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(ThemeData theme, bool isDark) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // NÚT BACK TỰ CHẾ CHO ĐẸP
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.arrow_back_ios_new, 
                  size: 18, 
                  color: theme.textTheme.titleLarge?.color
                ),
              ),
            ),
            const SizedBox(width: 15),
            Text(
              "Người dùng",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => _showSnackBar("Tính năng đang phát triển", Colors.blue),
              icon: Icon(Icons.person_add_alt_1, color: theme.primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 15),
          TextField(
            controller: _searchController,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: "Tìm theo tên hoặc email...",
              hintStyle: TextStyle(color: theme.hintColor),
              prefixIcon: Icon(Icons.search, color: theme.hintColor),
              filled: true,
              fillColor: isDark ? theme.cardColor : const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainList(ThemeData theme, bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildAiCard(),
        const SizedBox(height: 20),
        if (_filteredUsers.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text("Không tìm thấy kết quả", style: TextStyle(color: theme.hintColor)),
            ),
          )
        else
          ..._filteredUsers.map((user) => _buildUserItem(user, theme, isDark)).toList(),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildAiCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text("AI PHÂN TÍCH",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              GestureDetector(
                onTap: _isAiAnalyzing ? null : _analyzeWithAi,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(_isAiAnalyzing ? "..." : "Làm mới ✨",
                      style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(_aiAnalysis,
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade200),
        boxShadow: [
          if (!isDark)
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          child: Text(
            (user['username'] ?? 'U')[0].toUpperCase(),
            style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user['username'] ?? "N/A",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.textTheme.bodyLarge?.color),
        ),
        subtitle: Text(
          user['email'] ?? "",
          style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
        ),
        trailing: Icon(Icons.chevron_right, color: theme.hintColor),
        onTap: () => _showUserActions(user, theme),
      ),
    );
  }

  void _showUserActions(Map<String, dynamic> user, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text(user['username'] ?? "Chi tiết", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text("Xóa tài khoản", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(user['id'].toString(), user['username'] ?? user['email']);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String id, String name) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc chắn muốn xóa người dùng '$name'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("HỦY")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("XÓA", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper().deleteUser(id);
      _loadUsers();
      _showSnackBar("Đã xóa người dùng thành công", Colors.blueGrey);
    }
  }
}
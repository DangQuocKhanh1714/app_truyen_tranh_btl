import 'package:app_truyen_tranh/logic/auth_bloc/auth_bloc.dart';
import 'package:app_truyen_tranh/logic/auth_bloc/auth_state.dart';
import 'package:app_truyen_tranh/logic/auth_bloc/auth_event.dart';
import 'package:app_truyen_tranh/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Admin_screens/admin_management_screen.dart';
// Thêm import AppState để chuyển tab
import 'package:app_truyen_tranh/core/app_state.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authService = AuthService();

    const Color backgroundDark = Color(0xFF121212);
    const Color cardGrey = Color(0xFF1E1E1E);
    const Color accentRed = Color(0xFFFF5252);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        bool isLoggedIn = state is AuthAuthenticated;
        String? currentUid = state is AuthAuthenticated ? state.uid : null;

        return Scaffold(
          backgroundColor: backgroundDark,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 50),

                // --- CARD THÔNG TIN CÁ NHÂN ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 35,
                            backgroundColor: backgroundDark,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isLoggedIn && currentUid != null)
                                FutureBuilder<Map<String, dynamic>?>(
                                  future: authService.getUserProfile(),
                                  builder: (context, snapshot) {
                                    final String name =
                                        snapshot.data?['username'] ??
                                        "Người dùng DNU";
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Text(
                                            "Đã xác thực",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              else
                                const Text(
                                  "Khách ẩn danh",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // --- MENU TÙY CHỌN (Đã thêm logic điều hướng) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        if (state is AuthAuthenticated &&
                            state.role == "admin")
                          _buildMenuItem(
                            Icons.admin_panel_settings,
                            "Admin Management",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminManagementScreen(),
                                ),
                              );
                            },
                          ),

                        // Chuyển đến tab Lịch sử (Giả định tab 1)
                        _buildMenuItem(
                          Icons.favorite_outline,
                          "Truyện đang theo dõi",
                          () {
                            AppState.changeTab(1, context);
                          },
                        ),
                        const Divider(
                          color: Colors.white10,
                          height: 1,
                          indent: 55,
                        ),

                        // Chuyển đến tab Yêu thích (Giả định tab 2)
                        _buildMenuItem(Icons.history, "Lịch sử đọc truyện", () {
                          AppState.changeTab(2, context);
                        }),
                        const Divider(
                          color: Colors.white10,
                          height: 1,
                          indent: 55,
                        ),

                        _buildMenuItem(
                          Icons.settings_outlined,
                          "Cài đặt ứng dụng",
                          () {},
                        ),
                        const Divider(
                          color: Colors.white10,
                          height: 1,
                          indent: 55,
                        ),

                        _buildMenuItem(
                          Icons.help_outline,
                          "Hỗ trợ & Góp ý",
                          () {},
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // --- NÚT ĐĂNG XUẤT ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Material(
                    color: cardGrey,
                    borderRadius: BorderRadius.circular(15),
                    child: ListTile(
                      onTap: () async {
                        if (isLoggedIn) {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      leading: Icon(
                        isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                        color: accentRed,
                      ),
                      title: Text(
                        isLoggedIn ? "Đăng xuất" : "Đăng nhập ngay",
                        style: const TextStyle(
                          color: accentRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white24,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}

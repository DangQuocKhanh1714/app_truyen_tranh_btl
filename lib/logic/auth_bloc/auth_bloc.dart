import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/database_helper.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:sqflite/sqflite.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  AuthBloc(this.authService) : super(AuthInitial()) {
    // 1. Kiểm tra trạng thái đăng nhập
    on<AuthCheckRequested>((event, emit) async {
      final user = authService.currentUser;
      if (user != null) {
        final profile = await authService.getUserProfile();
        // Phân quyền dựa trên email (Yêu cầu nâng cao: Tích hợp Firebase [cite: 39])
        String role = (user.email == "admin@gmail.com") ? "admin" : "user";

        emit(
          AuthAuthenticated(
            user.uid,
            profile?['username'] ?? "Thành viên",
            role: role,
            displayName: profile?['username'] ?? "Thành viên", // Thêm dòng này
          ),
        );
      } else {
        emit(AuthUnauthenticated());
      }
    });

    // 2. Đăng ký tài khoản mới
    on<AuthSignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authService.signUp(
          email: event.email,
          password: event.password,
          username: event.username,
        );

        final user = authService.currentUser;
        if (user != null) {
          // Mặc định đăng ký mới là 'user'
          String role = "user";

          // Đồng bộ vào SQLite bảng users (Yêu cầu Kỹ thuật: sqflite [cite: 9])
          final db = await _dbHelper.database;
          await db.insert('users', {
            'id': user.uid,
            'email': event.email,
            'username': event.username,
            'firebase_uid': user.uid,
            'role': role,
          }, conflictAlgorithm: ConflictAlgorithm.replace);

          emit(AuthAuthenticated(user.uid, event.username, role: role));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // 3. Đăng nhập
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final credential = await authService.signIn(
          event.email,
          event.password,
        );
        final profile = await authService.getUserProfile();

        final uid = credential.user!.uid;
        final name = profile?['username'] ?? "Thành viên";

        // Logic phân quyền đơn giản cho bài tập lớn
        String role = (event.email == "admin@gmail.com") ? 'admin' : 'user';

        // Lưu/Cập nhật thông tin vào SQLite để dùng Offline (Yêu cầu Kỹ thuật [cite: 10])
        final db = await _dbHelper.database;
        await db.insert('users', {
          'id': uid,
          'email': event.email,
          'username': name,
          'firebase_uid': uid,
          'role': role,
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        emit(
          AuthAuthenticated(
            uid,
            name,
            role: role,
            displayName: name, // Thêm dòng này
          ),
        );
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // 4. Quên mật khẩu
    on<AuthForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authService.sendPasswordReset(event.email);
        emit(AuthForgotPasswordEmailSent());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // 5. Đăng xuất
    on<AuthLogoutRequested>((event, emit) async {
      await authService.signOut();
      emit(AuthUnauthenticated());
    });
  }
}

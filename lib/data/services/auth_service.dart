import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthService {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;

  // --- LẤY THÔNG TIN USER (Bây giờ lấy từ Firebase Auth trực tiếp) ---
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Vì không dùng Supabase, ta trả về thông tin từ Firebase
        return {
          'uid': user.uid,
          'email': user.email,
          'username': user.displayName ?? "Người dùng DNU",
        };
      }
    } catch (e) {
      print("Lỗi lấy Profile: $e");
    }
    return null;
  }

  // --- ĐĂNG KÝ ---
  Future<void> signUp({required String email, required String password, required String username}) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );

    if (credential.user != null) {
      // Cập nhật DisplayName trong Firebase thay vì lưu vào Supabase
      await credential.user!.updateDisplayName(username);
      
      // Gợi ý: Bạn có thể lưu thêm vào bảng 'users' trong SQLite nếu muốn dùng offline
      // await DatabaseHelper().insertUser({'uid': credential.user!.uid, 'username': username});
    }
  }

  // --- QUÊN MẬT KHẨU ---
  Future<void> sendPasswordReset(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // --- ĐĂNG NHẬP ---
  Future<fb.UserCredential> signIn(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // --- ĐĂNG XUẤT ---
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Lấy User hiện tại của Firebase
  fb.User? get currentUser => _firebaseAuth.currentUser;
}
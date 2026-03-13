class UserModel {
  final String id;
  final String email;
  final String name;
  final String avatarUrl;
  final String role; // Thêm dòng này: 'admin' hoặc 'user'

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.avatarUrl,
    this.role = 'user', // Mặc định là user
  });
}
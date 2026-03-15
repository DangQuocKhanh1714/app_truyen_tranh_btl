class CommentModel {
  final int id;
  final int mangaId;
  final String userId;
  final String content;
  final String? icon;
  final DateTime createdAt;
  final String? username; // Thêm để hiển thị tên người bình luận

  CommentModel({
    required this.id,
    required this.mangaId,
    required this.userId,
    required this.content,
    this.icon,
    required this.createdAt,
    this.username,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as int,
      mangaId: map['manga_id'] as int,
      userId: map['user_id'] as String,
      content: map['content'] as String,
      icon: map['icon'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      username: map['username'] as String?, // Lấy từ lệnh JOIN với bảng users
    );
  }
}

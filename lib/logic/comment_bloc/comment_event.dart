import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Tải bình luận của một bộ truyện cụ thể
class LoadComments extends CommentEvent {
  final int mangaId;
  LoadComments(this.mangaId);

  @override
  List<Object?> get props => [mangaId];
}

// Thêm bình luận mới
class AddComment extends CommentEvent {
  final int mangaId;
  final String content;
  AddComment({required this.mangaId, required this.content});

  @override
  List<Object?> get props => [mangaId, content];
}
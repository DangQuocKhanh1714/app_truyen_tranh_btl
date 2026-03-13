import 'package:equatable/equatable.dart';
import '../../data/models/comment_model.dart';

abstract class CommentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {}
class CommentLoading extends CommentState {}

class CommentLoaded extends CommentState {
  final List<CommentModel> comments;
  CommentLoaded(this.comments);

  @override
  List<Object?> get props => [comments];
}

class CommentError extends CommentState {
  final String message;
  CommentError(this.message);
}
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/database_helper.dart';
import '../../data/models/comment_model.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final DatabaseHelper dbHelper;

  CommentBloc(this.dbHelper) : super(CommentInitial()) {
    
    // Xử lý tải danh sách bình luận
    on<LoadComments>((event, emit) async {
      emit(CommentLoading());
      try {
        final List<Map<String, dynamic>> data = await dbHelper.fetchComments(event.mangaId);
        final comments = data.map((e) => CommentModel.fromMap(e)).toList();
        emit(CommentLoaded(comments));
      } catch (e) {
        emit(CommentError("Không thể tải bình luận: $e"));
      }
    });

    // Xử lý gửi bình luận mới
    on<AddComment>((event, emit) async {
      try {
        await dbHelper.addComment(event.mangaId, event.content);
        // Sau khi thêm thành công, tự động load lại danh sách mới nhất
        add(LoadComments(event.mangaId));
      } catch (e) {
        emit(CommentError("Không thể gửi bình luận: $e"));
      }
    });
  }
}
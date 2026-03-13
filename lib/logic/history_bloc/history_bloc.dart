import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/database_helper.dart';
import '../../data/models/history_model.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final DatabaseHelper dbHelper;

  HistoryBloc(this.dbHelper) : super(HistoryInitial()) {
    
    // 1. Tải lịch sử
    on<LoadHistoryEvent>((event, emit) async {
      emit(HistoryLoading());
      try {
        final List<Map<String, dynamic>> maps = await dbHelper.fetchHistory();
        final history = maps.map((e) => HistoryModel.fromMap(e)).toList();

        emit(HistoryLoaded(history));
      } catch (e) {
        emit(HistoryError("Lỗi tải lịch sử: ${e.toString()}"));
      }
    });

    // 2. Thêm lịch sử đọc
    on<AddHistoryEvent>((event, emit) async {
      try {
        await dbHelper.saveHistory(event.mangaId, event.chapterId);
        add(LoadHistoryEvent());
      } catch (e) {
        emit(HistoryError("Lỗi lưu lịch sử: ${e.toString()}"));
      }
    });

    // 3. Xóa một mục lịch sử (Đã sửa lỗi tên biến)
    on<RemoveHistoryItemEvent>((event, emit) async {
      try {
        await dbHelper.deleteHistory(event.mangaId); 
        add(LoadHistoryEvent()); // Tải lại danh sách
      } catch (e) {
        emit(HistoryError(e.toString()));
      }
    });
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/database_helper.dart';
import '../../data/models/history_model.dart';
import '../../data/models/manga_model.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final DatabaseHelper dbHelper;

  UserBloc(this.dbHelper) : super(UserInitial()) {
    on<LoadUserDataEvent>((event, emit) async {
      emit(UserLoading());
      try {
        // 1. Lấy dữ liệu thô từ DB
        final historyMaps = await dbHelper.fetchHistory();
        final favoriteMaps = await dbHelper.fetchFavorites();

        // 2. Chuyển đổi sang List Model (Quan trọng!)
        final history = historyMaps.map((e) => HistoryModel.fromMap(e)).toList();
        final favorites = favoriteMaps.map((e) => MangaModel.fromMap(e)).toList();

        emit(UserDataLoaded(history: history, favorites: favorites));
      } catch (e) {
        emit(UserError("Lỗi tải dữ liệu người dùng: $e"));
      }
    });

    on<RemoveHistoryEvent>((event, emit) async {
      try {
        await dbHelper.deleteHistory(event.mangaId);
        add(LoadUserDataEvent()); // Tự động load lại sau khi xóa
      } catch (e) {
        emit(UserError("Không thể xóa lịch sử: $e"));
      }
    });
  }
}
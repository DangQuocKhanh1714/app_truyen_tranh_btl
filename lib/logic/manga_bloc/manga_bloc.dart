import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/database_helper.dart';
import '../../data/models/manga_model.dart';
import 'manga_event.dart';
import 'manga_state.dart';

class MangaBloc extends Bloc<MangaEvent, MangaState> {
  final DatabaseHelper dbHelper;

  MangaBloc(this.dbHelper) : super(MangaInitial()) {
    
    // 1. Xử lý tải toàn bộ truyện
    on<LoadMangaEvent>((event, emit) async {
      emit(MangaLoading());
      try {
        final List<Map<String, dynamic>> data = await dbHelper.fetchMangas();
        final listManga = data.map((m) => MangaModel.fromMap(m)).toList();
        emit(MangaLoaded(listManga));
      } catch (e) {
        emit(MangaError("Lỗi tải truyện: ${e.toString()}"));
      }
    });

    // 2. Xử lý tìm kiếm truyện
    on<SearchManga>((event, emit) async {
      emit(MangaLoading());
      try {
        // Gọi hàm searchMangas trong DatabaseHelper (đã viết ở các bước trước)
        final List<Map<String, dynamic>> data = await dbHelper.searchMangas(event.query);
        final listManga = data.map((m) => MangaModel.fromMap(m)).toList();
        emit(MangaLoaded(listManga));
      } catch (e) {
        emit(MangaError("Lỗi tìm kiếm: ${e.toString()}"));
      }
    });
  }
}
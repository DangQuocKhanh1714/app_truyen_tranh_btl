import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/database_helper.dart';
import '../../data/models/manga_model.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final DatabaseHelper dbHelper;

  SearchBloc(this.dbHelper) : super(SearchInitial()) {
    on<OnQueryChanged>((event, emit) async {
      final query = event.query.trim();

      if (query.isEmpty) {
        emit(SearchInitial());
        return;
      }

      emit(SearchLoading());

      try {
        // Lấy dữ liệu Map từ SQLite
        final List<Map<String, dynamic>> data = await dbHelper.searchMangas(query);
        
        // Chuyển đổi sang List<MangaModel>
        final List<MangaModel> results = data.map((m) => MangaModel.fromMap(m)).toList();
        
        emit(SearchLoaded(results));
      } catch (e) {
        emit(SearchError("Không thể lấy dữ liệu tìm kiếm: $e"));
      }
    });

    on<ClearSearch>((event, emit) => emit(SearchInitial()));
  }
}
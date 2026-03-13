import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/database_helper.dart';
import '../../data/models/manga_model.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final DatabaseHelper dbHelper;

  FavoriteBloc(this.dbHelper) : super(FavoriteInitial()) {
    
    // 1. Tải danh sách yêu thích
    on<LoadFavoritesEvent>((event, emit) async {
      emit(FavoriteLoading());
      try {
        final List<Map<String, dynamic>> maps = await dbHelper.fetchFavorites();
        
        // Chuyển đổi từ Map sang List<MangaModel>
        final List<MangaModel> favorites = maps.map((e) => MangaModel.fromMap(e)).toList();
        
        emit(FavoriteLoaded(favorites));
      } catch (e) {
        emit(FavoriteError("Không thể tải danh sách yêu thích: ${e.toString()}"));
      }
    });

    // 2. Bật/Tắt yêu thích
    on<ToggleFavoriteEvent>((event, emit) async {
      try {
        await dbHelper.toggleFavorite(event.mangaId);
        
        // Tự động load lại danh sách sau khi toggle để UI cập nhật ngay lập tức
        final List<Map<String, dynamic>> maps = await dbHelper.fetchFavorites();
        final List<MangaModel> updatedFavorites = maps.map((e) => MangaModel.fromMap(e)).toList();

        emit(FavoriteLoaded(updatedFavorites));
      } catch (e) {
        emit(FavoriteError("Lỗi khi cập nhật yêu thích: $e"));
      }
    });

    // 3. Xóa nhanh yêu thích (Đã sửa lỗi tên biến)
    on<RemoveFavoriteQuickEvent>((event, emit) async {
      try {
        await dbHelper.removeFavorite(event.mangaId); 
        add(LoadFavoritesEvent()); // Tải lại danh sách sau khi xóa
      } catch (e) {
        emit(FavoriteError(e.toString()));
      }
    });
  }
}
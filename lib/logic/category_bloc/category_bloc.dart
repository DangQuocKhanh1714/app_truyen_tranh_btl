import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/database_helper.dart';
import '../../data/models/manga_model.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final DatabaseHelper dbHelper;

  CategoryBloc(this.dbHelper) : super(CategoryInitial()) {
    on<FetchMangasByCategory>((event, emit) async {
      emit(CategoryLoading()); // Yêu cầu 2.C: Hiển thị trạng thái Loading
      try {
        // 1. Gọi DatabaseHelper để lấy dữ liệu Map thông qua lệnh JOIN 3 bảng
        // Tôi mặc định bạn đã dùng hàm fetchMangasByCategory tôi viết ở file DatabaseHelper trước đó
        final List<Map<String, dynamic>> mangaMaps = await dbHelper.fetchMangasByCategory(event.categoryName);

        // 2. Chuyển đổi từ List<Map> sang List<MangaModel>
        List<MangaModel> mangas = mangaMaps.map((map) => MangaModel.fromMap(map)).toList();

        // 3. Xử lý thêm nếu có Query (Tìm kiếm trong thể loại)
        if (event.query != null && event.query!.isNotEmpty) {
          mangas = mangas.where((m) => 
            m.title.toLowerCase().contains(event.query!.toLowerCase())
          ).toList();
        }

        emit(CategoryLoaded(mangas));
      } catch (e) {
        emit(CategoryError("Không thể tải danh sách truyện cho thể loại ${event.categoryName}: $e"));
      }
    });
  }
}
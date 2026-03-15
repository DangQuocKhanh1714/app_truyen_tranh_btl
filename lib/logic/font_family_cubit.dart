import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cubit quản lý font family dành cho phần đọc truyện.
///
/// Lưu vào SharedPreferences để giữ lại giữa mỗi lần bật app.
class FontFamilyCubit extends Cubit<String> {
  static const _kFontFamilyKey = 'readerFontFamily';

  FontFamilyCubit() : super('Roboto') {
    _loadFontFamily();
  }

  Future<void> _loadFontFamily() async {
    final prefs = await SharedPreferences.getInstance();
    final fontFamily = prefs.getString(_kFontFamilyKey) ?? 'Roboto';
    emit(fontFamily);
  }

  Future<void> updateFontFamily(String family) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFontFamilyKey, family);
    emit(family);
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cubit quản lý tỷ lệ cỡ chữ toàn cục của app.
///
/// Giá trị nằm trong khoảng 0.8 - 1.4 (mặc định 1.0).
class FontSizeCubit extends Cubit<double> {
  static const _kFontScaleKey = 'fontScale';

  FontSizeCubit() : super(1.0) {
    _loadFontScale();
  }

  Future<void> _loadFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getDouble(_kFontScaleKey) ?? 1.0;
    emit(value);
  }

  Future<void> updateFontScale(double scale) async {
    final clamped = scale.clamp(0.8, 1.4);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontScaleKey, clamped);
    emit(clamped);
  }
}

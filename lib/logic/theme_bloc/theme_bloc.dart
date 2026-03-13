import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ThemeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ToggleThemeEvent extends ThemeEvent {}

// Thêm Event khởi tạo để đọc dữ liệu từ máy khi vừa mở app
class LoadThemeEvent extends ThemeEvent {}

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  ThemeBloc() : super(ThemeMode.dark) {
    // Xử lý khi app vừa khởi động
    on<LoadThemeEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkMode') ?? true; // Mặc định là tối nếu chưa lưu
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    });

    // Xử lý khi nhấn nút chuyển đổi
    on<ToggleThemeEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      if (state == ThemeMode.dark) {
        await prefs.setBool('isDarkMode', false);
        emit(ThemeMode.light);
      } else {
        await prefs.setBool('isDarkMode', true);
        emit(ThemeMode.dark);
      }
    });
  }
}
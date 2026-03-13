import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Kiểm tra trạng thái khi mở App
class AuthCheckRequested extends AuthEvent {}

// Đăng ký tài khoản mới
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;

  AuthSignUpRequested({
    required this.email, 
    required this.password, 
    required this.username
  });

  @override
  List<Object?> get props => [email, password, username];
}

// Đăng nhập
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({
    required this.email, 
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

// Quên mật khẩu
class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  AuthForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

// Đăng xuất
class AuthLogoutRequested extends AuthEvent {}
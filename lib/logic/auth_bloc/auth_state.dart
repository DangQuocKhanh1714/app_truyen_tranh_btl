import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String uid;
  final String username;
  final String role; 
  final String? displayName;
  
  AuthAuthenticated(
    this.uid, 
    this.username, 
    {required this.role, this.displayName}
  );

  @override
  List<Object?> get props => [uid, username, role, displayName];
}

class AuthUnauthenticated extends AuthState {}

class AuthForgotPasswordEmailSent extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
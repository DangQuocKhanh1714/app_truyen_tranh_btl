abstract class AddUserState {}

class AddUserInitial extends AddUserState {}
class AddUserLoading extends AddUserState {}
class AddUserSuccess extends AddUserState {}

class AddUserFailure extends AddUserState {
  final String error;
  AddUserFailure({required this.error}); // Đã sửa: dùng named parameter duy nhất
}
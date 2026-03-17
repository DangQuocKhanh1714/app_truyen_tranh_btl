abstract class AddUserEvent {}

class AddUserSubmitted extends AddUserEvent {
  final String username;
  final String email;
  final String password;
  final String role;

  AddUserSubmitted({
    required this.username,
    required this.email,
    required this.password,
    required this.role,
  });
}
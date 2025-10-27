//lib/models/user_model.dart




class AppUser {
  final String id;
  final String firstName;
  final String lastName;
  final String userName;
  final String email;
  final String role;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    required this.role,
  });

  String get fullName => '$firstName $lastName';
  bool get isAdmin => role == 'admin';
}

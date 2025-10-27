class SignUpModel {
  final String firstName;
  final String lastName;
  final String userName;
  final String phoneNumber;
  final String email;
  final String role;
  final String password;
  final String confirmPassword;
  final bool signUpConsent;

  SignUpModel({
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.phoneNumber,
    required this.email,
    required this.role,
    required this.password,
    required this.confirmPassword,
    required this.signUpConsent,
  });

  SignUpModel copyWith({
    String? firstName,
    String? lastName,
    String? userName,
    String? phoneNumber,
    String? email,
    String? role,
    String? password,
    String? confirmPassword,
    bool? signUpConsent,
  }) {
    return SignUpModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      role: role ?? this.role,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      signUpConsent: signUpConsent ?? this.signUpConsent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role,
      'password': password,
      'confirmPassword': confirmPassword,
      'signUpConsent': signUpConsent,
    };
  }

  bool get isValidSignUp =>
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      userName.isNotEmpty &&
      email.isNotEmpty &&
      role.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      signUpConsent;
}

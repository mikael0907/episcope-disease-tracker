class SignInModel {
  final String email;
  final String password;

  SignInModel({required this.email, required this.password});

  SignInModel copyWith({String? email, String? password}) {
    return SignInModel(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

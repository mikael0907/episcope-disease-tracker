import 'package:disease_tracker/models/sign_up_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpController extends StateNotifier<SignUpModel> {
  SignUpController()
    : super(
        SignUpModel(
          firstName: '',
          lastName: '',
          userName: '',
          email: '',
          phoneNumber: '',
          role: '',
          password: '',
          confirmPassword: '',
          signUpConsent: false,
        ),
      );

  void updateFirstName(String firstName) {
    state = state.copyWith(firstName: firstName);
  }

  void updateLastName(String lastName) {
    state = state.copyWith(lastName: lastName);
  }

  void updateUserName(String userName) {
    state = state.copyWith(userName: userName);
  }

  void updateEmail(String email) {
    if (email.contains('@') && email.contains('.')) {
      state = state.copyWith(email: email);
    } else {
      throw Error();
    }
  }

  void updatePhoneNumber(String phoneNumber) {
    try {
      state = state.copyWith(phoneNumber: phoneNumber);
    } catch (e) {
      e.toString();
    }
  }

  void updateRole(String role) {
    state = state.copyWith(role: role);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword);
  }

  void updateSignUpConsent(bool? signUpConsent) {
    state = state.copyWith(signUpConsent: signUpConsent ?? false);
  }

  Future<void> submitSignUp() async {
    if (mounted && !state.isValidSignUp) {
      throw Exception('Please fill all required fields and give consent');
    }

    await Future.delayed(const Duration(seconds: 2));
  }
}

final signUpControllerProvider =
    StateNotifierProvider<SignUpController, SignUpModel>(
      (ref) => SignUpController(),
    );

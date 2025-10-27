import 'package:disease_tracker/models/sign_in_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInController extends StateNotifier<SignInModel> {
  SignInController() : super(SignInModel(email: '', password: ''));

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }
}

final signInControllerProvider =
    StateNotifierProvider<SignInController, SignInModel>(
      (ref) => SignInController(),
    );

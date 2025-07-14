import 'package:agrinix/models/auth_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as dev;

class AuthProvider extends StateNotifier<AuthModel> {
  AuthProvider()
    : super(
        AuthModel(
          email: 'youremail@gmail.com',
          name: 'Dickson Daniel Peprah',
          password: "",
        ),
      );

  void updateName(String value) {
    state = state.copyWith(name: value);
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value);
  }
}

//state notifier provider
final authNotifierProvider = StateNotifierProvider<AuthProvider, AuthModel>((
  _,
) {
  return AuthProvider();
});

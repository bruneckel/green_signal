import 'package:flutter/foundation.dart';

import '../../models/user_account.dart';

abstract class AuthRepository extends ChangeNotifier {
  bool get isLoggedIn;

  UserAccount? get currentUser;

  Future<void> initialize();

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String cep,
    required String street,
    required String number,
    String? complement,
    required String neighborhood,
    required String city,
    required String state,
  });

  Future<void> login({
    required String email,
    required String password,
  });

  Future<void> requestPasswordReset({required String email});

  Future<void> logout();

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String cep,
    required String street,
    required String number,
    String? complement,
    required String neighborhood,
    required String city,
    required String state,
  });
}

import 'package:flutter/foundation.dart';

import '../../models/user_account.dart';

abstract class AuthRepository extends ChangeNotifier {
  bool get isLoggedIn;

  UserAccount? get currentUser;

  Future<void> initialize();

  Future<void> register({
    required String name,
    required String email,
    required String address,
    required String phone,
    required String password,
  });

  Future<void> login({
    required String email,
    required String password,
  });

  Future<void> logout();
}

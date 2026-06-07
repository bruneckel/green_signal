import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_account.dart';
import 'auth_exceptions.dart';
import 'auth_repository.dart';
import 'password_hasher.dart';

class LocalAuthRepository extends AuthRepository {
  static const _usersKey = 'auth_users';
  static const _sessionEmailKey = 'auth_session_email';

  List<UserAccount> _users = [];
  UserAccount? _currentUser;

  @override
  bool get isLoggedIn => _currentUser != null;

  @override
  UserAccount? get currentUser => _currentUser;

  @override
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson != null) {
      final decoded = jsonDecode(usersJson) as List<dynamic>;
      _users = decoded
          .map((item) => UserAccount.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    final sessionEmail = prefs.getString(_sessionEmailKey);
    if (sessionEmail != null) {
      _currentUser = _findUserByEmail(sessionEmail);
    }
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String address,
    required String phone,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (_findUserByEmail(normalizedEmail) != null) {
      throw EmailAlreadyRegisteredException();
    }

    final user = UserAccount(
      name: name.trim(),
      email: normalizedEmail,
      address: address.trim(),
      phone: phone.trim(),
      passwordHash: hashPassword(password),
    );

    _users = [..._users, user];
    await _saveUsers();
  }

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final user = _findUserByEmail(email.trim().toLowerCase());

    if (user == null || !verifyPassword(password, user.passwordHash)) {
      throw InvalidCredentialsException();
    }

    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionEmailKey, user.email);
    notifyListeners();
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionEmailKey);
    notifyListeners();
  }

  UserAccount? _findUserByEmail(String email) {
    final normalized = email.toLowerCase();
    for (final user in _users) {
      if (user.email.toLowerCase() == normalized) {
        return user;
      }
    }
    return null;
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_users.map((user) => user.toJson()).toList());
    await prefs.setString(_usersKey, encoded);
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/phone_input_formatter.dart';
import '../../models/map_layer_data.dart';
import '../../models/user_account.dart';
import '../address/user_coordinates_resolver.dart';
import 'auth_exceptions.dart';
import 'auth_repository.dart';
import 'password_hasher.dart';

class LocalAuthRepository extends AuthRepository {
  LocalAuthRepository({UserCoordinatesResolver? coordinatesResolver})
      : _coordinatesResolver =
            coordinatesResolver ?? UserCoordinatesResolver();

  static const _usersKey = 'auth_users';
  static const _sessionEmailKey = 'auth_session_email';

  final UserCoordinatesResolver _coordinatesResolver;

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
      final user = _findUserByEmail(sessionEmail);
      if (user != null) {
        final migrated = await _ensureUserCoordinates(user);
        _currentUser = migrated;
        if (migrated != user) {
          notifyListeners();
        }
      }
    }
  }

  @override
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
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (_findUserByEmail(normalizedEmail) != null) {
      throw EmailAlreadyRegisteredException();
    }

    final draftUser = UserAccount(
      name: name.trim(),
      email: normalizedEmail,
      phone: stripPhoneDigits(phone),
      passwordHash: hashPassword(password),
      cep: cep.replaceAll(RegExp(r'\D'), ''),
      street: street.trim(),
      number: number.trim(),
      complement: complement?.trim(),
      neighborhood: neighborhood.trim(),
      city: city.trim(),
      state: state.trim(),
    );
    final coords = await _coordinatesResolver.resolve(draftUser);

    final user = UserAccount(
      name: draftUser.name,
      email: draftUser.email,
      phone: draftUser.phone,
      passwordHash: draftUser.passwordHash,
      cep: draftUser.cep,
      street: draftUser.street,
      number: draftUser.number,
      complement: draftUser.complement,
      neighborhood: draftUser.neighborhood,
      city: draftUser.city,
      state: draftUser.state,
      latitude: coords?.latitude,
      longitude: coords?.longitude,
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

    final migrated = await _ensureUserCoordinates(user);
    _currentUser = migrated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionEmailKey, migrated.email);
    notifyListeners();
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionEmailKey);
    notifyListeners();
  }

  @override
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
  }) async {
    final current = _currentUser;
    if (current == null) return;

    final draftUser = UserAccount(
      name: name.trim(),
      email: current.email,
      phone: stripPhoneDigits(phone),
      passwordHash: current.passwordHash,
      cep: cep.replaceAll(RegExp(r'\D'), ''),
      street: street.trim(),
      number: number.trim(),
      complement: complement?.trim(),
      neighborhood: neighborhood.trim(),
      city: city.trim(),
      state: state.trim(),
    );
    final coords = await _coordinatesResolver.resolve(draftUser);

    final updated = UserAccount(
      name: draftUser.name,
      email: draftUser.email,
      phone: draftUser.phone,
      passwordHash: draftUser.passwordHash,
      cep: draftUser.cep,
      street: draftUser.street,
      number: draftUser.number,
      complement: draftUser.complement,
      neighborhood: draftUser.neighborhood,
      city: draftUser.city,
      state: draftUser.state,
      latitude: coords?.latitude,
      longitude: coords?.longitude,
    );

    _users = _users
        .map((entry) => entry.email == updated.email ? updated : entry)
        .toList();
    _currentUser = updated;
    await _saveUsers();
    notifyListeners();
  }

  Future<UserAccount> _ensureUserCoordinates(UserAccount user) async {
    if (!MapLayerData.needsCoordinateRefresh(user)) return user;

    final coords = await _coordinatesResolver.resolve(user);
    if (coords == null) return user;

    final updated = UserAccount(
      name: user.name,
      email: user.email,
      phone: user.phone,
      passwordHash: user.passwordHash,
      cep: user.cep,
      street: user.street,
      number: user.number,
      complement: user.complement,
      neighborhood: user.neighborhood,
      city: user.city,
      state: user.state,
      latitude: coords.latitude,
      longitude: coords.longitude,
      legacyAddress: user.legacyAddress,
    );

    _users = _users
        .map((entry) => entry.email == updated.email ? updated : entry)
        .toList();
    await _saveUsers();
    return updated;
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

  void dispose() => _coordinatesResolver.dispose();
}

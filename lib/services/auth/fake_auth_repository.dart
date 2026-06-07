import '../../models/user_account.dart';
import 'auth_exceptions.dart';
import 'auth_repository.dart';
import 'password_hasher.dart';

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository({this.startLoggedIn = false}) {
    _users = [
      UserAccount(
        name: 'Test User',
        email: 'user@example.com',
        address: 'Rua Teste, 123',
        phone: '11999999999',
        passwordHash: hashPassword('123456'),
      ),
    ];

    if (startLoggedIn) {
      _currentUser = _users.first;
    }
  }

  final bool startLoggedIn;

  late List<UserAccount> _users;
  UserAccount? _currentUser;

  @override
  bool get isLoggedIn => _currentUser != null;

  @override
  UserAccount? get currentUser => _currentUser;

  @override
  Future<void> initialize() async {}

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

    _users = [
      ..._users,
      UserAccount(
        name: name.trim(),
        email: normalizedEmail,
        address: address.trim(),
        phone: phone.trim(),
        passwordHash: hashPassword(password),
      ),
    ];
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
    notifyListeners();
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
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
}

import '../../models/user_account.dart';
import 'auth_exceptions.dart';
import 'auth_repository.dart';
import 'password_hasher.dart';
import '../../core/utils/phone_input_formatter.dart';

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository({
    this.startLoggedIn = false,
    List<UserAccount>? users,
    UserAccount? loggedInUser,
  }) {
    _users = users ?? [testUser];
    _currentUser = loggedInUser ?? (startLoggedIn ? _users.first : null);
  }

  static final testUser = UserAccount(
    name: 'Test User',
    email: 'user@example.com',
    phone: '11999999999',
    passwordHash: hashPassword('123456'),
    cep: '05435000',
    street: 'Rua Teste',
    number: '123',
    neighborhood: 'Vila Madalena',
    city: 'São Paulo',
    state: 'SP',
    latitude: -23.546,
    longitude: -46.691,
  );

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

    _users = [
      ..._users,
      UserAccount(
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
        latitude: -25.5128666,
        longitude: -54.5556132,
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

    final updated = UserAccount(
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
      latitude: current.latitude,
      longitude: current.longitude,
    );

    _users = _users
        .map((entry) => entry.email == updated.email ? updated : entry)
        .toList();
    _currentUser = updated;
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

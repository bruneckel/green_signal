import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/models/map_layer_data.dart';
import 'package:green_signal/models/user_account.dart';
import 'package:green_signal/services/address/brasil_api_cep_client.dart';
import 'package:green_signal/services/address/user_coordinates_resolver.dart';
import 'package:green_signal/services/auth/auth_exceptions.dart';
import 'package:green_signal/services/auth/local_auth_repository.dart';
import 'package:green_signal/services/auth/password_hasher.dart';
import 'package:green_signal/services/environment/geocoding_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  UserCoordinatesResolver _fozCoordinatesResolver({
    GeocodingClient? geocodingClient,
  }) {
    return UserCoordinatesResolver(
      brasilApiCepClient: const FakeBrasilApiCepClient(
        coordinates: FakeBrasilApiCepClient.fozCoordinates,
      ),
      geocodingClient: geocodingClient ??
          GeocodingClient(
            client: MockClient((_) async => http.Response('', 500)),
          ),
    );
  }

  group('LocalAuthRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('register persists coordinates from BrasilAPI CEP', () async {
      final auth = LocalAuthRepository(
        coordinatesResolver: _fozCoordinatesResolver(),
      );

      await auth.register(
        name: 'Foz User',
        email: 'foz@test.com',
        phone: '45999999999',
        password: '123456',
        cep: '85862350',
        street: 'Avenida Brasil',
        number: '100',
        neighborhood: 'Centro',
        city: 'Foz do Iguaçu',
        state: 'PR',
      );

      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('auth_users')!;
      final users = jsonDecode(usersJson) as List<dynamic>;
      final user = users.first as Map<String, dynamic>;

      expect(user['latitude'], closeTo(-25.5478, 0.001));
      expect(user['longitude'], closeTo(-54.5882, 0.001));
    });

    test('register does not persist coordinates when all sources fail', () async {
      final auth = LocalAuthRepository(
        coordinatesResolver: UserCoordinatesResolver(
          brasilApiCepClient: const FakeBrasilApiCepClient(),
          geocodingClient: GeocodingClient(
            client: MockClient((_) async => http.Response('', 500)),
          ),
        ),
      );

      await auth.register(
        name: 'Foz User',
        email: 'foz@test.com',
        phone: '45999999999',
        password: '123456',
        cep: '85862350',
        street: 'Avenida Brasil',
        number: '100',
        neighborhood: 'Centro',
        city: 'Foz do Iguaçu',
        state: 'PR',
      );

      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('auth_users')!;
      final users = jsonDecode(usersJson) as List<dynamic>;
      final user = users.first as Map<String, dynamic>;

      expect(user['latitude'], isNull);
      expect(user['longitude'], isNull);
    });

    test('login migrates user with São Paulo region coordinates', () async {
      final fozUser = UserAccount(
        name: 'Foz User',
        email: 'foz@test.com',
        phone: '45999999999',
        passwordHash: hashPassword('123456'),
        cep: '85862350',
        street: 'Avenida Brasil',
        number: '100',
        neighborhood: 'Centro',
        city: 'Foz do Iguaçu',
        state: 'PR',
        latitude: -23.546,
        longitude: -46.691,
      );

      SharedPreferences.setMockInitialValues({
        'auth_users': jsonEncode([fozUser.toJson()]),
      });

      final auth = LocalAuthRepository(
        coordinatesResolver: _fozCoordinatesResolver(),
      );
      await auth.initialize();

      await auth.login(email: 'foz@test.com', password: '123456');

      expect(auth.currentUser?.latitude, closeTo(-25.5478, 0.001));
      expect(auth.currentUser?.longitude, closeTo(-54.5882, 0.001));
    });

    test('updateProfile persists name and recalculates coordinates', () async {
      final fozUser = UserAccount(
        name: 'Foz User',
        email: 'foz@test.com',
        phone: '45999999999',
        passwordHash: hashPassword('123456'),
        cep: '85862350',
        street: 'Avenida Brasil',
        number: '100',
        neighborhood: 'Centro',
        city: 'Foz do Iguaçu',
        state: 'PR',
        latitude: -23.546,
        longitude: -46.691,
      );

      SharedPreferences.setMockInitialValues({
        'auth_users': jsonEncode([fozUser.toJson()]),
        'auth_session_email': 'foz@test.com',
      });

      final auth = LocalAuthRepository(
        coordinatesResolver: _fozCoordinatesResolver(),
      );
      await auth.initialize();

      await auth.updateProfile(
        name: 'Nome Atualizado',
        phone: '45988887777',
        cep: '85862350',
        street: 'Avenida Brasil',
        number: '200',
        neighborhood: 'Centro',
        city: 'Foz do Iguaçu',
        state: 'PR',
      );

      expect(auth.currentUser?.name, 'Nome Atualizado');
      expect(auth.currentUser?.phone, '45988887777');
      expect(auth.currentUser?.number, '200');
      expect(auth.currentUser?.latitude, closeTo(-25.5478, 0.001));
      expect(auth.currentUser?.longitude, closeTo(-54.5882, 0.001));
      expect(auth.currentUser?.legacyAddress, isNull);

      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('auth_users')!;
      final users = jsonDecode(usersJson) as List<dynamic>;
      final saved = users.first as Map<String, dynamic>;
      expect(saved['name'], 'Nome Atualizado');
    });

    test('login migrates user with exact São Paulo fallback coordinates', () async {
      final fozUser = UserAccount(
        name: 'Foz User',
        email: 'foz@test.com',
        phone: '45999999999',
        passwordHash: hashPassword('123456'),
        cep: '85862350',
        street: 'Avenida Brasil',
        number: '100',
        neighborhood: 'Centro',
        city: 'Foz do Iguaçu',
        state: 'PR',
        latitude: MapLayerData.saoPauloCenter.latitude,
        longitude: MapLayerData.saoPauloCenter.longitude,
      );

      SharedPreferences.setMockInitialValues({
        'auth_users': jsonEncode([fozUser.toJson()]),
      });

      final auth = LocalAuthRepository(
        coordinatesResolver: _fozCoordinatesResolver(),
      );
      await auth.initialize();

      await auth.login(email: 'foz@test.com', password: '123456');

      expect(auth.currentUser?.latitude, closeTo(-25.5478, 0.001));
    });

    test('login persists session on success', () async {
      final auth = LocalAuthRepository(
        coordinatesResolver: _fozCoordinatesResolver(),
      );

      await auth.register(
        name: 'Foz User',
        email: 'foz@test.com',
        phone: '45999999999',
        password: '123456',
        cep: '85862350',
        street: 'Avenida Brasil',
        number: '100',
        neighborhood: 'Centro',
        city: 'Foz do Iguaçu',
        state: 'PR',
      );
      await auth.logout();

      await auth.login(email: 'foz@test.com', password: '123456');

      expect(auth.isLoggedIn, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_session_email'), 'foz@test.com');
    });

    test('login throws for invalid credentials', () async {
      final auth = LocalAuthRepository(
        coordinatesResolver: _fozCoordinatesResolver(),
      );

      await auth.register(
        name: 'Foz User',
        email: 'foz@test.com',
        phone: '45999999999',
        password: '123456',
        cep: '85862350',
        street: 'Avenida Brasil',
        number: '100',
        neighborhood: 'Centro',
        city: 'Foz do Iguaçu',
        state: 'PR',
      );
      await auth.logout();

      await expectLater(
        auth.login(email: 'foz@test.com', password: 'wrong'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });

    test('register throws for duplicate email', () async {
      final auth = LocalAuthRepository(
        coordinatesResolver: _fozCoordinatesResolver(),
      );

      const registerArgs = (
        name: 'Foz User',
        email: 'foz@test.com',
        phone: '45999999999',
        password: '123456',
        cep: '85862350',
        street: 'Avenida Brasil',
        number: '100',
        neighborhood: 'Centro',
        city: 'Foz do Iguaçu',
        state: 'PR',
      );

      await auth.register(
        name: registerArgs.name,
        email: registerArgs.email,
        phone: registerArgs.phone,
        password: registerArgs.password,
        cep: registerArgs.cep,
        street: registerArgs.street,
        number: registerArgs.number,
        neighborhood: registerArgs.neighborhood,
        city: registerArgs.city,
        state: registerArgs.state,
      );

      await expectLater(
        auth.register(
          name: 'Other User',
          email: registerArgs.email,
          phone: registerArgs.phone,
          password: registerArgs.password,
          cep: registerArgs.cep,
          street: registerArgs.street,
          number: registerArgs.number,
          neighborhood: registerArgs.neighborhood,
          city: registerArgs.city,
          state: registerArgs.state,
        ),
        throwsA(isA<EmailAlreadyRegisteredException>()),
      );
    });

    test('logout clears persisted session', () async {
      final auth = LocalAuthRepository(
        coordinatesResolver: _fozCoordinatesResolver(),
      );

      await auth.register(
        name: 'Foz User',
        email: 'foz@test.com',
        phone: '45999999999',
        password: '123456',
        cep: '85862350',
        street: 'Avenida Brasil',
        number: '100',
        neighborhood: 'Centro',
        city: 'Foz do Iguaçu',
        state: 'PR',
      );

      await auth.logout();

      expect(auth.isLoggedIn, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_session_email'), isNull);
    });
  });
}

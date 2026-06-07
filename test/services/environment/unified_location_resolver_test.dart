import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/models/environmental_snapshot.dart';
import 'package:green_signal/models/map_layer_data.dart';
import 'package:green_signal/services/location/location_override_store.dart';
import 'package:latlong2/latlong.dart';
import 'package:green_signal/models/user_account.dart';
import 'package:green_signal/services/address/brasil_api_cep_client.dart';
import 'package:green_signal/services/address/user_coordinates_resolver.dart';
import 'package:green_signal/services/auth/fake_auth_repository.dart';
import 'package:green_signal/services/auth/password_hasher.dart';
import 'package:green_signal/services/environment/geocoding_client.dart';
import 'package:green_signal/services/environment/unified_location_resolver.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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

  group('UnifiedLocationResolver', () {
    test('uses stored registration coordinates with profile labels', () async {
      final auth = FakeAuthRepository();
      await auth.login(email: 'user@example.com', password: '123456');

      final resolver = UnifiedLocationResolver(
        coordinatesResolver: _fozCoordinatesResolver(),
      );

      final result = await resolver.resolveWithMeta(auth);

      expect(result.location.position.latitude, closeTo(-23.546, 0.001));
      expect(result.location.neighborhood, 'Vila Madalena');
      expect(result.location.label, 'São Paulo, SP');
    });

    test('uses registration coords for Foz user profile', () async {
      final auth = FakeAuthRepository();
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
      await auth.login(email: 'foz@test.com', password: '123456');

      final resolver = UnifiedLocationResolver(
        coordinatesResolver: _fozCoordinatesResolver(),
      );

      final result = await resolver.resolveWithMeta(auth);

      expect(result.location.position.latitude, closeTo(-25.5128666, 0.001));
      expect(result.location.neighborhood, 'Centro');
      expect(result.location.label, 'Foz do Iguaçu, PR');
    });

    test('resolves via BrasilAPI when stored coordinates are in São Paulo', () async {
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
      final auth = FakeAuthRepository(loggedInUser: fozUser);

      final resolver = UnifiedLocationResolver(
        coordinatesResolver: _fozCoordinatesResolver(),
      );

      final result = await resolver.resolveWithMeta(auth);

      expect(result.location.position.latitude, closeTo(-25.5478, 0.001));
      expect(result.location.neighborhood, 'Centro');
      expect(result.location.label, 'Foz do Iguaçu, PR');
    });

    test('falls back to São Paulo when no user coords', () async {
      final resolver = UnifiedLocationResolver(
        coordinatesResolver: _fozCoordinatesResolver(),
      );

      final result = await resolver.resolveWithMeta(FakeAuthRepository());

      expect(result.location.position, MapLayerData.saoPauloCenter);
    });

    test('override takes precedence over profile location', () async {
      final auth = FakeAuthRepository();
      await auth.login(email: 'user@example.com', password: '123456');

      final overrideStore = LocationOverrideStore();
      final resolver = UnifiedLocationResolver(
        coordinatesResolver: _fozCoordinatesResolver(),
        overrideStore: overrideStore,
      );

      await overrideStore.setOverride(
        const ResolvedLocation(
          position: LatLng(-23.55, -46.63),
          label: 'São Paulo, SP',
          neighborhood: 'São Paulo',
        ),
        'user@example.com',
      );

      final result = await resolver.resolveWithMeta(auth);

      expect(result.location.label, 'São Paulo, SP');
      expect(result.location.neighborhood, 'São Paulo');
      resolver.dispose();
    });

    test('keeps profile labels when coords resolve fails', () async {
      final fozUser = UserAccount(
        name: 'Foz User',
        email: 'foz@test.com',
        phone: '45999999999',
        passwordHash: hashPassword('123456'),
        cep: '85863310',
        street: 'Rua João Goulart',
        number: '100',
        neighborhood: 'Centro Cívico',
        city: 'Foz do Iguaçu',
        state: 'PR',
      );
      final auth = FakeAuthRepository(loggedInUser: fozUser);

      final resolver = UnifiedLocationResolver(
        coordinatesResolver: UserCoordinatesResolver(
          brasilApiCepClient: const FakeBrasilApiCepClient(),
          geocodingClient: GeocodingClient(
            client: MockClient((_) async => http.Response('{}', 404)),
          ),
        ),
      );

      final result = await resolver.resolveWithMeta(auth);

      expect(result.location.label, 'Foz do Iguaçu, PR');
      expect(result.location.neighborhood, 'Centro Cívico');
      resolver.dispose();
    });
  });
}

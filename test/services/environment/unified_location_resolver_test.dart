import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/models/map_layer_data.dart';
import 'package:green_signal/services/auth/fake_auth_repository.dart';
import 'package:green_signal/services/environment/geocoding_client.dart';
import 'package:green_signal/services/environment/unified_location_resolver.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('UnifiedLocationResolver', () {
    test('uses stored registration coordinates with profile labels', () async {
      final auth = FakeAuthRepository();
      await auth.login(email: 'user@example.com', password: '123456');

      final resolver = UnifiedLocationResolver(
        geocodingClient: GeocodingClient(
          client: MockClient((_) async => http.Response('', 500)),
        ),
      );

      final result = await resolver.resolveWithMeta(auth);

      expect(result.location.position.latitude, closeTo(-23.5505, 0.001));
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
        geocodingClient: GeocodingClient(
          client: MockClient((_) async => http.Response('', 500)),
        ),
      );

      final result = await resolver.resolveWithMeta(auth);

      expect(result.location.position.latitude, closeTo(-25.5128666, 0.001));
      expect(result.location.neighborhood, 'Centro');
      expect(result.location.label, 'Foz do Iguaçu, PR');
    });

    test('falls back to São Paulo when no user coords', () async {
      final resolver = UnifiedLocationResolver(
        geocodingClient: GeocodingClient(
          client: MockClient((_) async => http.Response('', 500)),
        ),
      );

      final result = await resolver.resolveWithMeta(FakeAuthRepository());

      expect(result.location.position, MapLayerData.saoPauloCenter);
    });
  });
}

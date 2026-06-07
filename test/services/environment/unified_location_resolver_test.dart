import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/models/map_layer_data.dart';
import 'package:green_signal/models/user_account.dart';
import 'package:green_signal/services/auth/fake_auth_repository.dart';
import 'package:green_signal/services/environment/device_location_service.dart';
import 'package:green_signal/services/environment/geocoding_client.dart';
import 'package:green_signal/services/environment/unified_location_resolver.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

void main() {
  const gpsPosition = LatLng(-25.5128666, -54.5556132);

  group('UnifiedLocationResolver', () {
    test('uses GPS with profile labels when available', () async {
      final auth = FakeAuthRepository();
      await auth.login(email: 'user@example.com', password: '123456');

      final resolver = UnifiedLocationResolver(
        deviceLocation: const FakeDeviceLocationService(position: gpsPosition),
        geocodingClient: GeocodingClient(
          client: MockClient((_) async => http.Response('', 500)),
        ),
      );

      final result = await resolver.resolveWithMeta(auth);

      expect(result.usedGps, isTrue);
      expect(result.location.position, gpsPosition);
      expect(result.location.neighborhood, 'Vila Madalena');
      expect(result.location.label, 'São Paulo, SP');
    });

    test('falls back to stored coordinates when GPS unavailable', () async {
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
        deviceLocation: const FakeDeviceLocationService(),
        geocodingClient: GeocodingClient(
          client: MockClient((_) async => http.Response('', 500)),
        ),
      );

      final result = await resolver.resolveWithMeta(auth);

      expect(result.usedGps, isFalse);
      expect(result.location.position.latitude, closeTo(-25.5128666, 0.001));
      expect(result.location.neighborhood, 'Centro');
      expect(result.location.label, 'Foz do Iguaçu, PR');
    });

    test('falls back to São Paulo when no GPS and no user coords', () async {
      final resolver = UnifiedLocationResolver(
        deviceLocation: const FakeDeviceLocationService(),
        geocodingClient: GeocodingClient(
          client: MockClient((_) async => http.Response('', 500)),
        ),
      );

      final result = await resolver.resolveWithMeta(FakeAuthRepository());

      expect(result.usedGps, isFalse);
      expect(result.location.position, MapLayerData.saoPauloCenter);
    });
  });
}

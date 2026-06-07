import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/models/environmental_snapshot.dart';
import 'package:green_signal/models/map_layer_data.dart';
import 'package:green_signal/services/auth/fake_auth_repository.dart';
import 'package:green_signal/services/environment/device_location_service.dart';
import 'package:green_signal/services/environment/location_resolver.dart';
import 'package:green_signal/services/environment/map_location_resolver.dart';
import 'package:latlong2/latlong.dart';

void main() {
  const gpsPosition = LatLng(-22.9068, -43.1729);
  const addressPosition = LatLng(-23.561, -46.655);

  group('MapLocationResolver', () {
    test('uses GPS when device location is available', () async {
      final resolver = MapLocationResolver(
        deviceLocation: const FakeDeviceLocationService(position: gpsPosition),
        addressResolver: const FakeLocationResolver(
          location: ResolvedLocation(
            position: addressPosition,
            label: 'Endereço',
            neighborhood: 'Bairro',
          ),
        ),
      );

      final result = await resolver.resolve(FakeAuthRepository());

      expect(result.usedGps, isTrue);
      expect(result.position, gpsPosition);
    });

    test('falls back to address when GPS is unavailable', () async {
      final resolver = MapLocationResolver(
        deviceLocation: const FakeDeviceLocationService(),
        addressResolver: const FakeLocationResolver(
          location: ResolvedLocation(
            position: addressPosition,
            label: 'Endereço',
            neighborhood: 'Bairro',
          ),
        ),
      );

      final result = await resolver.resolve(FakeAuthRepository());

      expect(result.usedGps, isFalse);
      expect(result.position, addressPosition);
    });

    test('falls back to saoPauloCenter when GPS and address fail', () async {
      final resolver = MapLocationResolver(
        deviceLocation: const FakeDeviceLocationService(),
        addressResolver: const FakeLocationResolver(),
      );

      final result = await resolver.resolve(FakeAuthRepository());

      expect(result.usedGps, isFalse);
      expect(result.position, MapLayerData.saoPauloCenter);
    });
  });
}

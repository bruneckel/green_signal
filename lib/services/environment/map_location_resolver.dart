import 'package:latlong2/latlong.dart';

import '../auth/auth_repository.dart';
import 'device_location_service.dart';
import 'location_resolver.dart';

class MapLocationResult {
  const MapLocationResult({
    required this.position,
    required this.usedGps,
  });

  final LatLng position;
  final bool usedGps;
}

class MapLocationResolver {
  const MapLocationResolver({
    required this.deviceLocation,
    required this.addressResolver,
  });

  final DeviceLocationService deviceLocation;
  final LocationResolver addressResolver;

  Future<MapLocationResult> resolve(AuthRepository auth) async {
    final gps = await deviceLocation.getCurrentPosition();
    if (gps != null) {
      return MapLocationResult(position: gps, usedGps: true);
    }

    final address = await addressResolver.resolve(auth);
    return MapLocationResult(position: address.position, usedGps: false);
  }
}

import 'package:latlong2/latlong.dart';

import '../../models/environmental_snapshot.dart';
import '../../models/map_layer_data.dart';
import '../../models/user_account.dart';
import '../auth/auth_repository.dart';
import 'device_location_service.dart';
import 'geocoding_client.dart';
import 'location_resolver.dart';

class UnifiedLocationResult {
  const UnifiedLocationResult({
    required this.location,
    required this.usedGps,
  });

  final ResolvedLocation location;
  final bool usedGps;
}

class UnifiedLocationResolver implements LocationResolver {
  UnifiedLocationResolver({
    required this.deviceLocation,
    GeocodingClient? geocodingClient,
  }) : _geocodingClient = geocodingClient ?? GeocodingClient();

  final DeviceLocationService deviceLocation;
  final GeocodingClient _geocodingClient;

  @override
  Future<ResolvedLocation> resolve(AuthRepository auth) async {
    final result = await resolveWithMeta(auth);
    return result.location;
  }

  Future<UnifiedLocationResult> resolveWithMeta(AuthRepository auth) async {
    final user = auth.currentUser;

    final gps = await deviceLocation.getCurrentPosition();
    if (gps != null) {
      return UnifiedLocationResult(
        location: _locationFromProfile(gps, user),
        usedGps: true,
      );
    }

    final stored = user?.storedPosition;
    if (stored != null) {
      return UnifiedLocationResult(
        location: _locationFromProfile(stored, user),
        usedGps: false,
      );
    }

    final query = _geocodeQuery(user);
    if (query != null && query.isNotEmpty) {
      final geocoded = await _geocodingClient.resolve(query);
      return UnifiedLocationResult(
        location: ResolvedLocation(
          position: geocoded.position,
          label: _profileLabel(user).isNotEmpty
              ? _profileLabel(user)
              : geocoded.label,
          neighborhood: _neighborhood(user).isNotEmpty
              ? _neighborhood(user)
              : geocoded.neighborhood,
        ),
        usedGps: false,
      );
    }

    return UnifiedLocationResult(
      location: const ResolvedLocation(
        position: MapLayerData.saoPauloCenter,
        label: 'São Paulo, SP',
        neighborhood: 'São Paulo',
      ),
      usedGps: false,
    );
  }

  ResolvedLocation _locationFromProfile(LatLng position, UserAccount? user) {
    return ResolvedLocation(
      position: position,
      label: _profileLabel(user).isNotEmpty
          ? _profileLabel(user)
          : 'Localização atual',
      neighborhood: _neighborhood(user).isNotEmpty
          ? _neighborhood(user)
          : '—',
    );
  }

  String? _geocodeQuery(UserAccount? user) {
    if (user == null) return null;
    if (user.hasStructuredAddress) {
      return '${user.formattedAddress}, Brasil';
    }
    final legacy = user.legacyAddress ?? user.address;
    if (legacy.isNotEmpty) return legacy;
    return null;
  }

  String _profileLabel(UserAccount? user) {
    if (user == null) return '';
    if (user.hasStructuredAddress) return '${user.city}, ${user.state}';
    return user.legacyAddress ?? user.address;
  }

  String _neighborhood(UserAccount? user) {
    if (user == null) return '';
    if (user.hasStructuredAddress) return user.neighborhood;
    return '';
  }

  void dispose() => _geocodingClient.dispose();
}

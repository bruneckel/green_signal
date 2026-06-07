import 'package:latlong2/latlong.dart';

import '../../models/environmental_snapshot.dart';
import '../../models/map_layer_data.dart';
import '../../models/user_account.dart';
import '../auth/auth_repository.dart';
import '../address/user_coordinates_resolver.dart';
import 'location_resolver.dart';

class UnifiedLocationResult {
  const UnifiedLocationResult({required this.location});

  final ResolvedLocation location;
}

class UnifiedLocationResolver implements LocationResolver {
  UnifiedLocationResolver({
    UserCoordinatesResolver? coordinatesResolver,
  }) : _coordinatesResolver =
            coordinatesResolver ?? UserCoordinatesResolver();

  final UserCoordinatesResolver _coordinatesResolver;

  @override
  Future<ResolvedLocation> resolve(AuthRepository auth) async {
    final result = await resolveWithMeta(auth);
    return result.location;
  }

  Future<UnifiedLocationResult> resolveWithMeta(AuthRepository auth) async {
    final user = auth.currentUser;

    if (user != null) {
      final stored = user.storedPosition;
      if (stored != null && !MapLayerData.needsCoordinateRefresh(user)) {
        return UnifiedLocationResult(
          location: _locationFromProfile(stored, user),
        );
      }

      final coords = await _coordinatesResolver.resolve(user);
      if (coords != null) {
        return UnifiedLocationResult(
          location: _locationFromProfile(coords, user),
        );
      }

      final fallbackPosition = user.storedPosition ?? MapLayerData.saoPauloCenter;
      return UnifiedLocationResult(
        location: _locationFromProfile(fallbackPosition, user),
      );
    }

    return UnifiedLocationResult(
      location: const ResolvedLocation(
        position: MapLayerData.saoPauloCenter,
        label: 'São Paulo, SP',
        neighborhood: 'São Paulo',
      ),
    );
  }

  ResolvedLocation _locationFromProfile(LatLng position, UserAccount? user) {
    return ResolvedLocation(
      position: position,
      label: _profileLabel(user).isNotEmpty
          ? _profileLabel(user)
          : 'Localização cadastrada',
      neighborhood: _neighborhood(user).isNotEmpty
          ? _neighborhood(user)
          : '—',
    );
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

  void dispose() => _coordinatesResolver.dispose();
}

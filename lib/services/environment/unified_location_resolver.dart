import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../models/environmental_snapshot.dart';
import '../../models/map_layer_data.dart';
import '../../models/user_account.dart';
import '../auth/auth_repository.dart';
import '../address/user_coordinates_resolver.dart';
import '../location/location_override_store.dart';
import '../../core/constants/location_strings.dart';
import 'geocoding_client.dart';
import 'location_resolver.dart';

class UnifiedLocationResult {
  const UnifiedLocationResult({required this.location});

  final ResolvedLocation location;
}

class UnifiedLocationResolver extends ChangeNotifier implements LocationResolver {
  UnifiedLocationResolver({
    UserCoordinatesResolver? coordinatesResolver,
    LocationOverrideStore? overrideStore,
    GeocodingClient? geocodingClient,
  })  : _coordinatesResolver =
            coordinatesResolver ?? UserCoordinatesResolver(),
        _overrideStore = overrideStore ?? LocationOverrideStore(),
        _geocodingClient = geocodingClient ?? GeocodingClient(),
        _ownsGeocodingClient = geocodingClient == null {
    _overrideStore.addListener(notifyListeners);
  }

  final UserCoordinatesResolver _coordinatesResolver;
  final LocationOverrideStore _overrideStore;
  final GeocodingClient _geocodingClient;
  final bool _ownsGeocodingClient;

  String? _loadedUserEmail;

  LocationOverrideStore get overrideStore => _overrideStore;
  bool get isExploring => _overrideStore.isExploring;

  @override
  Future<ResolvedLocation> resolve(AuthRepository auth) async {
    final result = await resolveWithMeta(auth);
    return result.location;
  }

  Future<UnifiedLocationResult> resolveWithMeta(AuthRepository auth) async {
    await _ensureOverrideLoaded(auth);

    if (_overrideStore.current != null) {
      return UnifiedLocationResult(location: _overrideStore.current!);
    }

    return UnifiedLocationResult(location: await _resolveProfileLocation(auth));
  }

  Future<ResolvedLocation> resolveProfileLocation(AuthRepository auth) async {
    await _ensureOverrideLoaded(auth);
    return _resolveProfileLocation(auth);
  }

  String profileLabel(AuthRepository auth) {
    return _profileLabel(auth.currentUser);
  }

  Future<void> loadOverridesForUser(AuthRepository auth) async {
    _loadedUserEmail = auth.currentUser?.email;
    await _overrideStore.loadForUser(_loadedUserEmail);
  }

  Future<void> setExploredCity({
    required String city,
    required String state,
    required String userEmail,
  }) async {
    final geocoded = await _geocodingClient.resolve('$city, $state, Brasil');
    if (_isGeocodeFailure(geocoded, city)) {
      throw StateError(LocationStrings.geocodeError);
    }
    final location = ResolvedLocation(
      position: geocoded.position,
      label: '$city, $state',
      neighborhood: city,
    );
    await _overrideStore.setOverride(location, userEmail);
  }

  bool _isGeocodeFailure(ResolvedLocation result, String city) {
    if (!MapLayerData.isSaoPauloFallback(result.position)) {
      return false;
    }
    final normalizedCity = city.toLowerCase();
    return !normalizedCity.contains('são paulo') &&
        !normalizedCity.contains('sao paulo');
  }

  Future<void> clearExploredCity(String userEmail) async {
    await _overrideStore.clearOverride(userEmail);
  }

  Future<void> _ensureOverrideLoaded(AuthRepository auth) async {
    final email = auth.currentUser?.email;
    if (email == _loadedUserEmail) return;
    _loadedUserEmail = email;
    await _overrideStore.loadForUser(email);
  }

  Future<ResolvedLocation> _resolveProfileLocation(AuthRepository auth) async {
    final user = auth.currentUser;

    if (user != null) {
      final stored = user.storedPosition;
      if (stored != null && !MapLayerData.needsCoordinateRefresh(user)) {
        return _locationFromProfile(stored, user);
      }

      final coords = await _coordinatesResolver.resolve(user);
      if (coords != null) {
        return _locationFromProfile(coords, user);
      }

      final fallbackPosition = user.storedPosition ?? MapLayerData.saoPauloCenter;
      return _locationFromProfile(fallbackPosition, user);
    }

    return const ResolvedLocation(
      position: MapLayerData.saoPauloCenter,
      label: 'São Paulo, SP',
      neighborhood: 'São Paulo',
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

  @override
  void dispose() {
    _overrideStore.removeListener(notifyListeners);
    _coordinatesResolver.dispose();
    if (_ownsGeocodingClient) {
      _geocodingClient.dispose();
    }
    super.dispose();
  }
}

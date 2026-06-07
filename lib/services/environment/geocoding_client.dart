import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/map_config.dart';
import '../../models/environmental_snapshot.dart';
import '../../models/map_layer_data.dart';
import '../../models/user_account.dart';

class GeocodingClient {
  GeocodingClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final _memoryCache = <String, _GeocodeCacheEntry>{};

  Future<ResolvedLocation> resolve(String address) async {
    final query = address.trim();
    if (query.isEmpty) {
      return _fallbackLocation();
    }

    final cacheKey = _cacheKey(query);
    final memoryHit = _memoryCache[cacheKey];
    if (memoryHit != null && memoryHit.isValid) {
      return memoryHit.location;
    }

    final persisted = await _readPersisted(cacheKey);
    if (persisted != null) {
      _memoryCache[cacheKey] = _GeocodeCacheEntry(
        location: persisted,
        expiresAt: DateTime.now().add(
          Duration(days: MapConfig.geocodeCacheTtlDays),
        ),
      );
      return persisted;
    }

    try {
      final uri = Uri.parse(MapConfig.geocodingUrl).replace(
        queryParameters: {
          'name': query,
          'count': '1',
          'language': 'pt',
          'format': 'json',
        },
      );

      final response = await _client
          .get(uri)
          .timeout(Duration(seconds: MapConfig.requestTimeoutSeconds));

      if (response.statusCode != 200) {
        return _fallbackLocation();
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final results = json['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) {
        return _fallbackLocation();
      }

      final first = results.first as Map<String, dynamic>;
      final lat = (first['latitude'] as num?)?.toDouble();
      final lon = (first['longitude'] as num?)?.toDouble();
      if (lat == null || lon == null) {
        return _fallbackLocation();
      }

      final name = first['name'] as String? ?? query;
      final admin1 = first['admin1'] as String?;
      final country = first['country'] as String? ?? 'Brasil';
      final label = _formatLabel(name, admin1, country);

      final resolved = ResolvedLocation(
        position: LatLng(lat, lon),
        label: label,
        neighborhood: name,
      );

      if (!MapLayerData.isSaoPauloFallback(resolved.position)) {
        _memoryCache[cacheKey] = _GeocodeCacheEntry(
          location: resolved,
          expiresAt: DateTime.now().add(
            Duration(days: MapConfig.geocodeCacheTtlDays),
          ),
        );
        await _persist(cacheKey, resolved);
      }
      return resolved;
    } catch (_) {
      return _fallbackLocation();
    }
  }

  Future<ResolvedLocation> resolveForUser(UserAccount user) async {
    if (user.hasStructuredAddress) {
      final fullAddress = '${user.formattedAddress}, Brasil';
      final fullResult = await resolve(fullAddress);
      if (!_isRejectedForUser(fullResult.position, user)) {
        return fullResult;
      }

      final cityResult = await resolve('${user.city}, ${user.state}, Brasil');
      if (!_isRejectedForUser(cityResult.position, user)) {
        return cityResult;
      }

      // Open-Meteo often misses "City, UF, Brasil" but resolves the city name alone.
      final cityOnlyResult = await resolve(user.city);
      if (!_isRejectedForUser(cityOnlyResult.position, user)) {
        return cityOnlyResult;
      }
    } else {
      final legacy = user.legacyAddress ?? user.address;
      if (legacy.isNotEmpty) {
        final legacyResult = await resolve(legacy);
        if (!MapLayerData.isSaoPauloFallback(legacyResult.position)) {
          return legacyResult;
        }
      }
    }

    return _fallbackLocation();
  }

  bool _isRejectedForUser(LatLng position, UserAccount user) {
    if (!MapLayerData.isSaoPauloFallback(position)) return false;
    return !_isSaoPauloProfile(user);
  }

  bool _isSaoPauloProfile(UserAccount user) {
    final city = user.city.toLowerCase();
    return city.contains('são paulo') || city.contains('sao paulo');
  }

  ResolvedLocation _fallbackLocation() {
    return const ResolvedLocation(
      position: MapLayerData.saoPauloCenter,
      label: 'São Paulo, SP',
      neighborhood: 'São Paulo',
    );
  }

  String _formatLabel(String name, String? admin1, String country) {
    if (admin1 != null && admin1.isNotEmpty) {
      return '$name, $admin1';
    }
    return '$name, $country';
  }

  String _cacheKey(String query) => query.toLowerCase();

  Future<void> _persist(String key, ResolvedLocation location) async {
    if (MapLayerData.isSaoPauloFallback(location.position)) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'geocode_cache_$key',
        jsonEncode({
          'lat': location.position.latitude,
          'lon': location.position.longitude,
          'label': location.label,
          'neighborhood': location.neighborhood,
          'cachedAt': DateTime.now().toIso8601String(),
        }),
      );
    } catch (_) {
      // Persistence is best-effort (e.g. unavailable in unit tests).
    }
  }

  Future<ResolvedLocation?> _readPersisted(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('geocode_cache_$key');
      if (raw == null) return null;

      final json = jsonDecode(raw) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(json['cachedAt'] as String);
      if (DateTime.now().difference(cachedAt) >
          Duration(days: MapConfig.geocodeCacheTtlDays)) {
        return null;
      }

      final position = LatLng(
        (json['lat'] as num).toDouble(),
        (json['lon'] as num).toDouble(),
      );
      if (MapLayerData.isSaoPauloFallback(position)) {
        await prefs.remove('geocode_cache_$key');
        return null;
      }

      return ResolvedLocation(
        position: position,
        label: json['label'] as String,
        neighborhood: json['neighborhood'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.close();
}

class _GeocodeCacheEntry {
  _GeocodeCacheEntry({required this.location, required this.expiresAt});

  final ResolvedLocation location;
  final DateTime expiresAt;

  bool get isValid => DateTime.now().isBefore(expiresAt);
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/environmental_snapshot.dart';

class LocationOverrideStore extends ChangeNotifier {
  LocationOverrideStore({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;
  ResolvedLocation? _current;

  ResolvedLocation? get current => _current;
  bool get isExploring => _current != null;

  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static String keyForUser(String userEmail) =>
      'location_override_${userEmail.trim().toLowerCase()}';

  Future<void> loadForUser(String? userEmail) async {
    if (userEmail == null || userEmail.isEmpty) {
      _current = null;
      notifyListeners();
      return;
    }

    final prefs = await _ensurePrefs();
    final raw = prefs.getString(keyForUser(userEmail));
    if (raw == null) {
      _current = null;
      notifyListeners();
      return;
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _current = ResolvedLocation(
        position: LatLng(
          (json['lat'] as num).toDouble(),
          (json['lng'] as num).toDouble(),
        ),
        label: json['label'] as String,
        neighborhood: json['neighborhood'] as String? ?? '',
      );
    } catch (_) {
      _current = null;
    }
    notifyListeners();
  }

  Future<void> setOverride(ResolvedLocation location, String userEmail) async {
    final prefs = await _ensurePrefs();
    await prefs.setString(
      keyForUser(userEmail),
      jsonEncode({
        'label': location.label,
        'lat': location.position.latitude,
        'lng': location.position.longitude,
        'neighborhood': location.neighborhood,
      }),
    );
    _current = location;
    notifyListeners();
  }

  Future<void> clearOverride(String userEmail) async {
    final prefs = await _ensurePrefs();
    await prefs.remove(keyForUser(userEmail));
    _current = null;
    notifyListeners();
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

abstract class BrasilApiCepClient {
  Future<LatLng?> fetchCoordinates(String cep);
}

class LiveBrasilApiCepClient implements BrasilApiCepClient {
  LiveBrasilApiCepClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<LatLng?> fetchCoordinates(String cep) async {
    final digits = cep.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return null;

    try {
      final response = await _client
          .get(Uri.parse('https://brasilapi.com.br/api/cep/v2/$digits'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final location = json['location'] as Map<String, dynamic>?;
      if (location == null) return null;

      final coordinates = location['coordinates'] as Map<String, dynamic>?;
      if (coordinates == null || coordinates.isEmpty) return null;

      final lat = _parseCoordinate(coordinates['latitude']);
      final lon = _parseCoordinate(coordinates['longitude']);
      if (lat == null || lon == null) return null;

      return LatLng(lat, lon);
    } catch (_) {
      return null;
    }
  }

  double? _parseCoordinate(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String && value.isNotEmpty) return double.tryParse(value);
    return null;
  }

  void dispose() => _client.close();
}

class FakeBrasilApiCepClient implements BrasilApiCepClient {
  const FakeBrasilApiCepClient({this.coordinates, this.delay = Duration.zero});

  static const fozCoordinates = LatLng(-25.5478, -54.5882);

  final LatLng? coordinates;
  final Duration delay;

  @override
  Future<LatLng?> fetchCoordinates(String cep) async {
    await Future<void>.delayed(delay);
    return coordinates;
  }
}

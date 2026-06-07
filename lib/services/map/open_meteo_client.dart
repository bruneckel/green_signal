import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../core/constants/map_config.dart';

class OpenMeteoReading {
  const OpenMeteoReading({
    required this.position,
    this.europeanAqi,
    this.pm25,
    this.temperature,
    this.precipitation,
  });

  final LatLng position;
  final double? europeanAqi;
  final double? pm25;
  final double? temperature;
  final double? precipitation;
}

class OpenMeteoClient {
  OpenMeteoClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<OpenMeteoReading> fetchAirQuality(LatLng position) async {
    final uri = Uri.parse(MapConfig.openMeteoAirQualityUrl).replace(
      queryParameters: {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
        'current': 'european_aqi,pm2_5',
      },
    );

    final response = await _client
        .get(uri)
        .timeout(Duration(seconds: MapConfig.requestTimeoutSeconds));
    if (response.statusCode != 200) {
      throw OpenMeteoException(response.statusCode, uri.toString());
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>?;
    final aqi = (current?['european_aqi'] as num?)?.toDouble();
    final pm25 = (current?['pm2_5'] as num?)?.toDouble();

    return OpenMeteoReading(
      position: position,
      europeanAqi: aqi,
      pm25: pm25,
    );
  }

  Future<OpenMeteoReading> fetchWeather(LatLng position) async {
    final uri = Uri.parse(MapConfig.openMeteoForecastUrl).replace(
      queryParameters: {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
        'current': 'temperature_2m',
      },
    );

    final response = await _client
        .get(uri)
        .timeout(Duration(seconds: MapConfig.requestTimeoutSeconds));
    if (response.statusCode != 200) {
      throw OpenMeteoException(response.statusCode, uri.toString());
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>?;
    final temp = (current?['temperature_2m'] as num?)?.toDouble();

    return OpenMeteoReading(
      position: position,
      temperature: temp,
    );
  }

  Future<OpenMeteoReading> fetchRainForecast(LatLng position) async {
    final uri = Uri.parse(MapConfig.openMeteoForecastUrl).replace(
      queryParameters: {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
        'hourly': 'precipitation',
        'forecast_hours': MapConfig.rainForecastHours.toString(),
      },
    );

    final response = await _client
        .get(uri)
        .timeout(Duration(seconds: MapConfig.requestTimeoutSeconds));
    if (response.statusCode != 200) {
      throw OpenMeteoException(response.statusCode, uri.toString());
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>?;
    final values = hourly?['precipitation'] as List<dynamic>? ?? [];
    final sum = values.fold<double>(
      0,
      (total, value) => total + ((value as num?)?.toDouble() ?? 0),
    );

    return OpenMeteoReading(
      position: position,
      precipitation: sum,
    );
  }

  Future<List<OpenMeteoReading>> fetchAirQualityGrid(
    List<LatLng> grid,
  ) async {
    return _fetchResilient(grid, fetchAirQuality);
  }

  Future<List<OpenMeteoReading>> fetchWeatherGrid(List<LatLng> grid) async {
    return _fetchResilient(grid, fetchWeather);
  }

  Future<List<OpenMeteoReading>> fetchRainGrid(List<LatLng> grid) async {
    return _fetchResilient(grid, fetchRainForecast);
  }

  Future<List<OpenMeteoReading>> _fetchResilient(
    List<LatLng> grid,
    Future<OpenMeteoReading> Function(LatLng) fetch,
  ) async {
    final results = <OpenMeteoReading>[];
    for (var i = 0; i < grid.length; i += MapConfig.requestBatchSize) {
      final end = (i + MapConfig.requestBatchSize).clamp(0, grid.length);
      final batch = grid.sublist(i, end);
      for (final point in batch) {
        try {
          final reading = await fetch(point);
          results.add(reading);
        } catch (_) {
          // Skip failed points; other cells still contribute to the layer.
        }
      }
    }
    return results;
  }

  void dispose() => _client.close();
}

class OpenMeteoException implements Exception {
  OpenMeteoException(this.statusCode, this.url);

  final int statusCode;
  final String url;

  @override
  String toString() => 'OpenMeteoException($statusCode): $url';
}

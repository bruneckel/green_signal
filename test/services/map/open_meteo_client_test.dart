import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/services/map/open_meteo_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

void main() {
  const position = LatLng(-23.55, -46.63);

  group('OpenMeteoClient', () {
    test('fetchAirQuality parses european_aqi and pm2_5', () async {
      final client = OpenMeteoClient(
        client: MockClient((request) async {
          expect(request.url.host, contains('open-meteo'));
          return http.Response(
            jsonEncode({
              'current': {'european_aqi': 42, 'pm2_5': 11.2},
            }),
            200,
          );
        }),
      );

      final reading = await client.fetchAirQuality(position);
      expect(reading.europeanAqi, 42);
      expect(reading.pm25, 11.2);
      client.dispose();
    });

    test('fetchWeather parses temperature', () async {
      final client = OpenMeteoClient(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'current': {'temperature_2m': 25.5},
            }),
            200,
          );
        }),
      );

      final reading = await client.fetchWeather(position);
      expect(reading.temperature, 25.5);
      client.dispose();
    });

    test('fetchRainForecast sums hourly precipitation', () async {
      final client = OpenMeteoClient(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'hourly': {
                'precipitation': [0.0, 1.5, 2.0, 0.0],
              },
            }),
            200,
          );
        }),
      );

      final reading = await client.fetchRainForecast(position);
      expect(reading.precipitation, 3.5);
      client.dispose();
    });

    test('fetchAirQualityGrid continues when a point fails', () async {
      var callCount = 0;
      final client = OpenMeteoClient(
        client: MockClient((request) async {
          callCount++;
          if (callCount == 1) {
            return http.Response('', 500);
          }
          return http.Response(
            jsonEncode({'current': {'european_aqi': 30}}),
            200,
          );
        }),
      );

      final readings = await client.fetchAirQualityGrid([
        const LatLng(-23.55, -46.63),
        const LatLng(-23.56, -46.64),
      ]);

      expect(readings, hasLength(1));
      client.dispose();
    });
  });
}

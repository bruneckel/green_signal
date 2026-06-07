import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/services/address/brasil_api_cep_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('LiveBrasilApiCepClient', () {
    test('parses coordinates from BrasilAPI response', () async {
      final client = LiveBrasilApiCepClient(
        client: MockClient((_) async {
          return http.Response(
            jsonEncode({
              'cep': '85862350',
              'city': 'Foz do Iguaçu',
              'state': 'PR',
              'location': {
                'type': 'Point',
                'coordinates': {
                  'latitude': '-25.5478',
                  'longitude': '-54.5882',
                },
              },
            }),
            200,
          );
        }),
      );

      final coords = await client.fetchCoordinates('85862350');

      expect(coords, isNotNull);
      expect(coords!.latitude, closeTo(-25.5478, 0.001));
      expect(coords.longitude, closeTo(-54.5882, 0.001));

      client.dispose();
    });

    test('returns null when coordinates are missing', () async {
      final client = LiveBrasilApiCepClient(
        client: MockClient((_) async {
          return http.Response(
            jsonEncode({
              'cep': '85862350',
              'location': {'type': 'Point', 'coordinates': {}},
            }),
            200,
          );
        }),
      );

      final coords = await client.fetchCoordinates('85862350');

      expect(coords, isNull);
      client.dispose();
    });

    test('returns null for invalid CEP response', () async {
      final client = LiveBrasilApiCepClient(
        client: MockClient((_) async => http.Response('', 404)),
      );

      final coords = await client.fetchCoordinates('00000000');

      expect(coords, isNull);
      client.dispose();
    });
  });

  group('FakeBrasilApiCepClient', () {
    test('returns configured coordinates', () async {
      const client = FakeBrasilApiCepClient(
        coordinates: FakeBrasilApiCepClient.fozCoordinates,
      );

      final coords = await client.fetchCoordinates('85862350');

      expect(coords, FakeBrasilApiCepClient.fozCoordinates);
    });
  });
}

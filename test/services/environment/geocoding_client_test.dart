import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/models/map_layer_data.dart';
import 'package:green_signal/services/environment/geocoding_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GeocodingClient', () {
    test('parses first search result', () async {
      final client = GeocodingClient(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'results': [
                {
                  'name': 'Vila Madalena',
                  'admin1': 'São Paulo',
                  'country': 'Brazil',
                  'latitude': -23.546,
                  'longitude': -46.691,
                },
              ],
            }),
            200,
          );
        }),
      );

      final resolved = await client.resolve('Vila Madalena, São Paulo');

      expect(resolved.neighborhood, 'Vila Madalena');
      expect(resolved.label, 'Vila Madalena, São Paulo');
      expect(resolved.position.latitude, closeTo(-23.546, 0.001));
      expect(resolved.position.longitude, closeTo(-46.691, 0.001));

      client.dispose();
    });

    test('falls back to São Paulo when search fails', () async {
      final client = GeocodingClient(
        client: MockClient((request) async {
          return http.Response('{}', 404);
        }),
      );

      final resolved = await client.resolve('Endereço inválido');

      expect(resolved.position, MapLayerData.saoPauloCenter);
      expect(resolved.label, 'São Paulo, SP');

      client.dispose();
    });

    test('falls back when address is empty', () async {
      final client = GeocodingClient(client: MockClient((_) async {
        throw StateError('Should not call API for empty address');
      }));

      final resolved = await client.resolve('   ');

      expect(resolved.position, MapLayerData.saoPauloCenter);

      client.dispose();
    });
  });
}

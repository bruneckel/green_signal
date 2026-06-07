import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/services/location/ibge_localities_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('LiveIbgeLocalitiesClient', () {
    test('fetchStates parses IBGE response', () async {
      final client = LiveIbgeLocalitiesClient(
        client: MockClient((request) async {
          expect(request.url.path, contains('/estados'));
          return http.Response(
            jsonEncode([
              {'id': 35, 'sigla': 'SP', 'nome': 'São Paulo'},
              {'id': 41, 'sigla': 'PR', 'nome': 'Paraná'},
            ]),
            200,
          );
        }),
      );

      final states = await client.fetchStates();

      expect(states, hasLength(2));
      expect(states.first.sigla, 'SP');
      expect(states.last.nome, 'Paraná');
    });

    test('fetchMunicipalities parses IBGE response', () async {
      final client = LiveIbgeLocalitiesClient(
        client: MockClient((request) async {
          expect(request.url.path, contains('/estados/SP/municipios'));
          return http.Response(
            jsonEncode([
              {'id': 3550308, 'nome': 'São Paulo'},
            ]),
            200,
          );
        }),
      );

      final municipalities = await client.fetchMunicipalities('SP');

      expect(municipalities, hasLength(1));
      expect(municipalities.single.nome, 'São Paulo');
    });
  });

  test('FakeIbgeLocalitiesClient returns configured data', () async {
    const fake = FakeIbgeLocalitiesClient();

    final states = await fake.fetchStates();
    final municipalities = await fake.fetchMunicipalities('PR');

    expect(states.map((s) => s.sigla), containsAll(['SP', 'PR']));
    expect(municipalities.map((m) => m.nome), contains('Foz do Iguaçu'));
  });
}

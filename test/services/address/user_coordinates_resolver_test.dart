import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/models/user_account.dart';
import 'package:green_signal/services/address/brasil_api_cep_client.dart';
import 'package:green_signal/services/address/user_coordinates_resolver.dart';
import 'package:green_signal/services/auth/password_hasher.dart';
import 'package:green_signal/services/environment/geocoding_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const fozUser = UserAccount(
    name: 'Foz User',
    email: 'foz@test.com',
    phone: '45999999999',
    passwordHash: 'hash',
    cep: '85862350',
    street: 'Avenida Brasil',
    number: '100',
    neighborhood: 'Centro',
    city: 'Foz do Iguaçu',
    state: 'PR',
  );

  group('UserCoordinatesResolver', () {
    test('prefers BrasilAPI CEP coordinates over geocoding', () async {
      final resolver = UserCoordinatesResolver(
        brasilApiCepClient: const FakeBrasilApiCepClient(
          coordinates: FakeBrasilApiCepClient.fozCoordinates,
        ),
        geocodingClient: GeocodingClient(
          client: MockClient((_) async => http.Response('', 500)),
        ),
      );

      final coords = await resolver.resolve(fozUser);

      expect(coords!.latitude, closeTo(-25.5478, 0.001));
      resolver.dispose();
    });

    test('falls back to geocoding when BrasilAPI returns null', () async {
      final resolver = UserCoordinatesResolver(
        brasilApiCepClient: const FakeBrasilApiCepClient(),
        geocodingClient: GeocodingClient(
          client: MockClient((_) async {
            return http.Response(
              '{"results":[{"name":"Foz do Iguaçu","admin1":"Paraná","country":"Brazil","latitude":-25.5478,"longitude":-54.5882}]}',
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final coords = await resolver.resolve(fozUser);

      expect(coords!.latitude, closeTo(-25.5478, 0.001));
      resolver.dispose();
    });

    test('resolves Foz user when BrasilAPI has empty coordinates', () async {
      const fozCepUser = UserAccount(
        name: 'Foz User',
        email: 'foz@test.com',
        phone: '45999999999',
        passwordHash: 'hash',
        cep: '85863310',
        street: 'Rua João Goulart',
        number: '100',
        neighborhood: 'Centro Cívico',
        city: 'Foz do Iguaçu',
        state: 'PR',
      );

      final resolver = UserCoordinatesResolver(
        brasilApiCepClient: const FakeBrasilApiCepClient(),
        geocodingClient: GeocodingClient(
          client: MockClient((request) async {
            final name = request.url.queryParameters['name'] ?? '';
            if (name == 'Foz do Iguaçu') {
              return http.Response(
                '{"results":[{"name":"Foz do Iguaçu","admin1":"Paraná","country":"Brazil","latitude":-25.5478,"longitude":-54.5882}]}',
                200,
                headers: {'content-type': 'application/json'},
              );
            }
            return http.Response('{}', 404);
          }),
        ),
      );

      final coords = await resolver.resolve(fozCepUser);

      expect(coords!.latitude, closeTo(-25.5478, 0.001));
      resolver.dispose();
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/services/address/viacep_client.dart';

void main() {
  group('FakeViaCepClient', () {
    test('returns configured address', () async {
      const client = FakeViaCepClient(result: FakeViaCepClient.fozSample);

      final address = await client.fetch('85862350');

      expect(address, isNotNull);
      expect(address!.neighborhood, 'Centro');
      expect(address.city, 'Foz do Iguaçu');
      expect(address.state, 'PR');
    });

    test('returns null when not configured', () async {
      const client = FakeViaCepClient();

      final address = await client.fetch('00000000');

      expect(address, isNull);
    });
  });
}

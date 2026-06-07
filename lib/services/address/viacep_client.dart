import 'dart:convert';

import 'package:http/http.dart' as http;

class ViaCepAddress {
  const ViaCepAddress({
    required this.cep,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
    this.complement = '',
  });

  final String cep;
  final String street;
  final String neighborhood;
  final String city;
  final String state;
  final String complement;
}

abstract class ViaCepClient {
  Future<ViaCepAddress?> fetch(String cep);
}

class LiveViaCepClient implements ViaCepClient {
  LiveViaCepClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<ViaCepAddress?> fetch(String cep) async {
    final digits = cep.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return null;

    try {
      final response = await _client
          .get(Uri.parse('https://viacep.com.br/ws/$digits/json/'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['erro'] == true) return null;

      return ViaCepAddress(
        cep: json['cep'] as String? ?? digits,
        street: json['logradouro'] as String? ?? '',
        neighborhood: json['bairro'] as String? ?? '',
        city: json['localidade'] as String? ?? '',
        state: json['uf'] as String? ?? '',
        complement: json['complemento'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.close();
}

class FakeViaCepClient implements ViaCepClient {
  const FakeViaCepClient({this.result, this.delay = Duration.zero});

  final ViaCepAddress? result;
  final Duration delay;

  static const fozSample = ViaCepAddress(
    cep: '85862-350',
    street: 'Avenida Brasil',
    neighborhood: 'Centro',
    city: 'Foz do Iguaçu',
    state: 'PR',
  );

  @override
  Future<ViaCepAddress?> fetch(String cep) async {
    await Future<void>.delayed(delay);
    return result;
  }
}

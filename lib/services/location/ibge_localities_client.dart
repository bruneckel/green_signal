import 'dart:convert';

import 'package:http/http.dart' as http;

class IbgeState {
  const IbgeState({
    required this.id,
    required this.sigla,
    required this.nome,
  });

  final int id;
  final String sigla;
  final String nome;

  factory IbgeState.fromJson(Map<String, dynamic> json) {
    return IbgeState(
      id: json['id'] as int,
      sigla: json['sigla'] as String,
      nome: json['nome'] as String,
    );
  }
}

class IbgeMunicipality {
  const IbgeMunicipality({
    required this.id,
    required this.nome,
  });

  final int id;
  final String nome;

  factory IbgeMunicipality.fromJson(Map<String, dynamic> json) {
    return IbgeMunicipality(
      id: json['id'] as int,
      nome: json['nome'] as String,
    );
  }
}

abstract class IbgeLocalitiesClient {
  Future<List<IbgeState>> fetchStates();

  Future<List<IbgeMunicipality>> fetchMunicipalities(String stateSigla);
}

class LiveIbgeLocalitiesClient implements IbgeLocalitiesClient {
  LiveIbgeLocalitiesClient({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://servicodados.ibge.gov.br/api/v1/localidades';

  final http.Client _client;

  @override
  Future<List<IbgeState>> fetchStates() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/estados?orderBy=nome'),
    );
    if (response.statusCode != 200) {
      throw IbgeLocalitiesException('Failed to load states');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((item) => IbgeState.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<IbgeMunicipality>> fetchMunicipalities(String stateSigla) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/estados/$stateSigla/municipios?orderBy=nome'),
    );
    if (response.statusCode != 200) {
      throw IbgeLocalitiesException('Failed to load municipalities');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((item) => IbgeMunicipality.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  void dispose() => _client.close();
}

class FakeIbgeLocalitiesClient implements IbgeLocalitiesClient {
  const FakeIbgeLocalitiesClient({
    this.states = const [
      IbgeState(id: 35, sigla: 'SP', nome: 'São Paulo'),
      IbgeState(id: 41, sigla: 'PR', nome: 'Paraná'),
    ],
    this.municipalitiesByState = const {
      'SP': [
        IbgeMunicipality(id: 3550308, nome: 'São Paulo'),
      ],
      'PR': [
        IbgeMunicipality(id: 4108304, nome: 'Foz do Iguaçu'),
        IbgeMunicipality(id: 4106902, nome: 'Curitiba'),
      ],
    },
    this.delay = Duration.zero,
  });

  final List<IbgeState> states;
  final Map<String, List<IbgeMunicipality>> municipalitiesByState;
  final Duration delay;

  @override
  Future<List<IbgeState>> fetchStates() async {
    await Future<void>.delayed(delay);
    return states;
  }

  @override
  Future<List<IbgeMunicipality>> fetchMunicipalities(String stateSigla) async {
    await Future<void>.delayed(delay);
    return municipalitiesByState[stateSigla] ?? const [];
  }
}

class IbgeLocalitiesException implements Exception {
  IbgeLocalitiesException(this.message);

  final String message;

  @override
  String toString() => message;
}

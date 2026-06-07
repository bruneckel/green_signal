import 'package:flutter/material.dart';

import 'home_data.dart';

class EnvironmentalIndicator {
  const EnvironmentalIndicator({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class NeighborhoodScoreData {
  const NeighborhoodScoreData({
    required this.neighborhood,
    required this.city,
    required this.riskScore,
    required this.indicators,
  });

  final String neighborhood;
  final String city;
  final int riskScore;
  final List<EnvironmentalIndicator> indicators;

  RiskLevel get riskLevel => RiskLevel.fromScore(riskScore);

  static const mock = NeighborhoodScoreData(
    neighborhood: 'Vila Madalena',
    city: 'São Paulo, SP',
    riskScore: 65,
    indicators: [
      EnvironmentalIndicator(
        icon: Icons.air,
        label: 'Qualidade do Ar',
        value: 'Moderada AQI 68',
      ),
      EnvironmentalIndicator(
        icon: Icons.thermostat_outlined,
        label: 'Temperatura',
        value: '31°C',
      ),
      EnvironmentalIndicator(
        icon: Icons.water_drop_outlined,
        label: 'Umidade',
        value: '54%',
      ),
      EnvironmentalIndicator(
        icon: Icons.grain,
        label: 'Chuva',
        value: '40%',
      ),
      EnvironmentalIndicator(
        icon: Icons.flood_outlined,
        label: 'Risco de Enchente',
        value: 'Médio',
      ),
      EnvironmentalIndicator(
        icon: Icons.local_fire_department_outlined,
        label: 'Focos de Incêndio',
        value: '2',
      ),
    ],
  );
}

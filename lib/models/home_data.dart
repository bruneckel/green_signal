import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

enum RiskLevel {
  low,
  medium,
  high;

  factory RiskLevel.fromScore(int score) {
    if (score <= 39) return RiskLevel.low;
    if (score <= 69) return RiskLevel.medium;
    return RiskLevel.high;
  }

  String get label => switch (this) {
        RiskLevel.low => 'Baixo',
        RiskLevel.medium => 'Médio',
        RiskLevel.high => 'Alto Risco',
      };

  Color get color => switch (this) {
        RiskLevel.low => AppColors.riskLow,
        RiskLevel.medium => AppColors.riskMedium,
        RiskLevel.high => AppColors.riskHigh,
      };
}

class ActiveAlert {
  const ActiveAlert({
    required this.message,
    required this.region,
  });

  final String message;
  final String region;
}

class IndicatorItem {
  const IndicatorItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class HomeData {
  const HomeData({
    required this.city,
    required this.riskScore,
    required this.alerts,
    required this.indicators,
  });

  final String city;
  final int riskScore;
  final List<ActiveAlert> alerts;
  final List<IndicatorItem> indicators;

  RiskLevel get riskLevel => RiskLevel.fromScore(riskScore);

  static const mock = HomeData(
    city: 'São Paulo, SP',
    riskScore: 83,
    alerts: [
      ActiveAlert(
        message: 'Risco de chuva intensa nas próximas 6 horas.',
        region: 'Zona Norte',
      ),
    ],
    indicators: [
      IndicatorItem(icon: Icons.air, label: 'Ar Ruim'),
      IndicatorItem(icon: Icons.thermostat_outlined, label: 'Temperatura 32°C'),
      IndicatorItem(icon: Icons.grain, label: 'Chuva 60%'),
      IndicatorItem(icon: Icons.local_fire_department_outlined, label: 'Focos de Incêndio 3'),
    ],
  );
}

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

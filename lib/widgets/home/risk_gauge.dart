import 'package:arc_gauge/arc_gauge.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/home_data.dart';

class RiskGauge extends StatelessWidget {
  const RiskGauge({
    super.key,
    required this.score,
    required this.riskLevel,
    this.width = 168,
    this.height = 118,
  });

  final int score;
  final RiskLevel riskLevel;
  final double width;
  final double height;

  static const _zones = [
    ArcZone(from: 0, to: 40, label: 'Baixo', color: AppColors.riskLow),
    ArcZone(from: 40, to: 70, label: 'Médio', color: AppColors.riskMedium),
    ArcZone(from: 70, to: 100, label: 'Alto Risco', color: AppColors.riskHigh),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ArcGauge(
        value: score.toDouble(),
        zones: _zones,
        displayValue: '$score',
        categoryLabel: riskLevel.label,
        size: Size(width, height),
        duration: const Duration(milliseconds: 500),
        valueStyle: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          height: 1,
        ),
      ),
    );
  }
}

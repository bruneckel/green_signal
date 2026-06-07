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
}

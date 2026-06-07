import 'package:latlong2/latlong.dart';

import 'home_data.dart';

class EnvironmentalSnapshot {
  const EnvironmentalSnapshot({
    required this.position,
    required this.locationLabel,
    required this.riskScore,
    required this.riskLevel,
    required this.fetchedAt,
    this.aqi,
    this.pm25,
    this.temperatureC,
    this.precipitationMm,
    this.hotspotCount = 0,
    this.isStale = false,
    this.hasError = false,
  });

  final LatLng position;
  final String locationLabel;
  final int riskScore;
  final RiskLevel riskLevel;
  final double? aqi;
  final double? pm25;
  final double? temperatureC;
  final double? precipitationMm;
  final int hotspotCount;
  final DateTime fetchedAt;
  final bool isStale;
  final bool hasError;

  static EnvironmentalSnapshot fallback({
    required LatLng position,
    required String locationLabel,
  }) {
    return EnvironmentalSnapshot(
      position: position,
      locationLabel: locationLabel,
      riskScore: HomeData.mock.riskScore,
      riskLevel: HomeData.mock.riskLevel,
      aqi: 68,
      temperatureC: 31,
      precipitationMm: 4,
      hotspotCount: 2,
      fetchedAt: DateTime.now(),
      hasError: true,
    );
  }

  EnvironmentalSnapshot copyWith({
    LatLng? position,
    String? locationLabel,
    int? riskScore,
    RiskLevel? riskLevel,
    double? aqi,
    double? pm25,
    double? temperatureC,
    double? precipitationMm,
    int? hotspotCount,
    DateTime? fetchedAt,
    bool? isStale,
    bool? hasError,
  }) {
    return EnvironmentalSnapshot(
      position: position ?? this.position,
      locationLabel: locationLabel ?? this.locationLabel,
      riskScore: riskScore ?? this.riskScore,
      riskLevel: riskLevel ?? this.riskLevel,
      aqi: aqi ?? this.aqi,
      pm25: pm25 ?? this.pm25,
      temperatureC: temperatureC ?? this.temperatureC,
      precipitationMm: precipitationMm ?? this.precipitationMm,
      hotspotCount: hotspotCount ?? this.hotspotCount,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isStale: isStale ?? this.isStale,
      hasError: hasError ?? this.hasError,
    );
  }
}

class ResolvedLocation {
  const ResolvedLocation({
    required this.position,
    required this.label,
    required this.neighborhood,
  });

  final LatLng position;
  final String label;
  final String neighborhood;
}

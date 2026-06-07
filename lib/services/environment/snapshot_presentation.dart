import 'package:flutter/material.dart';

import '../../models/environmental_snapshot.dart';
import '../../models/home_data.dart';
import '../../models/neighborhood_score_data.dart';
import '../map/map_intensity_mapper.dart';

abstract final class SnapshotPresentation {
  static String airQualityLabel(double? aqi) {
    if (aqi == null) return 'Ar —';
    if (aqi <= 20) return 'Bom AQI ${aqi.round()}';
    if (aqi <= 50) return 'Moderada AQI ${aqi.round()}';
    if (aqi <= 100) return 'Ruim AQI ${aqi.round()}';
    return 'Péssima AQI ${aqi.round()}';
  }

  static String airQualityShortLabel(double? aqi) {
    if (aqi == null) return 'Ar —';
    if (aqi <= 20) return 'Ar Bom';
    if (aqi <= 50) return 'Ar Moderado';
    if (aqi <= 100) return 'Ar Ruim';
    return 'Ar Péssimo';
  }

  static String rainLabel(double? precipitationMm, MapIntensityMapper mapper) {
    if (precipitationMm == null) return 'Chuva —';
    final normalized = mapper.normalizePrecipitation(precipitationMm);
    return 'Chuva ${(normalized * 100).round()}%';
  }

  static List<IndicatorItem> toHomeIndicators(EnvironmentalSnapshot snapshot) {
    final mapper = const MapIntensityMapper();
    return [
      IndicatorItem(
        icon: Icons.air,
        label: airQualityShortLabel(snapshot.aqi),
      ),
      IndicatorItem(
        icon: Icons.thermostat_outlined,
        label: snapshot.temperatureC != null
            ? 'Temperatura ${snapshot.temperatureC!.round()}°C'
            : 'Temperatura —',
      ),
      IndicatorItem(
        icon: Icons.grain,
        label: rainLabel(snapshot.precipitationMm, mapper),
      ),
      IndicatorItem(
        icon: Icons.local_fire_department_outlined,
        label: 'Focos de Incêndio ${snapshot.hotspotCount}',
      ),
    ];
  }

  static List<EnvironmentalIndicator> toScoreIndicators(
    EnvironmentalSnapshot snapshot,
  ) {
    final mapper = const MapIntensityMapper();
    return [
      EnvironmentalIndicator(
        icon: Icons.air,
        label: 'Qualidade do Ar',
        value: airQualityLabel(snapshot.aqi),
      ),
      EnvironmentalIndicator(
        icon: Icons.thermostat_outlined,
        label: 'Temperatura',
        value: snapshot.temperatureC != null
            ? '${snapshot.temperatureC!.round()}°C'
            : '—',
      ),
      EnvironmentalIndicator(
        icon: Icons.grain,
        label: 'Chuva',
        value: rainLabel(snapshot.precipitationMm, mapper),
      ),
      EnvironmentalIndicator(
        icon: Icons.local_fire_department_outlined,
        label: 'Focos de Incêndio',
        value: '${snapshot.hotspotCount}',
      ),
    ];
  }

  static NeighborhoodScoreData toNeighborhoodScoreData({
    required EnvironmentalSnapshot snapshot,
    required ResolvedLocation location,
  }) {
    return NeighborhoodScoreData(
      neighborhood: location.neighborhood,
      city: location.label,
      riskScore: snapshot.riskScore,
      indicators: toScoreIndicators(snapshot),
    );
  }
}

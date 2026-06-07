import 'package:flutter/material.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants/map_strings.dart';
import '../core/theme/app_colors.dart';

enum MapLayer {
  airQuality,
  temperature,
  rain,
  hotspots;

  String get label => switch (this) {
        MapLayer.airQuality => MapStrings.layerAirQuality,
        MapLayer.temperature => MapStrings.layerTemperature,
        MapLayer.rain => MapStrings.layerRain,
        MapLayer.hotspots => MapStrings.layerHotspots,
      };
}

class MapLayerData {
  const MapLayerData({required this.points});

  final List<WeightedLatLng> points;

  static const saoPauloCenter = LatLng(-23.5505, -46.6333);
  static const initialZoom = 10.0;
  static const minZoom = 8.0;
  static const maxZoom = 16.0;

  static final riskGradient = <double, MaterialColor>{
    0.0: Colors.green,
    0.25: Colors.yellow,
    0.5: Colors.orange,
    0.75: Colors.red,
    1.0: Colors.purple,
  };

  static MapLayerData forLayer(MapLayer layer) {
    return MapLayerData(points: _pointsFor(layer));
  }

  static Color colorForIntensity(double intensity) {
    if (intensity <= 0.39) return AppColors.riskLow;
    if (intensity <= 0.69) return AppColors.riskMedium;
    if (intensity <= 0.85) return Colors.orange;
    if (intensity <= 0.95) return AppColors.riskHigh;
    return Colors.purple;
  }

  static List<WeightedLatLng> _pointsFor(MapLayer layer) {
    final seeds = switch (layer) {
      MapLayer.airQuality => _airQualitySeeds,
      MapLayer.temperature => _temperatureSeeds,
      MapLayer.rain => _rainSeeds,
      MapLayer.hotspots => _hotspotSeeds,
    };
    return _expandSeeds(seeds);
  }

  /// Gera pontos próximos aos seeds para heatmap contínuo e suave.
  static List<WeightedLatLng> _expandSeeds(List<(LatLng, double)> seeds) {
    const offsets = [
      (0.0, 0.0),
      (0.012, 0.008),
      (-0.01, 0.012),
      (0.015, -0.01),
      (-0.014, -0.008),
      (0.006, 0.018),
      (-0.018, 0.004),
      (0.02, 0.014),
    ];

    final points = <WeightedLatLng>[];
    for (final (center, intensity) in seeds) {
      for (final (dLat, dLng) in offsets) {
        final falloff = 1 - (dLat.abs() + dLng.abs()) * 8;
        points.add(
          WeightedLatLng(
            LatLng(center.latitude + dLat, center.longitude + dLng),
            (intensity * falloff).clamp(0.2, 1.0),
          ),
        );
      }
    }
    return points;
  }

  static const _airQualitySeeds = [
    (LatLng(-23.5505, -46.6333), 0.95),
    (LatLng(-23.5300, -46.6100), 0.82),
    (LatLng(-23.5700, -46.6600), 0.88),
    (LatLng(-23.5100, -46.6800), 0.65),
    (LatLng(-23.5900, -46.7000), 0.72),
    (LatLng(-23.4900, -46.5900), 0.48),
    (LatLng(-23.6100, -46.6200), 0.58),
    (LatLng(-23.5400, -46.7200), 0.55),
  ];

  static const _temperatureSeeds = [
    (LatLng(-23.5505, -46.6333), 1.0),
    (LatLng(-23.5450, -46.6250), 0.92),
    (LatLng(-23.5580, -46.6400), 0.88),
    (LatLng(-23.5350, -46.6450), 0.75),
    (LatLng(-23.5200, -46.6300), 0.62),
    (LatLng(-23.5650, -46.6150), 0.68),
  ];

  static const _rainSeeds = [
    (LatLng(-23.4800, -46.7500), 0.9),
    (LatLng(-23.4650, -46.7200), 0.78),
    (LatLng(-23.4950, -46.7800), 0.85),
    (LatLng(-23.5505, -46.6333), 0.35),
    (LatLng(-23.5600, -46.6000), 0.28),
    (LatLng(-23.5200, -46.6700), 0.52),
    (LatLng(-23.5100, -46.7100), 0.6),
  ];

  static const _hotspotSeeds = [
    (LatLng(-23.6100, -46.7100), 1.0),
    (LatLng(-23.4700, -46.5800), 0.92),
    (LatLng(-23.5200, -46.7800), 0.85),
    (LatLng(-23.6500, -46.6200), 0.7),
    (LatLng(-23.5505, -46.6333), 0.3),
  ];
}

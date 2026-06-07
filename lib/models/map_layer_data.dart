import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants/map_config.dart';
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

enum MapLayerDisplayMode { heatmap, markers }

class MapLayerStyle {
  const MapLayerStyle({
    required this.displayMode,
    required this.gradient,
    required this.legendLow,
    required this.legendHigh,
    this.heatmapOptionsBuilder,
  });

  final MapLayerDisplayMode displayMode;
  final Map<double, MaterialColor> gradient;
  final String legendLow;
  final String legendHigh;
  final HeatMapOptions Function(
    double zoom,
    Map<double, MaterialColor> gradient, {
    double latStep,
    double lngStep,
    double latitude,
  })? heatmapOptionsBuilder;
}

extension MapLayerVisual on MapLayer {
  MapLayerStyle get style => switch (this) {
        MapLayer.airQuality => MapLayerStyle(
            displayMode: MapLayerDisplayMode.heatmap,
            gradient: MapLayerData.airQualityGradient,
            legendLow: MapStrings.legendAirLow,
            legendHigh: MapStrings.legendAirHigh,
            heatmapOptionsBuilder: MapLayerData.calibratedHeatmapOptions,
          ),
        MapLayer.temperature => MapLayerStyle(
            displayMode: MapLayerDisplayMode.heatmap,
            gradient: MapLayerData.temperatureGradient,
            legendLow: MapStrings.legendTempLow,
            legendHigh: MapStrings.legendTempHigh,
            heatmapOptionsBuilder: MapLayerData.calibratedHeatmapOptions,
          ),
        MapLayer.rain => MapLayerStyle(
            displayMode: MapLayerDisplayMode.heatmap,
            gradient: MapLayerData.rainGradient,
            legendLow: MapStrings.legendRainLow,
            legendHigh: MapStrings.legendRainHigh,
            heatmapOptionsBuilder: MapLayerData.softHeatmapOptions,
          ),
        MapLayer.hotspots => MapLayerStyle(
            displayMode: MapLayerDisplayMode.markers,
            gradient: MapLayerData.burnGradient,
            legendLow: MapStrings.legendBurnLow,
            legendHigh: MapStrings.legendBurnHigh,
          ),
      };
}

class MapLayerData {
  static const saoPauloCenter = LatLng(-23.5505, -46.6333);
  static const initialZoom = 10.0;
  static const minZoom = 8.0;
  static const maxZoom = 16.0;

  static final airQualityGradient = <double, MaterialColor>{
    0.0: Colors.green,
    0.25: Colors.yellow,
    0.5: Colors.orange,
    0.75: Colors.red,
    1.0: Colors.purple,
  };

  static final temperatureGradient = <double, MaterialColor>{
    0.0: Colors.blue,
    0.35: Colors.lightBlue,
    0.55: Colors.yellow,
    0.75: Colors.orange,
    1.0: Colors.red,
  };

  static final rainGradient = <double, MaterialColor>{
    0.0: Colors.cyan,
    0.3: Colors.lightBlue,
    0.6: Colors.blue,
    1.0: Colors.indigo,
  };

  static final burnGradient = <double, MaterialColor>{
    0.0: Colors.orange,
    0.5: Colors.deepOrange,
    1.0: Colors.red,
  };

  static HeatMapOptions defaultHeatmapOptions(
    double zoom,
    Map<double, MaterialColor> gradient, {
    double latStep = 0,
    double lngStep = 0,
    double latitude = -23.5505,
  }) {
    return HeatMapOptions(
      gradient: gradient,
      minOpacity: 0.1,
      radius: 35 + zoom * 3,
      layerOpacity: 0.45,
      blurFactor: 0.55,
    );
  }

  static HeatMapOptions softHeatmapOptions(
    double zoom,
    Map<double, MaterialColor> gradient, {
    double latStep = 0,
    double lngStep = 0,
    double latitude = -23.5505,
  }) {
    return HeatMapOptions(
      gradient: gradient,
      minOpacity: 0.08,
      radius: 35 + zoom * 3,
      layerOpacity: 0.42,
      blurFactor: 0.55,
    );
  }

  static HeatMapOptions calibratedHeatmapOptions(
    double zoom,
    Map<double, MaterialColor> gradient, {
    double latStep = 0,
    double lngStep = 0,
    double latitude = -23.5505,
  }) {
    final radius = latStep > 0 && lngStep > 0
        ? cellRadiusPixels(
            zoom: zoom,
            latitude: latitude,
            latStep: latStep,
            lngStep: lngStep,
          )
        : _minHeatmapRadius(zoom);

    return HeatMapOptions(
      gradient: gradient,
      minOpacity: 0.25,
      radius: radius,
      layerOpacity: 0.58,
      blurFactor: 0.72,
    );
  }

  static double _minHeatmapRadius(double zoom) => 32 + zoom * 4;

  static double cellRadiusPixels({
    required double zoom,
    required double latitude,
    required double latStep,
    required double lngStep,
  }) {
    final metersPerPixel = 156543.03392 *
        math.cos(latitude * math.pi / 180) /
        math.pow(2, zoom);
    const metersPerDegreeLat = 111320.0;
    final latMeters = latStep * metersPerDegreeLat;
    final lngMeters =
        lngStep * metersPerDegreeLat * math.cos(latitude * math.pi / 180);
    final cellMeters = math.min(latMeters, lngMeters);
    final computed = (cellMeters / metersPerPixel) * 0.80;
    return math.max(computed, _minHeatmapRadius(zoom));
  }

  static Color colorFromGradient(
    Map<double, MaterialColor> gradient,
    double intensity,
  ) {
    final t = intensity.clamp(0.0, 1.0);
    final stops = gradient.keys.toList()..sort();
    if (stops.isEmpty) return Colors.grey;
    if (t <= stops.first) return gradient[stops.first]!;
    if (t >= stops.last) return gradient[stops.last]!;

    for (var i = 0; i < stops.length - 1; i++) {
      final low = stops[i];
      final high = stops[i + 1];
      if (t >= low && t <= high) {
        final fraction = (t - low) / (high - low);
        return Color.lerp(gradient[low], gradient[high], fraction)!;
      }
    }
    return gradient[stops.last]!;
  }

  static Color colorForFrp(double frp) {
    final normalized = (frp / MapConfig.frpMaxScale).clamp(0.0, 1.0);
    if (normalized <= 0.25) return Colors.orange;
    if (normalized <= 0.5) return Colors.deepOrange;
    if (normalized <= 0.75) return AppColors.riskHigh;
    return Colors.red.shade900;
  }

  static Color colorForIntensity(double intensity) {
    if (intensity <= 0.39) return AppColors.riskLow;
    if (intensity <= 0.69) return AppColors.riskMedium;
    if (intensity <= 0.85) return Colors.orange;
    if (intensity <= 0.95) return AppColors.riskHigh;
    return Colors.purple;
  }

  static List<Color> gradientColors(Map<double, MaterialColor> gradient) {
    return gradient.entries.map((e) => e.value).toList();
  }
}

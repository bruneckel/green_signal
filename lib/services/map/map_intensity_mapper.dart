import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/map_config.dart';
import '../../models/grid_sample_point.dart';


class MapIntensityMapper {
  const MapIntensityMapper();

  double normalizeAirQuality({double? aqi, double? pm25}) {
    if (aqi != null) {
      if (aqi <= 0) return 0;
      if (aqi <= 20) return aqi / 80;
      if (aqi <= 50) return 0.25 + (aqi - 20) / 120;
      if (aqi <= 100) return 0.5 + (aqi - 50) / 200;
      if (aqi <= 150) return 0.75 + (aqi - 100) / 200;
      return 1.0;
    }
    return normalizePm25(pm25);
  }

  double normalizePm25(double? pm25) {
    if (pm25 == null) return 0.3;
    if (pm25 <= 0) return 0;
    if (pm25 <= 10) return pm25 / 40;
    if (pm25 <= 25) return 0.25 + (pm25 - 10) / 60;
    if (pm25 <= 50) return 0.5 + (pm25 - 25) / 100;
    if (pm25 <= 75) return 0.75 + (pm25 - 50) / 100;
    return 1.0;
  }

  double normalizeTemperatureAbsolute(double celsius) {
    return ((celsius - MapConfig.tempScaleMinC) /
            (MapConfig.tempScaleMaxC - MapConfig.tempScaleMinC))
        .clamp(0.0, 1.0);
  }

  double normalizePrecipitation(double? mm) {
    if (mm == null || mm <= 0) return 0;
    if (mm <= 1) return mm * 0.3;
    if (mm <= 5) return 0.3 + (mm - 1) / 10;
    if (mm <= 15) return 0.6 + (mm - 5) / 25;
    return 1.0;
  }

  double normalizeFrp(double frp, {double? min, double? max}) {
    if (min != null && max != null && max > min) {
      return ((frp - min) / (max - min)).clamp(0.2, 1.0);
    }
    return (frp / MapConfig.frpMaxScale).clamp(0.2, 1.0);
  }

  List<WeightedLatLng> toCalibratedHeatmapPoints(List<GridSamplePoint> samples) {
    return samples
        .map(
          (s) => WeightedLatLng(
            s.position,
            s.intensity.clamp(0.0, 1.0),
          ),
        )
        .toList();
  }

  List<WeightedLatLng> toHeatmapPoints(
    List<GridSamplePoint> samples, {
    required double latStep,
    required double lngStep,
  }) {
    return expandSeeds(
      samples.map((s) => (s.position, s.intensity)).toList(),
      latStep: latStep,
      lngStep: lngStep,
    );
  }

  List<WeightedLatLng> expandSeeds(
    List<(LatLng, double)> seeds, {
    required double latStep,
    required double lngStep,
  }) {
    final dLat = latStep / 3;
    final dLng = lngStep / 3;
    final offsets = [
      (0.0, 0.0),
      (dLat, 0.0),
      (-dLat, 0.0),
      (0.0, dLng),
      (0.0, -dLng),
      (dLat, dLng),
      (-dLat, dLng),
      (dLat, -dLng),
      (-dLat, -dLng),
    ];

    final falloffScale = 3 / (latStep + lngStep + 0.001);

    final points = <WeightedLatLng>[];
    for (final (center, intensity) in seeds) {
      for (final (offsetLat, offsetLng) in offsets) {
        final falloff = 1 - (offsetLat.abs() + offsetLng.abs()) * falloffScale;
        points.add(
          WeightedLatLng(
            LatLng(center.latitude + offsetLat, center.longitude + offsetLng),
            (intensity * falloff).clamp(0.2, 1.0),
          ),
        );
      }
    }
    return points;
  }

  List<GridSamplePoint> mapAirQualitySamples(
    List<(LatLng position, double? aqi, double? pm25)> raw,
  ) {
    return raw
        .map(
          (entry) => GridSamplePoint(
            position: entry.$1,
            intensity: normalizeAirQuality(aqi: entry.$2, pm25: entry.$3),
          ),
        )
        .toList();
  }

  List<GridSamplePoint> mapTemperatureSamples(
    List<(LatLng position, double? temp)> raw,
  ) {
    return raw
        .where((e) => e.$2 != null)
        .map(
          (entry) => GridSamplePoint(
            position: entry.$1,
            intensity: normalizeTemperatureAbsolute(entry.$2!),
          ),
        )
        .toList();
  }

  List<GridSamplePoint> mapRainSamples(
    List<(LatLng position, double? precipitation)> raw,
  ) {
    return raw
        .map(
          (entry) => GridSamplePoint(
            position: entry.$1,
            intensity: normalizePrecipitation(entry.$2),
          ),
        )
        .where((s) => s.intensity > 0)
        .toList();
  }
}

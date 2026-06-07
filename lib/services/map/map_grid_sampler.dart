import 'package:latlong2/latlong.dart';

import '../../core/constants/map_config.dart';

class GridSampleResult {
  const GridSampleResult({
    required this.points,
    required this.latStep,
    required this.lngStep,
  });

  final List<LatLng> points;
  final double latStep;
  final double lngStep;
}

class MapGridSampler {
  const MapGridSampler();

  GridSampleResult sample(LatLngBounds bounds, double zoom) {
    final south = bounds.south;
    final north = bounds.north;
    final west = bounds.west;
    final east = bounds.east;

    final latSpan = (north - south).abs();
    final lngSpan = (east - west).abs();
    if (latSpan == 0 || lngSpan == 0) {
      return GridSampleResult(
        points: [LatLng((south + north) / 2, (west + east) / 2)],
        latStep: 0.06,
        lngStep: 0.06,
      );
    }

    final step = _stepForZoom(zoom);
    var cols = ((lngSpan / step).ceil()).clamp(1, 8);
    var rows = ((latSpan / step).ceil()).clamp(1, 8);

    while (cols * rows > MapConfig.maxGridPoints) {
      if (cols >= rows && cols > 1) {
        cols--;
      } else if (rows > 1) {
        rows--;
      } else {
        break;
      }
    }

    final latStep = latSpan / rows;
    final lngStep = lngSpan / cols;
    final points = <LatLng>[];

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final lat = south + latStep * (row + 0.5);
        final lng = west + lngStep * (col + 0.5);
        points.add(LatLng(lat, lng));
      }
    }

    return GridSampleResult(
      points: points,
      latStep: latStep,
      lngStep: lngStep,
    );
  }

  double _stepForZoom(double zoom) {
    if (zoom <= 9) return 0.10;
    if (zoom <= 11) return 0.035;
    if (zoom <= 13) return 0.018;
    return 0.012;
  }
}

class LatLngBounds {
  const LatLngBounds({
    required this.south,
    required this.north,
    required this.west,
    required this.east,
  });

  final double south;
  final double north;
  final double west;
  final double east;

  bool contains(LatLng point) {
    return point.latitude >= south &&
        point.latitude <= north &&
        point.longitude >= west &&
        point.longitude <= east;
  }

  String cacheKey() {
    String round(double v) => v.toStringAsFixed(2);
    return '${round(south)}_${round(north)}_${round(west)}_${round(east)}';
  }

  factory LatLngBounds.fromMapBounds({
    required double south,
    required double north,
    required double west,
    required double east,
  }) {
    return LatLngBounds(
      south: south,
      north: north,
      west: west,
      east: east,
    );
  }

  static LatLngBounds fromCenterZoom(LatLng center, double zoom) {
    final span = _spanForZoom(zoom);
    return LatLngBounds(
      south: center.latitude - span,
      north: center.latitude + span,
      west: center.longitude - span,
      east: center.longitude + span,
    );
  }

  static double _spanForZoom(double zoom) {
    if (zoom <= 8) return 0.45;
    if (zoom <= 10) return 0.22;
    if (zoom <= 12) return 0.11;
    return 0.055;
  }
}

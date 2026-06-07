import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/services/map/map_grid_sampler.dart';
import 'package:latlong2/latlong.dart';

void main() {
  const sampler = MapGridSampler();

  group('MapGridSampler', () {
    test('returns at most maxGridPoints', () {
      const bounds = LatLngBounds(
        south: -24,
        north: -23,
        west: -47,
        east: -46,
      );

      final result = sampler.sample(bounds, 10);
      expect(result.points.length, lessThanOrEqualTo(64));
      expect(result.points, isNotEmpty);
      expect(result.latStep, greaterThan(0));
      expect(result.lngStep, greaterThan(0));
    });

    test('points are inside bounds', () {
      const bounds = LatLngBounds(
        south: -23.7,
        north: -23.4,
        west: -46.8,
        east: -46.5,
      );

      final result = sampler.sample(bounds, 11);
      for (final point in result.points) {
        expect(bounds.contains(point), isTrue);
      }
    });

    test('fromCenterZoom produces valid bounds', () {
      const center = LatLng(-23.55, -46.63);
      final bounds = LatLngBounds.fromCenterZoom(center, 10);

      expect(bounds.contains(center), isTrue);
      expect(bounds.north, greaterThan(bounds.south));
      expect(bounds.east, greaterThan(bounds.west));
    });
  });
}

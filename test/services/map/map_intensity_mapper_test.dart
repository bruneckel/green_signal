import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/core/constants/map_config.dart';
import 'package:green_signal/models/map_layer_data.dart';
import 'package:green_signal/services/map/map_intensity_mapper.dart';
import 'package:latlong2/latlong.dart';

void main() {
  const mapper = MapIntensityMapper();

  group('MapIntensityMapper', () {
    test('normalizeAirQuality maps known thresholds', () {
      expect(mapper.normalizeAirQuality(aqi: 0), 0);
      expect(mapper.normalizeAirQuality(aqi: 20), closeTo(0.25, 0.01));
      expect(mapper.normalizeAirQuality(aqi: 50), closeTo(0.5, 0.01));
      expect(mapper.normalizeAirQuality(aqi: 100), closeTo(0.75, 0.01));
      expect(mapper.normalizeAirQuality(aqi: 200), 1.0);
    });

    test('normalizeAirQuality falls back to pm2_5', () {
      expect(
        mapper.normalizeAirQuality(aqi: null, pm25: 12.0),
        closeTo(0.28, 0.02),
      );
    });

    test('normalizeTemperatureAbsolute uses fixed Celsius scale', () {
      expect(
        mapper.normalizeTemperatureAbsolute(MapConfig.tempScaleMinC),
        0,
      );
      expect(
        mapper.normalizeTemperatureAbsolute(
          (MapConfig.tempScaleMinC + MapConfig.tempScaleMaxC) / 2,
        ),
        closeTo(0.5, 0.01),
      );
      expect(
        mapper.normalizeTemperatureAbsolute(MapConfig.tempScaleMaxC),
        1,
      );
      expect(mapper.normalizeTemperatureAbsolute(10), 0);
      expect(mapper.normalizeTemperatureAbsolute(40), 1);
    });

    test('normalizePrecipitation scales rainfall', () {
      expect(mapper.normalizePrecipitation(0), 0);
      expect(mapper.normalizePrecipitation(1), closeTo(0.3, 0.01));
      expect(mapper.normalizePrecipitation(20), 1.0);
    });

    test('expandSeeds uses proportional offsets', () {
      const center = LatLng(-23.55, -46.63);
      final points = mapper.expandSeeds(
        [(center, 0.8)],
        latStep: 0.06,
        lngStep: 0.06,
      );

      expect(points.length, greaterThan(1));
      expect(points.every((p) => p.intensity >= 0.2), isTrue);
    });

    test('toCalibratedHeatmapPoints creates one point per sample', () {
      const center = LatLng(-23.55, -46.63);
      final samples = mapper.mapTemperatureSamples([(center, 22.0)]);
      final points = mapper.toCalibratedHeatmapPoints(samples);

      expect(points, hasLength(1));
      expect(
        points.first.intensity,
        closeTo(mapper.normalizeTemperatureAbsolute(22.0), 0.01),
      );
    });

    test('mapTemperatureSamples uses absolute scale', () {
      const a = LatLng(-23.55, -46.63);
      const b = LatLng(-23.56, -46.64);
      final samples = mapper.mapTemperatureSamples([
        (a, 20.0),
        (b, 30.0),
      ]);

      expect(samples, hasLength(2));
      expect(samples.first.intensity, lessThan(samples.last.intensity));
      expect(
        samples.first.intensity,
        closeTo(mapper.normalizeTemperatureAbsolute(20.0), 0.01),
      );
    });
  });

  group('MapLayerData cellRadiusPixels', () {
    test('radius in pixels increases as zoom increases', () {
      const lat = -23.55;
      const step = 0.04;

      final zoom10 = MapLayerData.cellRadiusPixels(
        zoom: 10,
        latitude: lat,
        latStep: step,
        lngStep: step,
      );
      final zoom12 = MapLayerData.cellRadiusPixels(
        zoom: 12,
        latitude: lat,
        latStep: step,
        lngStep: step,
      );

      expect(zoom12, greaterThan(zoom10));
    });

    test('radius respects minimum floor at zoom 10', () {
      final radius = MapLayerData.cellRadiusPixels(
        zoom: 10,
        latitude: -23.55,
        latStep: 0.001,
        lngStep: 0.001,
      );

      expect(radius, greaterThanOrEqualTo(72));
    });
  });

  group('MapLayerData calibratedHeatmapOptions', () {
    test('uses minimum radius when grid steps are provided', () {
      final options = MapLayerData.calibratedHeatmapOptions(
        10,
        MapLayerData.temperatureGradient,
        latStep: 0.001,
        lngStep: 0.001,
      );

      expect(options.radius, greaterThanOrEqualTo(72));
      expect(options.minOpacity, 0.25);
      expect(options.layerOpacity, 0.58);
    });
  });
}

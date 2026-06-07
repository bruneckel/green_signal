import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/services/environment/risk_score_calculator.dart';
import 'package:green_signal/services/map/map_intensity_mapper.dart';

void main() {
  const calculator = RiskScoreCalculator();
  const mapper = MapIntensityMapper();

  group('RiskScoreCalculator', () {
    test('returns 0 for ideal conditions', () {
      final score = calculator.calculate(
        aqi: 0,
        temperatureC: 15,
        precipitationMm: 0,
        hotspotCount: 0,
      );

      expect(score, 0);
    });

    test('returns 100 for worst-case inputs', () {
      final score = calculator.calculate(
        aqi: 150,
        temperatureC: 35,
        precipitationMm: 20,
        hotspotCount: 10,
      );

      expect(score, 100);
    });

    test('weights air quality at 35%', () {
      final airOnly = calculator.calculate(
        aqi: 150,
        temperatureC: 15,
        precipitationMm: 0,
        hotspotCount: 0,
      );
      final normalizedAir = mapper.normalizeAirQuality(aqi: 150);

      expect(airOnly, (normalizedAir * 35).round());
    });

    test('combines all factors with configured weights', () {
      final score = calculator.calculate(
        aqi: 68,
        temperatureC: 31,
        precipitationMm: 4,
        hotspotCount: 2,
      );

      final air = mapper.normalizeAirQuality(aqi: 68);
      final temp = mapper.normalizeTemperatureAbsolute(31);
      final rain = mapper.normalizePrecipitation(4);
      const fire = 2 / 5;

      final expected =
          ((air * 0.35) + (temp * 0.25) + (rain * 0.20) + (fire * 0.20)) *
              100;

      expect(score, expected.round().clamp(0, 100));
    });
  });
}

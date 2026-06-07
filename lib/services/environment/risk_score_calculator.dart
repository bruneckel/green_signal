import '../../models/environmental_snapshot.dart';
import '../map/map_intensity_mapper.dart';

class RiskScoreCalculator {
  const RiskScoreCalculator({MapIntensityMapper? mapper})
      : _mapper = mapper ?? const MapIntensityMapper();

  final MapIntensityMapper _mapper;

  int calculate({
    double? aqi,
    double? pm25,
    double? temperatureC,
    double? precipitationMm,
    int hotspotCount = 0,
  }) {
    final air = _mapper.normalizeAirQuality(aqi: aqi, pm25: pm25);
    final temp = temperatureC != null
        ? _mapper.normalizeTemperatureAbsolute(temperatureC)
        : 0.0;
    final rain = _mapper.normalizePrecipitation(precipitationMm);
    final fire = (hotspotCount / 5).clamp(0.0, 1.0);

    const airWeight = 0.35;
    const tempWeight = 0.25;
    const rainWeight = 0.20;
    const fireWeight = 0.20;

    final weighted = (air * airWeight) +
        (temp * tempWeight) +
        (rain * rainWeight) +
        (fire * fireWeight);

    return (weighted * 100).round().clamp(0, 100);
  }

  int calculateFromSnapshot(EnvironmentalSnapshot snapshot) {
    return calculate(
      aqi: snapshot.aqi,
      pm25: snapshot.pm25,
      temperatureC: snapshot.temperatureC,
      precipitationMm: snapshot.precipitationMm,
      hotspotCount: snapshot.hotspotCount,
    );
  }
}

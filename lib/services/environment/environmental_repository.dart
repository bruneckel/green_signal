import 'package:latlong2/latlong.dart';

import '../../core/constants/map_config.dart';
import '../../models/inpe_hotspot_point.dart';
import '../../models/environmental_snapshot.dart';
import '../../models/home_data.dart';
import '../map/inpe_focos_client.dart';
import '../map/open_meteo_client.dart';
import 'risk_score_calculator.dart';

abstract class EnvironmentalRepository {
  Future<EnvironmentalSnapshot> fetchSnapshot({
    required LatLng point,
    required String locationLabel,
  });
}

class LiveEnvironmentalRepository implements EnvironmentalRepository {
  LiveEnvironmentalRepository({
    OpenMeteoClient? openMeteoClient,
    InpeFocosClient? inpeFocosClient,
    RiskScoreCalculator? scoreCalculator,
  })  : _openMeteo = openMeteoClient ?? OpenMeteoClient(),
        _inpe = inpeFocosClient ?? InpeFocosClient(),
        _calculator = scoreCalculator ?? const RiskScoreCalculator();

  final OpenMeteoClient _openMeteo;
  final InpeFocosClient _inpe;
  final RiskScoreCalculator _calculator;

  final _cache = <String, _SnapshotCacheEntry>{};

  @override
  Future<EnvironmentalSnapshot> fetchSnapshot({
    required LatLng point,
    required String locationLabel,
  }) async {
    final cacheKey = _cacheKey(point);
    final cached = _cache[cacheKey];
    if (cached != null && cached.isValid) {
      return cached.snapshot;
    }

    try {
      final results = await Future.wait([
        _openMeteo.fetchAirQuality(point),
        _openMeteo.fetchWeather(point),
        _openMeteo.fetchRainForecast(point),
      ]);

      final air = results[0];
      final weather = results[1];
      final rain = results[2];

      final allHotspots = await _inpe.fetchAll();
      final hotspotCount = _countHotspotsNearby(point, allHotspots);

      final riskScore = _calculator.calculate(
        aqi: air.europeanAqi,
        pm25: air.pm25,
        temperatureC: weather.temperature,
        precipitationMm: rain.precipitation,
        hotspotCount: hotspotCount,
      );

      final snapshot = EnvironmentalSnapshot(
        position: point,
        locationLabel: locationLabel,
        riskScore: riskScore,
        riskLevel: RiskLevel.fromScore(riskScore),
        aqi: air.europeanAqi,
        pm25: air.pm25,
        temperatureC: weather.temperature,
        precipitationMm: rain.precipitation,
        hotspotCount: hotspotCount,
        fetchedAt: DateTime.now(),
      );

      _cache[cacheKey] = _SnapshotCacheEntry(
        snapshot: snapshot,
        expiresAt: DateTime.now().add(
          Duration(minutes: MapConfig.openMeteoCacheTtlMinutes),
        ),
      );
      return snapshot;
    } catch (_) {
      final stale = cached?.snapshot;
      if (stale != null) {
        return EnvironmentalSnapshot(
          position: stale.position,
          locationLabel: stale.locationLabel,
          riskScore: stale.riskScore,
          riskLevel: stale.riskLevel,
          aqi: stale.aqi,
          pm25: stale.pm25,
          temperatureC: stale.temperatureC,
          precipitationMm: stale.precipitationMm,
          hotspotCount: stale.hotspotCount,
          fetchedAt: stale.fetchedAt,
          isStale: true,
          hasError: true,
        );
      }

      return EnvironmentalSnapshot.fallback(
        position: point,
        locationLabel: locationLabel,
      );
    }
  }

  int _countHotspotsNearby(LatLng center, List<InpeHotspotPoint> points) {
    const distance = Distance();
    return points.where((point) {
      return distance.as(
            LengthUnit.Kilometer,
            center,
            point.position,
          ) <=
          MapConfig.snapshotHotspotRadiusKm;
    }).length;
  }

  String _cacheKey(LatLng point) {
    return '${point.latitude.toStringAsFixed(2)},${point.longitude.toStringAsFixed(2)}';
  }

  void dispose() {
    _openMeteo.dispose();
    _inpe.dispose();
  }
}

class _SnapshotCacheEntry {
  _SnapshotCacheEntry({required this.snapshot, required this.expiresAt});

  final EnvironmentalSnapshot snapshot;
  final DateTime expiresAt;

  bool get isValid => DateTime.now().isBefore(expiresAt);
}

class FakeEnvironmentalRepository implements EnvironmentalRepository {
  FakeEnvironmentalRepository({
    this.delay = Duration.zero,
    EnvironmentalSnapshot? snapshot,
    this.shouldFail = false,
  }) : _snapshot = snapshot ?? _defaultSnapshot;

  final Duration delay;
  final bool shouldFail;
  final EnvironmentalSnapshot _snapshot;

  static final _defaultSnapshot = EnvironmentalSnapshot(
    position: const LatLng(-23.5505, -46.6333),
    locationLabel: 'São Paulo, SP',
    riskScore: 83,
    riskLevel: RiskLevel.fromScore(83),
    aqi: 68,
    temperatureC: 31,
    precipitationMm: 4,
    hotspotCount: 2,
    fetchedAt: DateTime(2026, 1, 1),
  );

  @override
  Future<EnvironmentalSnapshot> fetchSnapshot({
    required LatLng point,
    required String locationLabel,
  }) async {
    await Future<void>.delayed(delay);
    if (shouldFail) {
      return EnvironmentalSnapshot.fallback(
        position: point,
        locationLabel: locationLabel,
      );
    }

    return _snapshot.copyWith(
      position: point,
      locationLabel: locationLabel,
    );
  }
}

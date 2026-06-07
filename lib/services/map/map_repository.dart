import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/map_config.dart';
import '../../models/inpe_hotspot_point.dart';
import '../../models/map_fetch_result.dart';
import '../../models/map_layer_data.dart';
import 'inpe_focos_client.dart';
import 'map_cache.dart';
import 'map_grid_sampler.dart';
import 'map_intensity_mapper.dart';
import 'open_meteo_client.dart';

abstract class MapRepository {
  Future<MapFetchResult> fetchLayer({
    required MapLayer layer,
    required LatLngBounds bounds,
    required double zoom,
  });
}

class LiveMapRepository implements MapRepository {
  LiveMapRepository({
    OpenMeteoClient? openMeteoClient,
    InpeFocosClient? inpeFocosClient,
    MapGridSampler? gridSampler,
    MapIntensityMapper? intensityMapper,
    MapCache? cache,
  })  : _openMeteo = openMeteoClient ?? OpenMeteoClient(),
        _inpe = inpeFocosClient ?? InpeFocosClient(),
        _gridSampler = gridSampler ?? const MapGridSampler(),
        _mapper = intensityMapper ?? const MapIntensityMapper(),
        _cache = cache ?? MapCache();

  final OpenMeteoClient _openMeteo;
  final InpeFocosClient _inpe;
  final MapGridSampler _gridSampler;
  final MapIntensityMapper _mapper;
  final MapCache _cache;

  @override
  Future<MapFetchResult> fetchLayer({
    required MapLayer layer,
    required LatLngBounds bounds,
    required double zoom,
  }) async {
    final cacheKey = _cacheKey(layer, bounds, zoom);
    final cached = _cache.get(cacheKey);
    if (cached != null) return cached;

    try {
      final result = switch (layer) {
        MapLayer.hotspots => await _fetchHotspots(bounds),
        MapLayer.airQuality => await _fetchAirQuality(bounds, zoom),
        MapLayer.temperature => await _fetchTemperature(bounds, zoom),
        MapLayer.rain => await _fetchRain(bounds, zoom),
      };

      _maybeCache(cacheKey, result, layer);
      return result;
    } catch (_) {
      final stale = _cache.getStale(cacheKey);
      if (stale != null) {
        return MapFetchResult(
          points: stale.points,
          hotspotMarkers: stale.hotspotMarkers,
          gridLatStep: stale.gridLatStep,
          gridLngStep: stale.gridLngStep,
          displayMode: stale.displayMode,
          fetchedAt: stale.fetchedAt,
          source: stale.source,
          isStale: true,
          hasError: true,
        );
      }
      return MapFetchResult(
        points: const [],
        fetchedAt: DateTime.now(),
        source: _sourceFor(layer),
        hasError: true,
      );
    }
  }

  void _maybeCache(String cacheKey, MapFetchResult result, MapLayer layer) {
    if (result.points.isNotEmpty ||
        result.hotspotMarkers.isNotEmpty ||
        result.isEmpty) {
      _cache.put(
        cacheKey,
        result,
        ttlMinutes: layer == MapLayer.hotspots
            ? MapConfig.inpeCacheTtlMinutes
            : MapConfig.openMeteoCacheTtlMinutes,
      );
    }
  }

  void _ensureMinSuccess(int received, int expected) {
    if (expected == 0) return;
    if (received / expected < MapConfig.minGridSuccessRatio) {
      throw InsufficientMapDataException(received, expected);
    }
  }

  Future<MapFetchResult> _fetchAirQuality(
    LatLngBounds bounds,
    double zoom,
  ) async {
    final grid = _gridSampler.sample(bounds, zoom);
    final readings = await _openMeteo.fetchAirQualityGrid(grid.points);
    _ensureMinSuccess(readings.length, grid.points.length);

    final samples = _mapper.mapAirQualitySamples(
      readings.map((r) => (r.position, r.europeanAqi, r.pm25)).toList(),
    );
    return MapFetchResult(
      points: _mapper.toCalibratedHeatmapPoints(samples),
      gridLatStep: grid.latStep,
      gridLngStep: grid.lngStep,
      displayMode: MapLayerDisplayMode.heatmap,
      fetchedAt: DateTime.now(),
      source: 'Open-Meteo / CAMS',
    );
  }

  Future<MapFetchResult> _fetchTemperature(
    LatLngBounds bounds,
    double zoom,
  ) async {
    final grid = _gridSampler.sample(bounds, zoom);
    final readings = await _openMeteo.fetchWeatherGrid(grid.points);
    _ensureMinSuccess(readings.length, grid.points.length);

    final samples = _mapper.mapTemperatureSamples(
      readings.map((r) => (r.position, r.temperature)).toList(),
    );

    if (samples.isEmpty) {
      return MapFetchResult(
        points: const [],
        gridLatStep: grid.latStep,
        gridLngStep: grid.lngStep,
        displayMode: MapLayerDisplayMode.heatmap,
        fetchedAt: DateTime.now(),
        source: 'Open-Meteo',
        isEmpty: true,
      );
    }

    return MapFetchResult(
      points: _mapper.toCalibratedHeatmapPoints(samples),
      gridLatStep: grid.latStep,
      gridLngStep: grid.lngStep,
      displayMode: MapLayerDisplayMode.heatmap,
      fetchedAt: DateTime.now(),
      source: 'Open-Meteo',
    );
  }

  Future<MapFetchResult> _fetchRain(LatLngBounds bounds, double zoom) async {
    final grid = _gridSampler.sample(bounds, zoom);
    final readings = await _openMeteo.fetchRainGrid(grid.points);
    _ensureMinSuccess(readings.length, grid.points.length);

    final samples = _mapper.mapRainSamples(
      readings.map((r) => (r.position, r.precipitation)).toList(),
    );

    if (samples.isEmpty) {
      return MapFetchResult(
        points: const [],
        fetchedAt: DateTime.now(),
        source: 'Open-Meteo',
        isEmpty: true,
      );
    }

    return MapFetchResult(
      points: _mapper.toHeatmapPoints(
        samples,
        latStep: grid.latStep,
        lngStep: grid.lngStep,
      ),
      fetchedAt: DateTime.now(),
      source: 'Open-Meteo',
    );
  }

  Future<MapFetchResult> _fetchHotspots(LatLngBounds bounds) async {
    final all = await _inpe.fetchAll();
    final filtered = _inpe.filterByBounds(all, bounds);

    if (filtered.isEmpty) {
      return MapFetchResult(
        points: const [],
        fetchedAt: DateTime.now(),
        source: 'INPE Queimadas',
        displayMode: MapLayerDisplayMode.markers,
        isEmpty: true,
      );
    }

    return MapFetchResult(
      points: const [],
      hotspotMarkers: filtered,
      displayMode: MapLayerDisplayMode.markers,
      fetchedAt: DateTime.now(),
      source: 'INPE Queimadas',
    );
  }

  String _cacheKey(MapLayer layer, LatLngBounds bounds, double zoom) {
    final zoomBucket = zoom.floor();
    return '${layer.name}_${bounds.cacheKey()}_$zoomBucket';
  }

  String _sourceFor(MapLayer layer) => switch (layer) {
        MapLayer.airQuality => 'Open-Meteo / CAMS',
        MapLayer.temperature => 'Open-Meteo',
        MapLayer.rain => 'Open-Meteo',
        MapLayer.hotspots => 'INPE Queimadas',
      };

  void dispose() {
    _openMeteo.dispose();
    _inpe.dispose();
  }
}

class InsufficientMapDataException implements Exception {
  InsufficientMapDataException(this.received, this.expected);

  final int received;
  final int expected;

  @override
  String toString() =>
      'InsufficientMapDataException($received/$expected points)';
}

class FakeMapRepository implements MapRepository {
  FakeMapRepository({
    this.delay = Duration.zero,
    this.points = const [],
    this.hotspotMarkers = const [],
    this.shouldFail = false,
    this.isEmpty = false,
  });

  final Duration delay;
  final List<WeightedLatLng> points;
  final List<InpeHotspotPoint> hotspotMarkers;
  final bool shouldFail;
  final bool isEmpty;

  static final _defaultHotspotMarkers = [
    InpeHotspotPoint(position: LatLng(-23.55, -46.63), frp: 80),
    InpeHotspotPoint(position: LatLng(-23.56, -46.64), frp: 120),
  ];

  static final _defaultHeatmapPoints = [
    WeightedLatLng(LatLng(-23.55, -46.63), 0.75),
  ];

  static const _defaultGridLatStep = 0.04;
  static const _defaultGridLngStep = 0.04;

  @override
  Future<MapFetchResult> fetchLayer({
    required MapLayer layer,
    required LatLngBounds bounds,
    required double zoom,
  }) async {
    await Future<void>.delayed(delay);
    if (shouldFail) {
      return MapFetchResult(
        points: const [],
        fetchedAt: DateTime.now(),
        source: 'Fake',
        hasError: true,
      );
    }

    if (layer == MapLayer.hotspots) {
      final markers = hotspotMarkers.isNotEmpty
          ? hotspotMarkers
          : (isEmpty ? const <InpeHotspotPoint>[] : _defaultHotspotMarkers);
      return MapFetchResult(
        points: const [],
        hotspotMarkers: markers,
        displayMode: MapLayerDisplayMode.markers,
        fetchedAt: DateTime.now(),
        source: 'Fake',
        isEmpty: isEmpty || markers.isEmpty,
      );
    }

    if (layer == MapLayer.airQuality || layer == MapLayer.temperature) {
      final heatmapPoints = isEmpty
          ? const <WeightedLatLng>[]
          : (points.isNotEmpty ? points : _defaultHeatmapPoints);
      return MapFetchResult(
        points: heatmapPoints,
        gridLatStep: _defaultGridLatStep,
        gridLngStep: _defaultGridLngStep,
        displayMode: MapLayerDisplayMode.heatmap,
        fetchedAt: DateTime.now(),
        source: 'Fake',
        isEmpty: isEmpty,
      );
    }

    final List<WeightedLatLng> heatmapPoints =
        points.isNotEmpty ? points : (isEmpty ? const [] : _defaultHeatmapPoints);
    return MapFetchResult(
      points: heatmapPoints,
      fetchedAt: DateTime.now(),
      source: 'Fake',
      isEmpty: isEmpty,
    );
  }
}

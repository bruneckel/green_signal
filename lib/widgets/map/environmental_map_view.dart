import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' hide LatLngBounds;
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/map_config.dart';
import '../../core/theme/app_colors.dart';
import '../../models/inpe_hotspot_point.dart';
import '../../models/map_layer_data.dart';
import '../../services/map/map_grid_sampler.dart';

typedef ViewportChangedCallback = void Function(
  LatLngBounds bounds,
  double zoom,
);

class EnvironmentalMapView extends StatefulWidget {
  const EnvironmentalMapView({
    super.key,
    required this.layer,
    required this.points,
    required this.displayMode,
    required this.hotspotMarkers,
    required this.gridLatStep,
    required this.gridLngStep,
    required this.isLoading,
    required this.onViewportChanged,
    required this.initialCenter,
  });

  final MapLayer layer;
  final List<WeightedLatLng> points;
  final MapLayerDisplayMode displayMode;
  final List<InpeHotspotPoint> hotspotMarkers;
  final double gridLatStep;
  final double gridLngStep;
  final bool isLoading;
  final ViewportChangedCallback onViewportChanged;
  final LatLng initialCenter;

  @override
  State<EnvironmentalMapView> createState() => _EnvironmentalMapViewState();
}

class _EnvironmentalMapViewState extends State<EnvironmentalMapView> {
  final _mapController = MapController();
  final _rebuildController = StreamController<void>.broadcast();
  StreamSubscription<MapEvent>? _mapEventSub;
  LatLngBounds? _lastReportedBounds;
  double? _lastReportedZoom;
  double _currentZoom = MapLayerData.initialZoom;

  @override
  void initState() {
    super.initState();
    _mapEventSub = _mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveEnd) {
        _reportViewportIfChanged();
        _rebuildController.add(null);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rebuildController.add(null);
      _mapController.move(
        widget.initialCenter,
        MapLayerData.initialZoom,
      );
    });
  }

  @override
  void didUpdateWidget(EnvironmentalMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCenter != widget.initialCenter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(
          widget.initialCenter,
          MapLayerData.initialZoom,
        );
        _reportViewportIfChanged();
      });
    }
    if (oldWidget.layer != widget.layer ||
        oldWidget.points != widget.points ||
        oldWidget.displayMode != widget.displayMode ||
        oldWidget.hotspotMarkers != widget.hotspotMarkers ||
        oldWidget.gridLatStep != widget.gridLatStep ||
        oldWidget.gridLngStep != widget.gridLngStep) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _rebuildController.add(null);
      });
    }
  }

  void _reportViewportIfChanged() {
    final camera = _mapController.camera;
    final visible = camera.visibleBounds;
    final bounds = LatLngBounds.fromMapBounds(
      south: visible.south,
      north: visible.north,
      west: visible.west,
      east: visible.east,
    );

    if (!_shouldReport(bounds, camera.zoom)) return;

    _lastReportedBounds = bounds;
    _lastReportedZoom = camera.zoom;
    _currentZoom = camera.zoom;
    widget.onViewportChanged(bounds, camera.zoom);
  }

  bool _shouldReport(LatLngBounds bounds, double zoom) {
    if (_lastReportedBounds == null || _lastReportedZoom == null) {
      return true;
    }
    if ((zoom - _lastReportedZoom!).abs() >= 0.5) return true;

    final prev = _lastReportedBounds!;
    final latSpan = (bounds.north - bounds.south).abs();
    final lngSpan = (bounds.east - bounds.west).abs();
    final prevLatSpan = (prev.north - prev.south).abs();
    final prevLngSpan = (prev.east - prev.west).abs();

    if (prevLatSpan == 0 || prevLngSpan == 0) return true;

    final latShift = (latSpan - prevLatSpan).abs() / prevLatSpan;
    final lngShift = (lngSpan - prevLngSpan).abs() / prevLngSpan;

    return latShift >= MapConfig.boundsChangeThreshold ||
        lngShift >= MapConfig.boundsChangeThreshold ||
        (bounds.south - prev.south).abs() / prevLatSpan >=
            MapConfig.boundsChangeThreshold ||
        (bounds.west - prev.west).abs() / prevLngSpan >=
            MapConfig.boundsChangeThreshold;
  }

  double _heatmapLatitude() {
    if (widget.points.isEmpty) {
      return widget.initialCenter.latitude;
    }
    final sum = widget.points.fold<double>(
      0,
      (total, point) => total + point.latLng.latitude,
    );
    return sum / widget.points.length;
  }

  @override
  void dispose() {
    _mapEventSub?.cancel();
    _rebuildController.close();
    _mapController.dispose();
    super.dispose();
  }

  Widget _buildDataLayer(double zoom) {
    final style = widget.layer.style;

    switch (widget.displayMode) {
      case MapLayerDisplayMode.heatmap:
        if (widget.points.isEmpty) return const SizedBox.shrink();
        final optionsBuilder = style.heatmapOptionsBuilder ??
            MapLayerData.defaultHeatmapOptions;
        return HeatMapLayer(
          key: ValueKey(
            '${widget.layer}_${widget.points.length}_${widget.gridLatStep}_$zoom',
          ),
          heatMapDataSource: InMemoryHeatMapDataSource(data: widget.points),
          heatMapOptions: optionsBuilder(
            zoom,
            style.gradient,
            latStep: widget.gridLatStep,
            lngStep: widget.gridLngStep,
            latitude: _heatmapLatitude(),
          ),
          reset: _rebuildController.stream,
        );
      case MapLayerDisplayMode.markers:
        if (widget.hotspotMarkers.isEmpty) return const SizedBox.shrink();
        return CircleLayer(
          key: ValueKey('${widget.layer}_${widget.hotspotMarkers.length}'),
          circles: widget.hotspotMarkers.map((hotspot) {
            final color = MapLayerData.colorForFrp(hotspot.frp);
            return CircleMarker(
              point: hotspot.position,
              radius: 6,
              useRadiusInMeter: false,
              color: color.withValues(alpha: 0.85),
              borderColor: color.withValues(alpha: 0.4),
              borderStrokeWidth: 1,
            );
          }).toList(),
        );
    }
  }

  double _effectiveZoom() {
    try {
      return _mapController.camera.zoom;
    } catch (_) {
      return _currentZoom;
    }
  }

  @override
  Widget build(BuildContext context) {
    final zoom = _effectiveZoom();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.initialCenter,
            initialZoom: MapLayerData.initialZoom,
            minZoom: MapLayerData.minZoom,
            maxZoom: MapLayerData.maxZoom,
            backgroundColor: AppColors.background,
            onMapReady: _reportViewportIfChanged,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
              pinchZoomThreshold: 0.5,
              scrollWheelVelocity: 0.005,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.green_signal',
              maxZoom: MapLayerData.maxZoom,
            ),
            _buildDataLayer(zoom),
          ],
        ),
        if (widget.isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.25),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

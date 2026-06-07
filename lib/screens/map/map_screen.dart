import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/map_config.dart';
import '../../core/constants/map_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/form_utils.dart';
import '../../models/inpe_hotspot_point.dart';
import '../../models/map_layer_data.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/environment/unified_location_resolver.dart';
import '../../services/map/map_grid_sampler.dart';
import '../../services/map/map_repository.dart';
import '../../widgets/map/environmental_map_view.dart';
import '../../widgets/map/map_filter_chips.dart';
import '../../widgets/map/map_screen_footer.dart';
import '../../widgets/shell/tab_screen_header.dart';
import '../../widgets/shell/tab_screen_scaffold.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.repository,
    required this.authRepository,
    required this.locationResolver,
  });

  final MapRepository? repository;
  final AuthRepository authRepository;
  final UnifiedLocationResolver locationResolver;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapRepository _repository;
  LiveMapRepository? _liveRepository;
  MapLayer _selectedLayer = MapLayer.airQuality;
  List<WeightedLatLng> _points = const [];
  List<InpeHotspotPoint> _hotspotMarkers = const [];
  double _gridLatStep = 0;
  double _gridLngStep = 0;
  MapLayerDisplayMode _displayMode = MapLayerDisplayMode.heatmap;
  bool _isLoading = false;
  bool _hasError = false;
  bool _isEmpty = false;
  bool _isLocating = true;
  LatLng? _mapCenter;
  int _fetchGeneration = 0;
  LatLngBounds? _lastBounds;
  double? _lastZoom;
  Timer? _fetchDebounceTimer;

  String? _lastResolvedCoordsKey;

  @override
  void initState() {
    super.initState();
    if (widget.repository != null) {
      _repository = widget.repository!;
    } else {
      _liveRepository = LiveMapRepository();
      _repository = _liveRepository!;
    }
    widget.authRepository.addListener(_onAuthChanged);
    widget.locationResolver.addListener(_onLocationChanged);
    _resolveMapCenter();
  }

  void _onAuthChanged() {
    widget.locationResolver.loadOverridesForUser(widget.authRepository);
    _lastResolvedCoordsKey = null;
    _resolveMapCenter();
  }

  void _onLocationChanged() {
    _lastResolvedCoordsKey = null;
    _resolveMapCenter();
  }

  Future<void> _resolveMapCenter() async {
    final location = await widget.locationResolver.resolve(
      widget.authRepository,
    );

    if (!mounted) return;

    final coordsKey =
        '${location.position.latitude},${location.position.longitude}';
    if (coordsKey == _lastResolvedCoordsKey && _mapCenter != null) return;

    setState(() {
      _mapCenter = location.position;
      _isLocating = false;
      _lastResolvedCoordsKey = coordsKey;
      _points = const [];
      _hotspotMarkers = const [];
    });
  }

  @override
  void dispose() {
    widget.authRepository.removeListener(_onAuthChanged);
    widget.locationResolver.removeListener(_onLocationChanged);
    _fetchDebounceTimer?.cancel();
    _liveRepository?.dispose();
    super.dispose();
  }

  void _onLayerChanged(MapLayer layer) {
    if (layer == _selectedLayer) return;
    setState(() {
      _selectedLayer = layer;
      _points = const [];
      _hotspotMarkers = const [];
      _gridLatStep = 0;
      _gridLngStep = 0;
    });
    if (_lastBounds != null && _lastZoom != null) {
      _scheduleFetch(_lastBounds!, _lastZoom!);
    }
  }

  void _onViewportChanged(LatLngBounds bounds, double zoom) {
    _scheduleFetch(bounds, zoom);
  }

  void _scheduleFetch(LatLngBounds bounds, double zoom) {
    _lastBounds = bounds;
    _lastZoom = zoom;
    _fetchDebounceTimer?.cancel();
    setState(() {
      _isLoading = true;
      _hasError = false;
      _isEmpty = false;
    });
    _fetchDebounceTimer = Timer(
      const Duration(milliseconds: MapConfig.debounceMs),
      () => _loadForViewport(bounds, zoom),
    );
  }

  Future<void> _loadForViewport(LatLngBounds bounds, double zoom) async {
    final generation = ++_fetchGeneration;

    final result = await _repository.fetchLayer(
      layer: _selectedLayer,
      bounds: bounds,
      zoom: zoom,
    );

    if (!mounted || generation != _fetchGeneration) return;

    setState(() {
      _points = result.points;
      _hotspotMarkers = result.hotspotMarkers;
      _gridLatStep = result.gridLatStep;
      _gridLngStep = result.gridLngStep;
      _displayMode = result.displayMode;
      _isLoading = false;
      _hasError = result.hasError;
      _isEmpty = result.isEmpty;
    });

    if (result.hasError && !result.isStale && mounted) {
      showAppSnackBar(
        context,
        MapStrings.loadError,
        type: AppSnackBarType.error,
      );
    } else if (result.isStale && mounted) {
      showAppSnackBar(context, MapStrings.staleDataNotice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapCenter = _mapCenter;

    return TabScreenScaffold(
      backgroundColor: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          const TabScreenHeader(title: MapStrings.mapTitle),
          const SizedBox(height: AppSpacing.md),
          MapFilterChips(
            selectedLayer: _selectedLayer,
            onLayerChanged: _onLayerChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _isLocating || mapCenter == null
                ? const Center(child: CircularProgressIndicator())
                : EnvironmentalMapView(
                    key: ValueKey(
                      '${_selectedLayer.name}_'
                      '${mapCenter.latitude}_${mapCenter.longitude}',
                    ),
                    layer: _selectedLayer,
                    points: _points,
                    displayMode: _displayMode,
                    hotspotMarkers: _hotspotMarkers,
                    gridLatStep: _gridLatStep,
                    gridLngStep: _gridLngStep,
                    isLoading: _isLoading,
                    initialCenter: mapCenter,
                    onViewportChanged: _onViewportChanged,
                  ),
          ),
          MapScreenFooter(
            layer: _selectedLayer,
            hasError: _hasError,
            isEmpty: _isEmpty,
            isLoading: _isLoading,
            pointsEmpty: _points.isEmpty,
            hotspotMarkersEmpty: _hotspotMarkers.isEmpty,
          ),
        ],
      ),
    );
  }
}

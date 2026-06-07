import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';

import '../../core/theme/app_colors.dart';
import '../../models/map_layer_data.dart';

class EnvironmentalMapView extends StatefulWidget {
  const EnvironmentalMapView({
    super.key,
    required this.layer,
  });

  final MapLayer layer;

  @override
  State<EnvironmentalMapView> createState() => _EnvironmentalMapViewState();
}

class _EnvironmentalMapViewState extends State<EnvironmentalMapView> {
  final _mapController = MapController();
  final _rebuildController = StreamController<void>.broadcast();
  StreamSubscription<MapEvent>? _mapEventSub;

  @override
  void initState() {
    super.initState();
    _mapEventSub = _mapController.mapEventStream.listen((event) {
      if (event is MapEventMove || event is MapEventMoveEnd) {
        _rebuildController.add(null);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rebuildController.add(null);
    });
  }

  @override
  void didUpdateWidget(EnvironmentalMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.layer != widget.layer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _rebuildController.add(null);
      });
    }
  }

  @override
  void dispose() {
    _mapEventSub?.cancel();
    _rebuildController.close();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layerData = MapLayerData.forLayer(widget.layer);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: MapLayerData.saoPauloCenter,
        initialZoom: MapLayerData.initialZoom,
        minZoom: MapLayerData.minZoom,
        maxZoom: MapLayerData.maxZoom,
        backgroundColor: AppColors.background,
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
        HeatMapLayer(
          key: ValueKey(widget.layer),
          heatMapDataSource: InMemoryHeatMapDataSource(data: layerData.points),
          heatMapOptions: HeatMapOptions(
            gradient: MapLayerData.riskGradient,
            minOpacity: 0.12,
            radius: 72,
            layerOpacity: 0.52,
            blurFactor: 0.88,
          ),
          reset: _rebuildController.stream,
        ),
      ],
    );
  }
}

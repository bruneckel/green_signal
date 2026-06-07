import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';

import 'inpe_hotspot_point.dart';
import 'map_layer_data.dart';

class MapFetchResult {
  const MapFetchResult({
    required this.points,
    required this.fetchedAt,
    required this.source,
    this.displayMode = MapLayerDisplayMode.heatmap,
    this.hotspotMarkers = const [],
    this.gridLatStep = 0,
    this.gridLngStep = 0,
    this.isStale = false,
    this.hasError = false,
    this.isEmpty = false,
  });

  final List<WeightedLatLng> points;
  final List<InpeHotspotPoint> hotspotMarkers;
  final double gridLatStep;
  final double gridLngStep;
  final MapLayerDisplayMode displayMode;
  final DateTime fetchedAt;
  final String source;
  final bool isStale;
  final bool hasError;
  final bool isEmpty;
}

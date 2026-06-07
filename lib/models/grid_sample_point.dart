import 'package:latlong2/latlong.dart';

class GridSamplePoint {
  const GridSamplePoint({
    required this.position,
    required this.intensity,
  });

  final LatLng position;
  final double intensity;
}

import 'package:latlong2/latlong.dart';

class InpeHotspotPoint {
  const InpeHotspotPoint({
    required this.position,
    required this.frp,
  });

  final LatLng position;
  final double frp;
}

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

abstract class DeviceLocationService {
  Future<LatLng?> getCurrentPosition();
}

class GeolocatorDeviceLocationService implements DeviceLocationService {
  const GeolocatorDeviceLocationService();

  static const _timeLimit = Duration(seconds: 10);

  @override
  Future<LatLng?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: _timeLimit,
        ),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }
}

class FakeDeviceLocationService implements DeviceLocationService {
  const FakeDeviceLocationService({this.position, this.delay = Duration.zero});

  final LatLng? position;
  final Duration delay;

  @override
  Future<LatLng?> getCurrentPosition() async {
    await Future<void>.delayed(delay);
    return position;
  }
}

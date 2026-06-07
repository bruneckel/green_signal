import '../../models/environmental_snapshot.dart';
import '../../models/map_layer_data.dart';
import '../auth/auth_repository.dart';
import 'geocoding_client.dart';

abstract class LocationResolver {
  Future<ResolvedLocation> resolve(AuthRepository auth);
}

class GeocodingLocationResolver implements LocationResolver {
  GeocodingLocationResolver({GeocodingClient? geocodingClient})
      : _geocodingClient = geocodingClient ?? GeocodingClient();

  final GeocodingClient _geocodingClient;

  @override
  Future<ResolvedLocation> resolve(AuthRepository auth) async {
    final address = auth.currentUser?.address ?? '';
    return _geocodingClient.resolve(address);
  }

  void dispose() => _geocodingClient.dispose();
}

class FakeLocationResolver implements LocationResolver {
  const FakeLocationResolver({this.location = testLocation});

  final ResolvedLocation location;

  static const testLocation = ResolvedLocation(
    position: MapLayerData.saoPauloCenter,
    label: 'São Paulo, SP',
    neighborhood: 'Vila Madalena',
  );

  @override
  Future<ResolvedLocation> resolve(AuthRepository auth) async => location;
}

import 'package:latlong2/latlong.dart';

import '../../models/map_layer_data.dart';
import '../../models/user_account.dart';
import '../environment/geocoding_client.dart';
import 'brasil_api_cep_client.dart';

class UserCoordinatesResolver {
  UserCoordinatesResolver({
    BrasilApiCepClient? brasilApiCepClient,
    GeocodingClient? geocodingClient,
  })  : _brasilApiCepClient = brasilApiCepClient ?? LiveBrasilApiCepClient(),
        _geocodingClient = geocodingClient ?? GeocodingClient();

  final BrasilApiCepClient _brasilApiCepClient;
  final GeocodingClient _geocodingClient;

  Future<LatLng?> resolve(UserAccount user) async {
    if (user.hasStructuredAddress && user.cep.isNotEmpty) {
      final fromCep = await _brasilApiCepClient.fetchCoordinates(user.cep);
      if (fromCep != null && _isValidForUser(fromCep, user)) {
        return fromCep;
      }
    }

    final geocoded = await _geocodingClient.resolveForUser(user);
    if (_isValidForUser(geocoded.position, user)) {
      return geocoded.position;
    }

    return null;
  }

  bool _isValidForUser(LatLng position, UserAccount user) {
    if (MapLayerData.isSaoPauloFallback(position)) return false;
    if (!MapLayerData.isSaoPauloProfile(user) &&
        MapLayerData.isNearSaoPaulo(position)) {
      return false;
    }
    return true;
  }

  void dispose() {
    _geocodingClient.dispose();
    if (_brasilApiCepClient is LiveBrasilApiCepClient) {
      _brasilApiCepClient.dispose();
    }
  }
}

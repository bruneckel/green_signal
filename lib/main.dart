import 'package:flutter/material.dart';

import 'app.dart';
import 'services/address/brasil_api_cep_client.dart';
import 'services/address/user_coordinates_resolver.dart';
import 'services/address/viacep_client.dart';
import 'services/alerts/alerts_repository.dart';
import 'services/auth/local_auth_repository.dart';
import 'services/environment/environmental_repository.dart';
import 'services/environment/geocoding_client.dart';
import 'services/environment/unified_location_resolver.dart';
import 'services/location/ibge_localities_client.dart';
import 'services/location/location_override_store.dart';
import 'services/map/inpe_focos_client.dart';
import 'services/map/map_repository.dart';
import 'services/map/open_meteo_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final geocodingClient = GeocodingClient();
  final brasilApiCepClient = LiveBrasilApiCepClient();
  final coordinatesResolver = UserCoordinatesResolver(
    brasilApiCepClient: brasilApiCepClient,
    geocodingClient: geocodingClient,
  );
  final authRepository = LocalAuthRepository(
    coordinatesResolver: coordinatesResolver,
  );
  await authRepository.initialize();

  final openMeteoClient = OpenMeteoClient();
  final inpeFocosClient = InpeFocosClient();
  final mapRepository = LiveMapRepository(
    openMeteoClient: openMeteoClient,
    inpeFocosClient: inpeFocosClient,
  );
  final environmentalRepository = LiveEnvironmentalRepository(
    openMeteoClient: openMeteoClient,
    inpeFocosClient: inpeFocosClient,
  );
  final overrideStore = LocationOverrideStore();
  final locationResolver = UnifiedLocationResolver(
    coordinatesResolver: coordinatesResolver,
    overrideStore: overrideStore,
    geocodingClient: geocodingClient,
  );
  await locationResolver.loadOverridesForUser(authRepository);
  final alertsRepository = LiveAlertsRepository();
  final viaCepClient = LiveViaCepClient();
  final ibgeClient = LiveIbgeLocalitiesClient();

  runApp(
    GreenSignalApp(
      authRepository: authRepository,
      mapRepository: mapRepository,
      environmentalRepository: environmentalRepository,
      locationResolver: locationResolver,
      alertsRepository: alertsRepository,
      viaCepClient: viaCepClient,
      ibgeClient: ibgeClient,
    ),
  );
}

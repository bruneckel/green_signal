import 'package:flutter/material.dart';

import 'app.dart';
import 'services/address/brasil_api_cep_client.dart';
import 'services/address/user_coordinates_resolver.dart';
import 'services/address/viacep_client.dart';
import 'services/auth/local_auth_repository.dart';
import 'services/environment/environmental_repository.dart';
import 'services/environment/geocoding_client.dart';
import 'services/environment/unified_location_resolver.dart';
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
  final locationResolver = UnifiedLocationResolver(
    coordinatesResolver: coordinatesResolver,
  );
  final viaCepClient = LiveViaCepClient();

  runApp(
    GreenSignalApp(
      authRepository: authRepository,
      mapRepository: mapRepository,
      environmentalRepository: environmentalRepository,
      locationResolver: locationResolver,
      viaCepClient: viaCepClient,
    ),
  );
}

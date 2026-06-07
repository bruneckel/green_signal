import 'package:flutter/material.dart';

import 'app.dart';
import 'services/auth/local_auth_repository.dart';
import 'services/environment/geocoding_client.dart';
import 'services/environment/environmental_repository.dart';
import 'services/environment/location_resolver.dart';
import 'services/map/inpe_focos_client.dart';
import 'services/map/map_repository.dart';
import 'services/map/open_meteo_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authRepository = LocalAuthRepository();
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
  final locationResolver = GeocodingLocationResolver(
    geocodingClient: GeocodingClient(),
  );

  runApp(
    GreenSignalApp(
      authRepository: authRepository,
      mapRepository: mapRepository,
      environmentalRepository: environmentalRepository,
      locationResolver: locationResolver,
    ),
  );
}

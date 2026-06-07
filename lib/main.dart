import 'package:flutter/material.dart';

import 'app.dart';
import 'services/address/viacep_client.dart';
import 'services/auth/local_auth_repository.dart';
import 'services/environment/device_location_service.dart';
import 'services/environment/environmental_repository.dart';
import 'services/environment/geocoding_client.dart';
import 'services/environment/unified_location_resolver.dart';
import 'services/map/inpe_focos_client.dart';
import 'services/map/map_repository.dart';
import 'services/map/open_meteo_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final geocodingClient = GeocodingClient();
  final authRepository = LocalAuthRepository(geocodingClient: geocodingClient);
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
  const deviceLocationService = GeolocatorDeviceLocationService();
  final locationResolver = UnifiedLocationResolver(
    deviceLocation: deviceLocationService,
    geocodingClient: geocodingClient,
  );
  final viaCepClient = LiveViaCepClient();

  runApp(
    GreenSignalApp(
      authRepository: authRepository,
      mapRepository: mapRepository,
      environmentalRepository: environmentalRepository,
      locationResolver: locationResolver,
      deviceLocationService: deviceLocationService,
      viaCepClient: viaCepClient,
    ),
  );
}

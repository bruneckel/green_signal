import 'package:flutter/material.dart';

import 'app.dart';
import 'services/auth/local_auth_repository.dart';
import 'services/environment/device_location_service.dart';
import 'services/environment/environmental_repository.dart';
import 'services/environment/geocoding_client.dart';
import 'services/environment/location_resolver.dart';
import 'services/environment/map_location_resolver.dart';
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
  const deviceLocationService = GeolocatorDeviceLocationService();
  final mapLocationResolver = MapLocationResolver(
    deviceLocation: deviceLocationService,
    addressResolver: locationResolver,
  );

  runApp(
    GreenSignalApp(
      authRepository: authRepository,
      mapRepository: mapRepository,
      environmentalRepository: environmentalRepository,
      locationResolver: locationResolver,
      deviceLocationService: deviceLocationService,
      mapLocationResolver: mapLocationResolver,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'services/auth/auth_repository.dart';
import 'services/environment/environmental_repository.dart';
import 'services/environment/location_resolver.dart';
import 'services/map/map_repository.dart';

class GreenSignalApp extends StatelessWidget {
  GreenSignalApp({
    super.key,
    required this.authRepository,
    MapRepository? mapRepository,
    EnvironmentalRepository? environmentalRepository,
    LocationResolver? locationResolver,
  })  : mapRepository = mapRepository ?? LiveMapRepository(),
        environmentalRepository =
            environmentalRepository ?? LiveEnvironmentalRepository(),
        locationResolver = locationResolver ?? GeocodingLocationResolver(),
        _router = createRouter(
          authRepository: authRepository,
          mapRepository: mapRepository ?? LiveMapRepository(),
          environmentalRepository:
              environmentalRepository ?? LiveEnvironmentalRepository(),
          locationResolver: locationResolver ?? GeocodingLocationResolver(),
        );

  final AuthRepository authRepository;
  final MapRepository mapRepository;
  final EnvironmentalRepository environmentalRepository;
  final LocationResolver locationResolver;
  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GreenSignal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'services/address/viacep_client.dart';
import 'services/auth/auth_repository.dart';
import 'services/environment/environmental_repository.dart';
import 'services/environment/geocoding_client.dart';
import 'services/environment/unified_location_resolver.dart';
import 'services/map/map_repository.dart';

class GreenSignalApp extends StatelessWidget {
  factory GreenSignalApp({
    required AuthRepository authRepository,
    MapRepository? mapRepository,
    EnvironmentalRepository? environmentalRepository,
    UnifiedLocationResolver? locationResolver,
    ViaCepClient? viaCepClient,
  }) {
    final mapRepo = mapRepository ?? LiveMapRepository();
    final envRepo = environmentalRepository ?? LiveEnvironmentalRepository();
    final unifiedResolver = locationResolver ??
        UnifiedLocationResolver(geocodingClient: GeocodingClient());
    final cepClient = viaCepClient ?? LiveViaCepClient();

    return GreenSignalApp._(
      authRepository: authRepository,
      mapRepository: mapRepo,
      environmentalRepository: envRepo,
      locationResolver: unifiedResolver,
      viaCepClient: cepClient,
      router: createRouter(
        authRepository: authRepository,
        mapRepository: mapRepo,
        environmentalRepository: envRepo,
        locationResolver: unifiedResolver,
        viaCepClient: cepClient,
      ),
    );
  }

  const GreenSignalApp._({
    required this.authRepository,
    required this.mapRepository,
    required this.environmentalRepository,
    required this.locationResolver,
    required this.viaCepClient,
    required GoRouter router,
  }) : _router = router;

  final AuthRepository authRepository;
  final MapRepository mapRepository;
  final EnvironmentalRepository environmentalRepository;
  final UnifiedLocationResolver locationResolver;
  final ViaCepClient viaCepClient;
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

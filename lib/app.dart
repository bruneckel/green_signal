import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'services/auth/auth_repository.dart';
import 'services/environment/device_location_service.dart';
import 'services/environment/environmental_repository.dart';
import 'services/environment/location_resolver.dart';
import 'services/environment/map_location_resolver.dart';
import 'services/map/map_repository.dart';

class GreenSignalApp extends StatelessWidget {
  factory GreenSignalApp({
    required AuthRepository authRepository,
    MapRepository? mapRepository,
    EnvironmentalRepository? environmentalRepository,
    LocationResolver? locationResolver,
    MapLocationResolver? mapLocationResolver,
    DeviceLocationService? deviceLocationService,
  }) {
    final mapRepo = mapRepository ?? LiveMapRepository();
    final envRepo = environmentalRepository ?? LiveEnvironmentalRepository();
    final addressResolver = locationResolver ?? GeocodingLocationResolver();
    final deviceLocation =
        deviceLocationService ?? const GeolocatorDeviceLocationService();
    final mapLocResolver = mapLocationResolver ??
        MapLocationResolver(
          deviceLocation: deviceLocation,
          addressResolver: addressResolver,
        );

    return GreenSignalApp._(
      authRepository: authRepository,
      mapRepository: mapRepo,
      environmentalRepository: envRepo,
      locationResolver: addressResolver,
      deviceLocationService: deviceLocation,
      mapLocationResolver: mapLocResolver,
      router: createRouter(
        authRepository: authRepository,
        mapRepository: mapRepo,
        environmentalRepository: envRepo,
        locationResolver: addressResolver,
        mapLocationResolver: mapLocResolver,
      ),
    );
  }

  const GreenSignalApp._({
    required this.authRepository,
    required this.mapRepository,
    required this.environmentalRepository,
    required this.locationResolver,
    required this.deviceLocationService,
    required this.mapLocationResolver,
    required GoRouter router,
  }) : _router = router;

  final AuthRepository authRepository;
  final MapRepository mapRepository;
  final EnvironmentalRepository environmentalRepository;
  final LocationResolver locationResolver;
  final DeviceLocationService deviceLocationService;
  final MapLocationResolver mapLocationResolver;
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

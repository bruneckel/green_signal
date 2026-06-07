import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'services/auth/auth_repository.dart';
import 'services/map/map_repository.dart';

class GreenSignalApp extends StatelessWidget {
  GreenSignalApp({
    super.key,
    MapRepository? mapRepository,
    required this.authRepository,
  }) : _router = createRouter(
          mapRepository: mapRepository,
          authRepository: authRepository,
        );

  final AuthRepository authRepository;
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

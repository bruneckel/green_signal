import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/alerts/alerts_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/community/community_screen.dart';
import '../screens/community/new_report_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/score/score_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../services/address/user_coordinates_resolver.dart';
import '../services/address/viacep_client.dart';
import '../services/alerts/alerts_repository.dart';
import '../services/auth/auth_repository.dart';
import '../services/environment/environmental_repository.dart';
import '../services/environment/geocoding_client.dart';
import '../services/environment/unified_location_resolver.dart';
import '../services/map/map_repository.dart';
import '../shell/main_shell.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const map = '/map';
  static const alerts = '/alerts';
  static const score = '/score';
  static const community = '/community';
  static const communityNewReport = '/community/new-report';
  static const profile = '/home/profile';
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter({
  MapRepository? mapRepository,
  EnvironmentalRepository? environmentalRepository,
  UnifiedLocationResolver? locationResolver,
  AlertsRepository? alertsRepository,
  ViaCepClient? viaCepClient,
  required AuthRepository authRepository,
}) {
  final mapRepo = mapRepository ?? LiveMapRepository();
  final envRepo = environmentalRepository ?? LiveEnvironmentalRepository();
  final unifiedResolver = locationResolver ??
      UnifiedLocationResolver(
        coordinatesResolver: UserCoordinatesResolver(
          geocodingClient: GeocodingClient(),
        ),
      );
  final alertsRepo = alertsRepository ?? LiveAlertsRepository();
  final cepClient = viaCepClient ?? LiveViaCepClient();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: authRepository,
    redirect: (context, state) {
      final matchedLocation = state.matchedLocation;
      final isSplash = matchedLocation == AppRoutes.splash;
      final isLogin = matchedLocation == AppRoutes.login;
      final isRegister = matchedLocation == AppRoutes.register;
      final isForgotPassword = matchedLocation == AppRoutes.forgotPassword;

      if (isSplash) return null;

      if (!authRepository.isLoggedIn &&
          !isLogin &&
          !isRegister &&
          !isForgotPassword) {
        return AppRoutes.login;
      }

      if (authRepository.isLoggedIn &&
          (isLogin || isRegister || isForgotPassword)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => SplashScreen(
          authRepository: authRepository,
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => LoginScreen(
          authRepository: authRepository,
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => RegisterScreen(
          authRepository: authRepository,
          viaCepClient: cepClient,
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => ForgotPasswordScreen(
          authRepository: authRepository,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(
            navigationShell: navigationShell,
            authRepository: authRepository,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => HomeScreen(
                  authRepository: authRepository,
                  environmentalRepository: envRepo,
                  locationResolver: unifiedResolver,
                  alertsRepository: alertsRepo,
                ),
                routes: [
                  GoRoute(
                    path: 'profile',
                    name: 'profile',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => ProfileScreen(
                      authRepository: authRepository,
                      viaCepClient: cepClient,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.map,
                name: 'map',
                builder: (context, state) => MapScreen(
                  repository: mapRepo,
                  authRepository: authRepository,
                  locationResolver: unifiedResolver,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.alerts,
                name: 'alerts',
                builder: (context, state) => AlertsScreen(
                  authRepository: authRepository,
                  environmentalRepository: envRepo,
                  locationResolver: unifiedResolver,
                  alertsRepository: alertsRepo,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.score,
                name: 'score',
                builder: (context, state) => ScoreScreen(
                  authRepository: authRepository,
                  environmentalRepository: envRepo,
                  locationResolver: unifiedResolver,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.community,
                name: 'community',
                builder: (context, state) => const CommunityScreen(),
                routes: [
                  GoRoute(
                    path: 'new-report',
                    name: 'community-new-report',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const NewReportScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

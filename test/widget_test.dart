import 'package:flutter/material.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/app.dart';
import 'package:green_signal/core/constants/alert_strings.dart';
import 'package:green_signal/core/constants/app_strings.dart';
import 'package:green_signal/core/constants/community_strings.dart';
import 'package:green_signal/core/constants/home_strings.dart';
import 'package:green_signal/core/constants/map_strings.dart';
import 'package:green_signal/core/constants/score_strings.dart';
import 'package:green_signal/services/auth/auth_repository.dart';
import 'package:green_signal/services/auth/fake_auth_repository.dart';
import 'package:green_signal/services/environment/device_location_service.dart';
import 'package:green_signal/services/environment/environmental_repository.dart';
import 'package:green_signal/services/environment/location_resolver.dart';
import 'package:green_signal/services/environment/map_location_resolver.dart';
import 'package:green_signal/services/map/map_repository.dart';
import 'package:latlong2/latlong.dart';

FakeMapRepository _fakeMapRepository({
  Duration delay = Duration.zero,
}) {
  return FakeMapRepository(
    delay: delay,
    points: [WeightedLatLng(const LatLng(-23.55, -46.63), 0.75)],
  );
}

FakeAuthRepository _fakeAuthRepository({bool startLoggedIn = false}) {
  return FakeAuthRepository(startLoggedIn: startLoggedIn);
}

FakeEnvironmentalRepository _fakeEnvironmentalRepository({
  Duration delay = Duration.zero,
}) {
  return FakeEnvironmentalRepository(delay: delay);
}

const _fakeLocationResolver = FakeLocationResolver();

const _fakeDeviceLocationService = FakeDeviceLocationService();

Widget _buildApp({
  MapRepository? mapRepository,
  AuthRepository? authRepository,
  EnvironmentalRepository? environmentalRepository,
  LocationResolver? locationResolver,
  MapLocationResolver? mapLocationResolver,
  DeviceLocationService? deviceLocationService,
}) {
  final addressResolver = locationResolver ?? _fakeLocationResolver;
  final deviceLocation = deviceLocationService ?? _fakeDeviceLocationService;
  final mapLocResolver = mapLocationResolver ??
      MapLocationResolver(
        deviceLocation: deviceLocation,
        addressResolver: addressResolver,
      );

  return GreenSignalApp(
    mapRepository: mapRepository ?? _fakeMapRepository(),
    authRepository: authRepository ?? _fakeAuthRepository(),
    environmentalRepository:
        environmentalRepository ?? _fakeEnvironmentalRepository(),
    locationResolver: addressResolver,
    deviceLocationService: deviceLocation,
    mapLocationResolver: mapLocResolver,
  );
}

Future<void> _goToLogin(
  WidgetTester tester, {
  MapRepository? mapRepository,
  AuthRepository? authRepository,
  DeviceLocationService? deviceLocationService,
}) async {
  await tester.pumpWidget(
    _buildApp(
      mapRepository: mapRepository,
      authRepository: authRepository,
      deviceLocationService: deviceLocationService,
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 2500));
  await tester.pumpAndSettle();
}

Future<void> _loginAndGoHome(
  WidgetTester tester, {
  MapRepository? mapRepository,
  AuthRepository? authRepository,
  DeviceLocationService? deviceLocationService,
}) async {
  await _goToLogin(
    tester,
    mapRepository: mapRepository,
    authRepository: authRepository,
    deviceLocationService: deviceLocationService,
  );

  await tester.enterText(
    find.byType(TextFormField).at(0),
    'user@example.com',
  );
  await tester.enterText(find.byType(TextFormField).at(1), '123456');
  await tester.tap(find.text(AppStrings.login));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Splash screen shows branding', (WidgetTester tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump();

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.tagline), findsOneWidget);
  });

  testWidgets('Splash navigates to login after delay', (WidgetTester tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.welcomeTitle), findsOneWidget);
  });

  testWidgets('Login navigates to register', (WidgetTester tester) async {
    await _goToLogin(tester);

    await tester.tap(find.text(AppStrings.signUp));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.registerTitle), findsOneWidget);
  });

  testWidgets('Login shows validation errors only after submit', (
    WidgetTester tester,
  ) async {
    await _goToLogin(tester);

    await tester.tap(find.byType(TextFormField).first);
    await tester.pump();

    expect(find.text('E-mail é obrigatório'), findsNothing);

    await tester.tap(find.text(AppStrings.login));
    await tester.pump();

    expect(find.text('E-mail é obrigatório'), findsOneWidget);
  });

  testWidgets('Login shows error for invalid credentials', (
    WidgetTester tester,
  ) async {
    await _goToLogin(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass');
    await tester.tap(find.text(AppStrings.login));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.invalidCredentials), findsOneWidget);
  });

  testWidgets('Register saves user and returns to login', (
    WidgetTester tester,
  ) async {
    await _goToLogin(tester);

    await tester.tap(find.text(AppStrings.signUp));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Novo Usuario');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'novo@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'Rua Nova, 10');
    await tester.enterText(find.byType(TextFormField).at(3), '11988887777');
    await tester.enterText(find.byType(TextFormField).at(4), '123456');
    await tester.enterText(find.byType(TextFormField).at(5), '123456');

    await tester.ensureVisible(find.text(AppStrings.register));
    await tester.tap(find.text(AppStrings.register));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.registerSuccess), findsOneWidget);
    expect(find.text(AppStrings.welcomeTitle), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'novo@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text(AppStrings.login));
    await tester.pumpAndSettle();

    expect(find.text('83'), findsOneWidget);
  });

  testWidgets('Persisted session skips login on splash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(authRepository: _fakeAuthRepository(startLoggedIn: true)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.text('83'), findsOneWidget);
    expect(find.text(AppStrings.welcomeTitle), findsNothing);
  });

  testWidgets('Logout clears session and returns to login', (
    WidgetTester tester,
  ) async {
    await _loginAndGoHome(tester);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.logout));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.welcomeTitle), findsOneWidget);
  });

  testWidgets('Login navigates to home after valid submit', (
    WidgetTester tester,
  ) async {
    await _loginAndGoHome(tester);

    expect(find.text('83'), findsOneWidget);
    expect(find.text(HomeStrings.activeAlerts), findsOneWidget);
  });

  testWidgets('Bottom nav opens map screen', (WidgetTester tester) async {
    await _loginAndGoHome(tester);

    await tester.tap(find.text(HomeStrings.navMap));
    await tester.pumpAndSettle();

    expect(find.text(MapStrings.mapTitle), findsOneWidget);
    expect(find.text(MapStrings.layerAirQuality), findsOneWidget);
    expect(find.text(MapStrings.layerHotspots), findsOneWidget);
    expect(find.text(MapStrings.legendAirLow), findsOneWidget);
    expect(find.text(MapStrings.attribution), findsOneWidget);
  });

  testWidgets('Map shows loading indicator while fetching data', (
    WidgetTester tester,
  ) async {
    await _loginAndGoHome(
      tester,
      mapRepository: _fakeMapRepository(
        delay: const Duration(milliseconds: 500),
      ),
      deviceLocationService: const FakeDeviceLocationService(
        delay: Duration(milliseconds: 300),
      ),
    );

    await tester.tap(find.text(HomeStrings.navMap));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Map filter switches to temperature layer', (
    WidgetTester tester,
  ) async {
    await _loginAndGoHome(tester);

    await tester.tap(find.text(HomeStrings.navMap));
    await tester.pumpAndSettle();

    await tester.tap(find.text(MapStrings.layerTemperature));
    await tester.pumpAndSettle();

    expect(find.text(MapStrings.layerTemperature), findsOneWidget);
    expect(find.text(MapStrings.legendTempLow), findsOneWidget);
    expect(find.text(MapStrings.legendTempHigh), findsOneWidget);
    expect(find.textContaining('15°C'), findsOneWidget);
    expect(find.textContaining('35°C'), findsOneWidget);
  });

  testWidgets('Bottom nav opens alerts screen with mock data', (
    WidgetTester tester,
  ) async {
    await _loginAndGoHome(tester);

    await tester.tap(find.text(HomeStrings.navAlerts));
    await tester.pumpAndSettle();

    expect(find.text(AlertStrings.screenTitle), findsAtLeast(1));
    expect(find.text(AlertStrings.tabActive), findsOneWidget);
    expect(find.text('Chuva intensa'), findsOneWidget);
    expect(find.text('Calor extremo'), findsOneWidget);
  });

  testWidgets('Alerts filter switches to recent tab', (
    WidgetTester tester,
  ) async {
    await _loginAndGoHome(tester);

    await tester.tap(find.text(HomeStrings.navAlerts));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AlertStrings.tabRecent));
    await tester.pumpAndSettle();

    expect(find.text('Vento forte'), findsOneWidget);
    expect(find.text('Chuva intensa'), findsNothing);
  });

  testWidgets('Home view all navigates to alerts screen', (
    WidgetTester tester,
  ) async {
    await _loginAndGoHome(tester);

    await tester.ensureVisible(find.text(HomeStrings.viewAll).first);
    await tester.tap(find.text(HomeStrings.viewAll).first);
    await tester.pumpAndSettle();

    expect(find.text(AlertStrings.screenTitle), findsAtLeast(1));
    expect(find.text('Chuva intensa'), findsOneWidget);
  });

  testWidgets('Bottom nav opens score screen with mock data', (
    WidgetTester tester,
  ) async {
    await _loginAndGoHome(tester);

    await tester.tap(find.text(HomeStrings.navScore));
    await tester.pumpAndSettle();

    expect(find.text(ScoreStrings.screenTitle), findsOneWidget);
    expect(find.textContaining('Vila Madalena'), findsOneWidget);
    expect(find.text('83'), findsOneWidget);
    expect(find.text('Ruim AQI 68'), findsOneWidget);
    expect(find.text(ScoreStrings.indicatorsTitle), findsOneWidget);
  });

  testWidgets('Score screen filter shows coming soon snackbar', (
    WidgetTester tester,
  ) async {
    await _loginAndGoHome(tester);

    await tester.tap(find.text(HomeStrings.navScore));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.featureComingSoon), findsOneWidget);
  });

  testWidgets('Bottom nav opens community screen with mock data', (
    WidgetTester tester,
  ) async {
    await _loginAndGoHome(tester);

    await tester.tap(find.text(HomeStrings.navCommunity));
    await tester.pumpAndSettle();

    expect(find.text(CommunityStrings.screenTitle), findsAtLeast(1));
    expect(find.text('Maria R.'), findsOneWidget);
    expect(find.text(CommunityStrings.filterFlood), findsAtLeast(1));
    expect(
      find.textContaining('Rua das Flores alagada'),
      findsOneWidget,
    );
  });

  testWidgets('Community filter shows only flood reports', (
    WidgetTester tester,
  ) async {
    await _loginAndGoHome(tester);

    await tester.tap(find.text(HomeStrings.navCommunity));
    await tester.pumpAndSettle();

    await tester.tap(find.text(CommunityStrings.filterFlood).first);
    await tester.pumpAndSettle();

    expect(find.text('Maria R.'), findsOneWidget);
    expect(find.text('João C.'), findsNothing);
  });

  testWidgets('Community add button opens new report screen', (
    WidgetTester tester,
  ) async {
    await _loginAndGoHome(tester);

    await tester.tap(find.text(HomeStrings.navCommunity));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();

    expect(find.text(CommunityStrings.newReportTitle), findsOneWidget);
    expect(find.text(CommunityStrings.submitReport), findsOneWidget);
  });

  testWidgets('New report submit shows success and returns to feed', (
    WidgetTester tester,
  ) async {
    await _loginAndGoHome(tester);

    await tester.tap(find.text(HomeStrings.navCommunity));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();

    await tester.tap(find.text(CommunityStrings.typeFlood).last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField),
      'Alagamento na rua principal.',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(CommunityStrings.submitReport));
    await tester.pumpAndSettle();

    expect(find.text(CommunityStrings.reportSuccess), findsOneWidget);
    expect(find.text(CommunityStrings.screenTitle), findsAtLeast(1));
  });
}

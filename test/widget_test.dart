import 'package:flutter/material.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/app.dart';
import 'package:green_signal/core/constants/alert_strings.dart';
import 'package:green_signal/core/constants/app_strings.dart';
import 'package:green_signal/core/constants/home_strings.dart';
import 'package:green_signal/core/constants/map_strings.dart';
import 'package:green_signal/core/constants/score_strings.dart';
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

Future<void> _loginAndGoHome(
  WidgetTester tester, {
  MapRepository? mapRepository,
}) async {
  await tester.pumpWidget(
    GreenSignalApp(mapRepository: mapRepository ?? _fakeMapRepository()),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 2500));
  await tester.pumpAndSettle();

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
    await tester.pumpWidget(GreenSignalApp());
    await tester.pump();

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.tagline), findsOneWidget);
  });

  testWidgets('Splash navigates to login after delay', (WidgetTester tester) async {
    await tester.pumpWidget(GreenSignalApp());
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.welcomeTitle), findsOneWidget);
  });

  testWidgets('Login navigates to register', (WidgetTester tester) async {
    await tester.pumpWidget(GreenSignalApp());
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.signUp));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.registerTitle), findsOneWidget);
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
    );

    await tester.tap(find.text(HomeStrings.navMap));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

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
    expect(find.text('65'), findsOneWidget);
    expect(find.text('Moderada AQI 68'), findsOneWidget);
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
}

import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/core/constants/alert_messages.dart';
import 'package:green_signal/models/alert_item.dart';
import 'package:green_signal/models/environmental_snapshot.dart';
import 'package:green_signal/models/home_data.dart';
import 'package:green_signal/services/alerts/derived_alerts_generator.dart';
import 'package:latlong2/latlong.dart';

void main() {
  const location = ResolvedLocation(
    position: LatLng(-25.54, -54.58),
    label: 'Foz do Iguaçu, PR',
    neighborhood: 'Centro',
  );

  const generator = DerivedAlertsGenerator();

  EnvironmentalSnapshot snapshot({
    double? aqi,
    double? temperatureC,
    double? precipitationMm,
    int hotspotCount = 0,
    int riskScore = 20,
  }) {
    return EnvironmentalSnapshot(
      position: location.position,
      locationLabel: location.label,
      riskScore: riskScore,
      riskLevel: RiskLevel.fromScore(riskScore),
      aqi: aqi,
      temperatureC: temperatureC,
      precipitationMm: precipitationMm,
      hotspotCount: hotspotCount,
      fetchedAt: DateTime(2026, 1, 1),
    );
  }

  test('creates heavy rain alert when precipitation is high', () {
    final alerts = generator.generate(
      snapshot: snapshot(precipitationMm: 20),
      location: location,
    );

    expect(
      alerts.any((a) => a.title == AlertMessages.heavyRainTitle),
      isTrue,
    );
  });

  test('creates extreme heat alert above 35C', () {
    final alerts = generator.generate(
      snapshot: snapshot(temperatureC: 36),
      location: location,
    );

    expect(
      alerts.any((a) => a.title == AlertMessages.extremeHeatTitle),
      isTrue,
    );
  });

  test('creates poor air alert when AQI is high', () {
    final alerts = generator.generate(
      snapshot: snapshot(aqi: 120),
      location: location,
    );

    expect(
      alerts.any((a) => a.title == AlertMessages.poorAirTitle),
      isTrue,
    );
  });

  test('creates wildfire alert when hotspots exist', () {
    final alerts = generator.generate(
      snapshot: snapshot(hotspotCount: 2),
      location: location,
    );

    expect(
      alerts.any((a) => a.title == AlertMessages.wildfireTitle),
      isTrue,
    );
  });

  test('creates informative alert when conditions are favorable', () {
    final alerts = generator.generate(
      snapshot: snapshot(aqi: 15, precipitationMm: 0, hotspotCount: 0),
      location: location,
    );

    expect(
      alerts.any((a) => a.tab == AlertTab.informative),
      isTrue,
    );
  });
}

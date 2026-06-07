import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/models/alert_item.dart';
import 'package:green_signal/models/environmental_snapshot.dart';
import 'package:green_signal/models/home_data.dart';
import 'package:green_signal/services/alerts/alerts_repository.dart';
import 'package:green_signal/services/alerts/inmet_alerts_client.dart';
import 'package:latlong2/latlong.dart';

void main() {
  const location = ResolvedLocation(
    position: LatLng(-25.54, -54.58),
    label: 'Foz do Iguaçu, PR',
    neighborhood: 'Centro',
  );

  EnvironmentalSnapshot snapshot({double precipitationMm = 20}) {
    return EnvironmentalSnapshot(
      position: location.position,
      locationLabel: location.label,
      riskScore: 80,
      riskLevel: RiskLevel.high,
      precipitationMm: precipitationMm,
      temperatureC: 36,
      aqi: 120,
      hotspotCount: 2,
      fetchedAt: DateTime(2026, 1, 1),
    );
  }

  test('merges derived alerts when INMET fails', () async {
    final repository = LiveAlertsRepository(
      inmetAlertsClient: const FakeInmetAlertsClient(shouldFail: true),
    );

    final result = await repository.fetchAlerts(
      location: location,
      snapshot: snapshot(),
    );

    expect(result.inmetHasError, isTrue);
    expect(result.alerts, isNotEmpty);
    expect(result.alerts.any((a) => a.id.startsWith('derived-')), isTrue);
  });

  test('prefers INMET alert over duplicate derived rain alert', () async {
    const inmetAlert = AlertItem(
      id: 'inmet-1',
      tab: AlertTab.active,
      riskLevel: RiskLevel.high,
      title: 'Chuva intensa',
      description: 'Aviso oficial.',
      region: 'Foz do Iguaçu/PR',
      timeAgo: 'Há 1 h',
    );

    final repository = LiveAlertsRepository(
      inmetAlertsClient: const FakeInmetAlertsClient(alerts: [inmetAlert]),
    );

    final result = await repository.fetchAlerts(
      location: location,
      snapshot: snapshot(),
    );

    final rainAlerts = result.alerts
        .where((alert) => alert.title.toLowerCase().contains('chuva'))
        .toList();

    expect(rainAlerts, hasLength(1));
    expect(rainAlerts.first.id, 'inmet-1');
  });
}

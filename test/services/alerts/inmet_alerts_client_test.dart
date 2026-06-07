import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/models/alert_item.dart';
import 'package:green_signal/models/environmental_snapshot.dart';
import 'package:green_signal/services/alerts/inmet_alerts_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

import '../../fixtures/inmet_rss_sample.dart';

void main() {
  const location = ResolvedLocation(
    position: LatLng(-25.54, -54.58),
    label: 'Foz do Iguaçu, PR',
    neighborhood: 'Centro',
  );

  group('InmetRssParser', () {
    test('parses active alert from RSS sample', () {
      final alerts = InmetRssParser.parse(sampleInmetRss);

      expect(alerts, hasLength(1));
      expect(alerts.first.title, 'Chuva intensa');
      expect(alerts.first.tab, AlertTab.active);
      expect(alerts.first.region, 'Foz do Iguaçu/PR');
    });
  });

  group('LiveInmetAlertsClient', () {
    test('filters alerts by user city and state', () async {
      final client = LiveInmetAlertsClient(
        client: MockClient((_) async => http.Response(sampleInmetRss, 200)),
      );

      final alerts = await client.fetchForLocation(location);

      expect(alerts, hasLength(1));
      client.dispose();
    });
  });
}

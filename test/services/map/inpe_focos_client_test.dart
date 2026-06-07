import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/services/map/inpe_focos_client.dart';
import 'package:green_signal/services/map/map_grid_sampler.dart';

void main() {
  group('InpeFocosClient', () {
    late InpeFocosClient client;

    setUp(() {
      client = InpeFocosClient();
    });

    test('parseCsv extracts lat, lon and frp', () {
      const csv = '''
id,lat,lon,data_hora_gmt,satelite,frp
abc,-23.550,-46.633,2026-06-06 00:00:00,GOES-19,45.5
def,-22.900,-47.060,2026-06-06 00:05:00,GOES-19,120.0
''';

      final points = client.parseCsv(csv);
      expect(points, hasLength(2));
      expect(points.first.position.latitude, -23.550);
      expect(points.first.frp, 45.5);
    });

    test('filterByBounds keeps points inside viewport', () {
      const csv = '''
lat,lon,frp
-23.550,-46.633,10
-10.000,-50.000,50
''';

      final all = client.parseCsv(csv);
      const bounds = LatLngBounds(
        south: -24,
        north: -23,
        west: -47,
        east: -46,
      );

      final filtered = client.filterByBounds(all, bounds);
      expect(filtered, hasLength(1));
      expect(filtered.first.frp, 10);
    });
  });
}

import 'dart:convert';

import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/models/map_layer_data.dart';
import 'package:green_signal/services/map/inpe_focos_client.dart';
import 'package:green_signal/services/map/map_grid_sampler.dart';
import 'package:green_signal/services/map/map_repository.dart';
import 'package:green_signal/services/map/open_meteo_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

void main() {
  const bounds = LatLngBounds(
    south: -23.65,
    north: -23.45,
    west: -46.75,
    east: -46.55,
  );

  group('LiveMapRepository', () {
    test('uses cache on repeated fetch with same bounds', () async {
      var requestCount = 0;
      final httpClient = MockClient((request) async {
        requestCount++;
        return http.Response('{"current":{"european_aqi":30,"pm2_5":10}}', 200);
      });

      final openMeteo = OpenMeteoClient(client: httpClient);
      final repository = LiveMapRepository(openMeteoClient: openMeteo);

      await repository.fetchLayer(
        layer: MapLayer.airQuality,
        bounds: bounds,
        zoom: 10,
      );
      final countAfterFirst = requestCount;
      expect(countAfterFirst, greaterThan(0));

      await repository.fetchLayer(
        layer: MapLayer.airQuality,
        bounds: bounds,
        zoom: 10,
      );

      expect(requestCount, countAfterFirst);
      repository.dispose();
    });

    test('filters hotspots by bounds with INPE csv format', () async {
      final httpClient = MockClient((request) async {
        return http.Response(
          'lat,lon,frp\n-23.550,-46.633,80\n-5.000,-50.000,200\n',
          200,
        );
      });

      final inpe = InpeFocosClient(client: httpClient);
      final repository = LiveMapRepository(inpeFocosClient: inpe);

      final result = await repository.fetchLayer(
        layer: MapLayer.hotspots,
        bounds: bounds,
        zoom: 10,
      );

      expect(result.hotspotMarkers, isNotEmpty);
      expect(result.displayMode, MapLayerDisplayMode.markers);
      expect(result.source, 'INPE Queimadas');
      repository.dispose();
    });

    test('returns isEmpty for rain when precipitation sum is zero', () async {
      final httpClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'hourly': {'precipitation': List.filled(12, 0.0)},
          }),
          200,
        );
      });

      final openMeteo = OpenMeteoClient(client: httpClient);
      final repository = LiveMapRepository(openMeteoClient: openMeteo);

      final result = await repository.fetchLayer(
        layer: MapLayer.rain,
        bounds: bounds,
        zoom: 10,
      );

      expect(result.isEmpty, isTrue);
      expect(result.points, isEmpty);
      repository.dispose();
    });
  });

  group('FakeMapRepository', () {
    test('returns configured heatmap points for air quality', () async {
      final fake = FakeMapRepository(
        points: [WeightedLatLng(const LatLng(-23.55, -46.63), 0.9)],
      );

      final result = await fake.fetchLayer(
        layer: MapLayer.airQuality,
        bounds: bounds,
        zoom: 10,
      );

      expect(result.points, isNotEmpty);
      expect(result.displayMode, MapLayerDisplayMode.heatmap);
      expect(result.gridLatStep, greaterThan(0));
      expect(result.hasError, isFalse);
    });

    test('returns markers for hotspots layer', () async {
      final fake = FakeMapRepository();

      final result = await fake.fetchLayer(
        layer: MapLayer.hotspots,
        bounds: bounds,
        zoom: 10,
      );

      expect(result.hotspotMarkers, isNotEmpty);
      expect(result.displayMode, MapLayerDisplayMode.markers);
      expect(result.points, isEmpty);
    });
  });
}

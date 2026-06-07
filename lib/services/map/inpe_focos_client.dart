import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../core/constants/map_config.dart';
import '../../models/inpe_hotspot_point.dart';
import 'map_grid_sampler.dart';

class InpeFocosClient {
  InpeFocosClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  List<InpeHotspotPoint>? _cachedPoints;
  DateTime? _cachedAt;

  Future<List<InpeHotspotPoint>> fetchAll({DateTime? referenceDate}) async {
    if (_cachedPoints != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) <
            Duration(minutes: MapConfig.inpeCacheTtlMinutes)) {
      return _cachedPoints!;
    }

    final now = referenceDate ?? DateTime.now().toUtc();
    List<InpeHotspotPoint>? points;

    for (var dayOffset = 0; dayOffset < 7; dayOffset++) {
      points = await _tryFetchForDate(
        now.subtract(Duration(days: dayOffset)),
      );
      if (points != null && points.isNotEmpty) break;
    }

    points ??= [];

    if (points.isNotEmpty) {
      _cachedPoints = points;
      _cachedAt = DateTime.now();
    }

    return points;
  }

  Future<List<InpeHotspotPoint>?> _tryFetchForDate(DateTime date) async {
    final formatted =
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final url =
        '${MapConfig.inpeFocosBaseUrl}/focos_diario_br_$formatted.csv';

    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) return null;

    return parseCsv(response.body);
  }

  List<InpeHotspotPoint> parseCsv(String body) {
    final lines = body.split('\n');
    if (lines.isEmpty) return [];

    final header = _parseCsvLine(lines.first);
    final latIndex = _columnIndex(header, ['lat', 'latitude']);
    final lngIndex = _columnIndex(header, ['lon', 'longitude']);
    final frpIndex = _columnIndex(header, ['frp']);

    if (latIndex == null || lngIndex == null) return [];

    final points = <InpeHotspotPoint>[];
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final cols = _parseCsvLine(line);
      if (cols.length <= latIndex || cols.length <= lngIndex) continue;

      final lat = double.tryParse(cols[latIndex].trim());
      final lng = double.tryParse(cols[lngIndex].trim());
      if (lat == null || lng == null) continue;

      final frp = frpIndex != null && cols.length > frpIndex
          ? (double.tryParse(cols[frpIndex].trim()) ?? 0.0)
          : 0.0;

      points.add(
        InpeHotspotPoint(
          position: LatLng(lat, lng),
          frp: frp,
        ),
      );
    }
    return points;
  }

  List<InpeHotspotPoint> filterByBounds(
    List<InpeHotspotPoint> points,
    LatLngBounds bounds,
  ) {
    return points.where((p) => bounds.contains(p.position)).toList();
  }

  int? _columnIndex(List<String> header, List<String> candidates) {
    for (final name in candidates) {
      final index = header.indexWhere(
        (h) => h.trim().toLowerCase() == name.toLowerCase(),
      );
      if (index >= 0) return index;
    }
    return null;
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    result.add(buffer.toString());
    return result;
  }

  void clearCache() {
    _cachedPoints = null;
    _cachedAt = null;
  }

  void dispose() => _client.close();
}

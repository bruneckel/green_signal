import '../../core/constants/map_config.dart';
import '../../models/map_fetch_result.dart';

class MapCacheEntry {
  MapCacheEntry(this.result, this.expiresAt);

  final MapFetchResult result;
  final DateTime expiresAt;

  bool get isValid => DateTime.now().isBefore(expiresAt);
}

class MapCache {
  final _entries = <String, MapCacheEntry>{};

  MapFetchResult? get(String key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (!entry.isValid) return null;
    return entry.result;
  }

  MapFetchResult? getStale(String key) {
    return _entries[key]?.result;
  }

  void put(String key, MapFetchResult result, {int? ttlMinutes}) {
    final ttl = ttlMinutes ?? MapConfig.openMeteoCacheTtlMinutes;
    _entries[key] = MapCacheEntry(
      result,
      DateTime.now().add(Duration(minutes: ttl)),
    );
  }

  void clear() => _entries.clear();
}

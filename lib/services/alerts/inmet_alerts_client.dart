import 'package:http/http.dart' as http;

import '../../core/constants/alert_messages.dart';
import '../../core/constants/alerts_config.dart';
import '../../models/alert_item.dart';
import '../../models/home_data.dart';
import '../../models/environmental_snapshot.dart';
import 'alert_time_formatter.dart';

abstract class InmetAlertsClient {
  Future<List<AlertItem>> fetchForLocation(ResolvedLocation location);
}

class LiveInmetAlertsClient implements InmetAlertsClient {
  LiveInmetAlertsClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  List<AlertItem>? _cachedAlerts;
  DateTime? _cachedAt;

  @override
  Future<List<AlertItem>> fetchForLocation(ResolvedLocation location) async {
    if (_cachedAlerts != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) <
            Duration(minutes: AlertsConfig.inmetCacheTtlMinutes)) {
      return _filterForLocation(_cachedAlerts!, location);
    }

    final response = await _client
        .get(Uri.parse(AlertsConfig.inmetRssUrl))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw InmetAlertsException(response.statusCode);
    }

    final parsed = InmetRssParser.parse(response.body);
    _cachedAlerts = parsed;
    _cachedAt = DateTime.now();
    return _filterForLocation(parsed, location);
  }

  List<AlertItem> _filterForLocation(
    List<AlertItem> alerts,
    ResolvedLocation location,
  ) {
    final cityState = _parseCityState(location.label);
    if (cityState == null) return alerts;

    final (city, state) = cityState;
    final normalizedCity = _normalize(city);
    final normalizedState = _normalize(state);

    return alerts.where((alert) {
      final area = _normalize(alert.region);
      return area.contains(normalizedCity) &&
          (area.contains(normalizedState) ||
              area.contains('/$normalizedState') ||
              area.contains(' $normalizedState'));
    }).toList();
  }

  (String, String)? _parseCityState(String label) {
    final parts = label.split(',');
    if (parts.length < 2) return null;
    return (parts[0].trim(), parts[1].trim());
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('ã', 'a')
        .replaceAll('á', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ç', 'c')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ú', 'u');
  }

  void dispose() => _client.close();
}

class FakeInmetAlertsClient implements InmetAlertsClient {
  const FakeInmetAlertsClient({this.alerts = const [], this.shouldFail = false});

  final List<AlertItem> alerts;
  final bool shouldFail;

  @override
  Future<List<AlertItem>> fetchForLocation(ResolvedLocation location) async {
    if (shouldFail) throw InmetAlertsException(500);
    return alerts;
  }
}

class InmetAlertsException implements Exception {
  InmetAlertsException(this.statusCode);

  final int statusCode;

  @override
  String toString() => 'InmetAlertsException($statusCode)';
}

abstract final class InmetRssParser {
  static List<AlertItem> parse(String xml) {
    final items = <AlertItem>[];
    final itemPattern = RegExp(r'<item>([\s\S]*?)</item>', multiLine: true);

    for (final match in itemPattern.allMatches(xml)) {
      final block = match.group(1)!;
      final item = _parseItem(block);
      if (item != null) items.add(item);
    }

    return items;
  }

  static AlertItem? _parseItem(String block) {
    final title = _tagValue(block, 'title');
    final link = _tagValue(block, 'link');
    final description = _tagValue(block, 'description');
    final pubDateRaw = _tagValue(block, 'pubDate');
    if (title == null || description == null) return null;

    final details = _parseDescriptionTable(description);
    final event = details['Evento'] ?? title;
    final severity = details['Severidade'] ?? '';
    final status = details['Status'] ?? '';
    final area = details['Área'] ?? details['Area'] ?? '';
    final body = details['Descrição'] ?? details['Descricao'] ?? description;

    final start = _parseBrazilianDateTime(details['Início'] ?? details['Inicio']);
    final end = _parseBrazilianDateTime(details['Fim']);
    final published = _parseRssDate(pubDateRaw) ?? start ?? DateTime.now();

    final tab = _resolveTab(status: status, start: start, end: end, published: published);
    if (tab == null) return null;

    final id = link ?? 'inmet-${published.millisecondsSinceEpoch}-$event';

    return AlertItem(
      id: id,
      tab: tab,
      riskLevel: _mapSeverity(severity),
      title: event.trim(),
      description: body.trim(),
      region: area.trim().isNotEmpty ? area.trim() : AlertMessages.inmetSourceLabel,
      timeAgo: AlertTimeFormatter.relative(published),
    );
  }

  static String? _tagValue(String block, String tag) {
    final cdata = RegExp(
      '<$tag><!\\[CDATA\\[([\\s\\S]*?)\\]\\]></$tag>',
      caseSensitive: false,
    ).firstMatch(block);
    if (cdata != null) return cdata.group(1)?.trim();

    final plain = RegExp(
      '<$tag>([\\s\\S]*?)</$tag>',
      caseSensitive: false,
    ).firstMatch(block);
    return plain?.group(1)?.trim();
  }

  static Map<String, String> _parseDescriptionTable(String html) {
    final details = <String, String>{};
    final rowPattern = RegExp(
      r'<th[^>]*>([^<]+)</th>\s*<td[^>]*>([\s\S]*?)</td>',
      caseSensitive: false,
    );

    for (final match in rowPattern.allMatches(html)) {
      final key = _stripHtml(match.group(1) ?? '').trim();
      final value = _stripHtml(match.group(2) ?? '').trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        details[key] = value;
      }
    }

    return details;
  }

  static String _stripHtml(String value) {
    return value
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static AlertTab? _resolveTab({
    required String status,
    required DateTime? start,
    required DateTime? end,
    required DateTime published,
  }) {
    final now = DateTime.now();
    final normalizedStatus = status.toLowerCase();

    if (end != null && end.isBefore(now)) {
      if (now.difference(end).inHours <= AlertsConfig.recentAlertMaxAgeHours) {
        return AlertTab.recent;
      }
      return null;
    }

    if (normalizedStatus.contains('encerr') ||
        normalizedStatus.contains('inativ')) {
      if (now.difference(published).inHours <= AlertsConfig.recentAlertMaxAgeHours) {
        return AlertTab.recent;
      }
      return null;
    }

    return AlertTab.active;
  }

  static RiskLevel _mapSeverity(String severity) {
    final value = severity.toLowerCase();
    if (value.contains('extrem') ||
        value.contains('sever') ||
        value.contains('grave') ||
        value.contains('muito')) {
      return RiskLevel.high;
    }
    if (value.contains('moder')) return RiskLevel.medium;
    return RiskLevel.low;
  }

  static DateTime? _parseRssDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final match = RegExp(
      r'(\d{1,2})\s+([A-Za-z]{3})\s+(\d{4})\s+(\d{2}):(\d{2}):(\d{2})',
    ).firstMatch(raw);
    if (match == null) return null;

    final month = _months[match.group(2)!.toLowerCase()];
    if (month == null) return null;

    return DateTime(
      int.parse(match.group(3)!),
      month,
      int.parse(match.group(1)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
      int.parse(match.group(6)!),
    );
  }

  static const _months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  static DateTime? _parseBrazilianDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final match = RegExp(
      r'(\d{2})/(\d{2})/(\d{4})\s+(\d{2}):(\d{2})',
    ).firstMatch(raw);
    if (match == null) return null;

    return DateTime(
      int.parse(match.group(3)!),
      int.parse(match.group(2)!),
      int.parse(match.group(1)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
    );
  }
}

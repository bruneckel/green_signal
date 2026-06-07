import '../../models/alert_item.dart';
import '../../models/home_data.dart';
import '../../models/environmental_snapshot.dart';
import 'derived_alerts_generator.dart';
import 'inmet_alerts_client.dart';

class AlertsFetchResult {
  const AlertsFetchResult({
    required this.alerts,
    this.inmetHasError = false,
  });

  final List<AlertItem> alerts;
  final bool inmetHasError;
}

abstract class AlertsRepository {
  Future<AlertsFetchResult> fetchAlerts({
    required ResolvedLocation location,
    required EnvironmentalSnapshot snapshot,
  });
}

class LiveAlertsRepository implements AlertsRepository {
  LiveAlertsRepository({
    DerivedAlertsGenerator? derivedGenerator,
    InmetAlertsClient? inmetAlertsClient,
  })  : _derivedGenerator = derivedGenerator ?? const DerivedAlertsGenerator(),
        _inmetClient = inmetAlertsClient ?? LiveInmetAlertsClient();

  final DerivedAlertsGenerator _derivedGenerator;
  final InmetAlertsClient _inmetClient;

  @override
  Future<AlertsFetchResult> fetchAlerts({
    required ResolvedLocation location,
    required EnvironmentalSnapshot snapshot,
  }) async {
    final derived = _derivedGenerator.generate(
      snapshot: snapshot,
      location: location,
    );

    var inmetHasError = false;
    List<AlertItem> inmet = const [];
    try {
      inmet = await _inmetClient.fetchForLocation(location);
    } catch (_) {
      inmetHasError = true;
    }

    final merged = _mergeAlerts(inmet: inmet, derived: derived);
    return AlertsFetchResult(alerts: merged, inmetHasError: inmetHasError);
  }

  List<AlertItem> _mergeAlerts({
    required List<AlertItem> inmet,
    required List<AlertItem> derived,
  }) {
    final merged = [...inmet];
    final inmetTopics = inmet.map(_topicKey).toSet();

    for (final alert in derived) {
      final topic = _topicKey(alert);
      if (inmetTopics.contains(topic)) continue;
      if (_isDuplicateOfInmet(alert, inmet)) continue;
      merged.add(alert);
    }

    merged.sort(_compareAlerts);
    return merged;
  }

  bool _isDuplicateOfInmet(AlertItem derived, List<AlertItem> inmet) {
    final title = derived.title.toLowerCase();
    for (final official in inmet) {
      final officialTitle = official.title.toLowerCase();
      if (_shareTopic(title, officialTitle)) return true;
    }
    return false;
  }

  bool _shareTopic(String a, String b) {
    const keywords = [
      'chuva',
      'temporal',
      'calor',
      'onda',
      'frio',
      'vento',
      'granizo',
      'queimada',
      'incendio',
      'incêndio',
    ];
    for (final keyword in keywords) {
      if (a.contains(keyword) && b.contains(keyword)) return true;
    }
    return false;
  }

  String _topicKey(AlertItem alert) => '${alert.tab.name}:${alert.title.toLowerCase()}';

  int _compareAlerts(AlertItem a, AlertItem b) {
    final tabOrder = {
      AlertTab.active: 0,
      AlertTab.recent: 1,
      AlertTab.informative: 2,
    };
    final tabCompare = tabOrder[a.tab]!.compareTo(tabOrder[b.tab]!);
    if (tabCompare != 0) return tabCompare;

    final severityCompare =
        _severityRank(b.riskLevel).compareTo(_severityRank(a.riskLevel));
    if (severityCompare != 0) return severityCompare;

    return a.title.compareTo(b.title);
  }

  int _severityRank(RiskLevel level) => switch (level) {
        RiskLevel.high => 3,
        RiskLevel.medium => 2,
        RiskLevel.low => 1,
      };

  void dispose() {
    if (_inmetClient is LiveInmetAlertsClient) {
      _inmetClient.dispose();
    }
  }
}

class FakeAlertsRepository implements AlertsRepository {
  FakeAlertsRepository({
    this.alerts = const [],
    this.inmetHasError = false,
    this.delay = Duration.zero,
  });

  final List<AlertItem> alerts;
  final bool inmetHasError;
  final Duration delay;

  @override
  Future<AlertsFetchResult> fetchAlerts({
    required ResolvedLocation location,
    required EnvironmentalSnapshot snapshot,
  }) async {
    await Future<void>.delayed(delay);
    return AlertsFetchResult(
      alerts: alerts,
      inmetHasError: inmetHasError,
    );
  }
}

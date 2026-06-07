import '../../core/constants/alerts_config.dart';
import '../../core/constants/alert_strings.dart';
import '../../models/alert_item.dart';
import '../../models/home_data.dart';

abstract final class AlertPresentation {
  static List<ActiveAlert> toActiveAlerts(
    List<AlertItem> alerts, {
    int limit = AlertsConfig.homeActiveAlertsLimit,
  }) {
    return alerts
        .where((alert) => alert.tab == AlertTab.active)
        .take(limit)
        .map(
          (alert) => ActiveAlert(
            message: alert.description.isNotEmpty
                ? '${alert.title}. ${alert.description}'
                : alert.title,
            region: alert.region,
          ),
        )
        .toList();
  }

  static List<AlertItem> filterByTab(List<AlertItem> alerts, AlertTab tab) {
    if (tab == AlertTab.all) return sortForDisplay(alerts);
    return alerts.where((alert) => alert.tab == tab).toList();
  }

  static List<AlertItem> sortForDisplay(List<AlertItem> alerts) {
    final sorted = List<AlertItem>.from(alerts);
    sorted.sort(_compareForDisplay);
    return sorted;
  }

  static int countForTab(List<AlertItem> alerts, AlertTab tab) {
    if (tab == AlertTab.all) return alerts.length;
    return alerts.where((alert) => alert.tab == tab).length;
  }

  static Map<AlertTab, int> countsByTab(List<AlertItem> alerts) {
    return {
      for (final tab in AlertTab.values)
        tab: countForTab(alerts, tab),
    };
  }

  static String emptyMessageFor(AlertTab tab) => switch (tab) {
        AlertTab.all => AlertStrings.emptyAll,
        AlertTab.active => AlertStrings.emptyActive,
        AlertTab.recent => AlertStrings.emptyRecent,
        AlertTab.informative => AlertStrings.emptyInformative,
      };

  static String sectionEmptyMessageFor(AlertTab tab) => switch (tab) {
        AlertTab.active => AlertStrings.sectionEmptyActive,
        AlertTab.recent => AlertStrings.sectionEmptyRecent,
        AlertTab.informative => AlertStrings.sectionEmptyInformative,
        AlertTab.all => AlertStrings.emptyAll,
      };

  static int _compareForDisplay(AlertItem a, AlertItem b) {
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

  static int _severityRank(RiskLevel level) => switch (level) {
        RiskLevel.high => 3,
        RiskLevel.medium => 2,
        RiskLevel.low => 1,
      };
}

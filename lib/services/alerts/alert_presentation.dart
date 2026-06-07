import '../../core/constants/alerts_config.dart';
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
}

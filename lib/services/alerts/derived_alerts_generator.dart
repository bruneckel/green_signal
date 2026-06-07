import '../../core/constants/alert_messages.dart';
import '../../core/constants/alerts_config.dart';
import '../../models/alert_item.dart';
import '../../models/environmental_snapshot.dart';
import '../../models/home_data.dart';
import '../map/map_intensity_mapper.dart';

class DerivedAlertsGenerator {
  const DerivedAlertsGenerator({MapIntensityMapper? mapper})
      : _mapper = mapper ?? const MapIntensityMapper();

  final MapIntensityMapper _mapper;

  List<AlertItem> generate({
    required EnvironmentalSnapshot snapshot,
    required ResolvedLocation location,
  }) {
    final region = location.neighborhood.isNotEmpty
        ? location.neighborhood
        : location.label;
    final alerts = <AlertItem>[];

    _addRainAlerts(snapshot, region, alerts);
    _addHeatAlerts(snapshot, region, alerts);
    _addAirAlerts(snapshot, region, alerts);
    _addWildfireAlerts(snapshot, region, alerts);
    _addRiskAlerts(snapshot, region, alerts);
    _addInformativeAlerts(snapshot, region, alerts);

    return alerts;
  }

  void _addRainAlerts(
    EnvironmentalSnapshot snapshot,
    String region,
    List<AlertItem> alerts,
  ) {
    final normalized =
        _mapper.normalizePrecipitation(snapshot.precipitationMm);
    if (normalized >= AlertsConfig.rainHeavyNormalizedThreshold) {
      alerts.add(
        _derivedAlert(
          id: 'derived-rain-heavy',
          tab: AlertTab.active,
          riskLevel: RiskLevel.high,
          title: AlertMessages.heavyRainTitle,
          description: AlertMessages.heavyRainDescription,
          region: region,
        ),
      );
    } else if (normalized >= AlertsConfig.rainModerateNormalizedThreshold) {
      alerts.add(
        _derivedAlert(
          id: 'derived-rain-moderate',
          tab: AlertTab.active,
          riskLevel: RiskLevel.medium,
          title: AlertMessages.rainForecastTitle,
          description: AlertMessages.rainForecastDescription,
          region: region,
        ),
      );
    }
  }

  void _addHeatAlerts(
    EnvironmentalSnapshot snapshot,
    String region,
    List<AlertItem> alerts,
  ) {
    final temp = snapshot.temperatureC;
    if (temp == null) return;

    if (temp >= AlertsConfig.extremeHeatC) {
      alerts.add(
        _derivedAlert(
          id: 'derived-heat-extreme',
          tab: AlertTab.active,
          riskLevel: RiskLevel.high,
          title: AlertMessages.extremeHeatTitle,
          description: AlertMessages.extremeHeatDescription,
          region: region,
        ),
      );
    } else if (temp >= AlertsConfig.highHeatC) {
      alerts.add(
        _derivedAlert(
          id: 'derived-heat-high',
          tab: AlertTab.active,
          riskLevel: RiskLevel.medium,
          title: AlertMessages.highHeatTitle,
          description: AlertMessages.highHeatDescription,
          region: region,
        ),
      );
    }
  }

  void _addAirAlerts(
    EnvironmentalSnapshot snapshot,
    String region,
    List<AlertItem> alerts,
  ) {
    final aqi = snapshot.aqi;
    if (aqi == null) return;

    if (aqi > AlertsConfig.poorAirAqi) {
      alerts.add(
        _derivedAlert(
          id: 'derived-air-poor',
          tab: AlertTab.active,
          riskLevel: RiskLevel.high,
          title: AlertMessages.poorAirTitle,
          description: AlertMessages.poorAirDescription,
          region: region,
        ),
      );
    } else if (aqi > AlertsConfig.moderateAirAqi) {
      alerts.add(
        _derivedAlert(
          id: 'derived-air-moderate',
          tab: AlertTab.active,
          riskLevel: RiskLevel.medium,
          title: AlertMessages.moderateAirTitle,
          description: AlertMessages.moderateAirDescription,
          region: region,
        ),
      );
    }
  }

  void _addWildfireAlerts(
    EnvironmentalSnapshot snapshot,
    String region,
    List<AlertItem> alerts,
  ) {
    if (snapshot.hotspotCount <= 0) return;

    alerts.add(
      _derivedAlert(
        id: 'derived-wildfire',
        tab: AlertTab.active,
        riskLevel: snapshot.hotspotCount >= AlertsConfig.wildfireHighCount
            ? RiskLevel.high
            : RiskLevel.medium,
        title: AlertMessages.wildfireTitle,
        description: AlertMessages.wildfireDescription,
        region: region,
      ),
    );
  }

  void _addRiskAlerts(
    EnvironmentalSnapshot snapshot,
    String region,
    List<AlertItem> alerts,
  ) {
    if (snapshot.riskScore < AlertsConfig.highRiskScore) return;

    alerts.add(
      _derivedAlert(
        id: 'derived-risk-high',
        tab: AlertTab.active,
        riskLevel: RiskLevel.high,
        title: AlertMessages.highRiskTitle,
        description: AlertMessages.highRiskDescription,
        region: region,
      ),
    );
  }

  void _addInformativeAlerts(
    EnvironmentalSnapshot snapshot,
    String region,
    List<AlertItem> alerts,
  ) {
    final aqi = snapshot.aqi;
    final rainNormalized =
        _mapper.normalizePrecipitation(snapshot.precipitationMm);
    final hasActiveConditions = alerts.any((a) => a.tab == AlertTab.active);

    if (!hasActiveConditions &&
        aqi != null &&
        aqi <= AlertsConfig.moderateAirAqi &&
        snapshot.hotspotCount == 0 &&
        rainNormalized < AlertsConfig.rainModerateNormalizedThreshold) {
      alerts.add(
        _derivedAlert(
          id: 'derived-air-good',
          tab: AlertTab.informative,
          riskLevel: RiskLevel.low,
          title: AlertMessages.goodAirTitle,
          description: AlertMessages.goodAirDescription,
          region: region,
          timeAgo: 'Hoje',
        ),
      );
    }

    final temp = snapshot.temperatureC;
    if (temp != null && temp >= AlertsConfig.highHeatC) {
      alerts.add(
        _derivedAlert(
          id: 'derived-hydration',
          tab: AlertTab.informative,
          riskLevel: RiskLevel.low,
          title: AlertMessages.hydrationTitle,
          description: AlertMessages.hydrationDescription,
          region: region,
          timeAgo: 'Hoje',
        ),
      );
    }
  }

  AlertItem _derivedAlert({
    required String id,
    required AlertTab tab,
    required RiskLevel riskLevel,
    required String title,
    required String description,
    required String region,
    String timeAgo = AlertMessages.derivedTimeAgo,
  }) {
    return AlertItem(
      id: id,
      tab: tab,
      riskLevel: riskLevel,
      title: title,
      description: description,
      region: region,
      timeAgo: timeAgo,
    );
  }
}

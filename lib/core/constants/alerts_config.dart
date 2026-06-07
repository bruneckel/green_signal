abstract final class AlertsConfig {
  static const inmetRssUrl = 'https://apiprevmet3.inmet.gov.br/avisos/rss';
  static const inmetCacheTtlMinutes = 15;
  static const recentAlertMaxAgeHours = 48;
  static const homeActiveAlertsLimit = 3;

  static const rainHeavyNormalizedThreshold = 0.6;
  static const rainModerateNormalizedThreshold = 0.3;
  static const extremeHeatC = 35.0;
  static const highHeatC = 32.0;
  static const poorAirAqi = 100.0;
  static const moderateAirAqi = 50.0;
  static const highRiskScore = 70;
  static const wildfireHighCount = 3;
}

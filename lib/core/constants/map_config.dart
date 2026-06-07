abstract final class MapConfig {
  static const openMeteoAirQualityUrl =
      'https://air-quality-api.open-meteo.com/v1/air-quality';
  static const openMeteoForecastUrl = 'https://api.open-meteo.com/v1/forecast';
  static const inpeFocosBaseUrl =
      'https://dataserver-coids.inpe.br/queimadas/queimadas/focos/csv/diario/Brasil';

  static const maxGridPoints = 64;
  static const requestBatchSize = 6;
  static const openMeteoCacheTtlMinutes = 30;
  static const inpeCacheTtlMinutes = 15;
  static const debounceMs = 400;
  static const boundsChangeThreshold = 0.1;
  static const frpMaxScale = 200.0;
  static const requestTimeoutSeconds = 10;
  static const rainForecastHours = 12;
  static const minGridSuccessRatio = 0.5;
  static const tempScaleMinC = 15.0;
  static const tempScaleMaxC = 35.0;
}

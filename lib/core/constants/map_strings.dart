abstract final class MapStrings {
  static const mapTitle = 'Mapa Ambiental';

  static const layerAirQuality = 'Qualidade do Ar';
  static const layerTemperature = 'Temperatura';
  static const layerRain = 'Chuva';
  static const layerHotspots = 'Queimadas';

  static const legendLow = 'Baixo';
  static const legendHigh = 'Alto Risco';

  static const legendAirLow = 'Bom';
  static const legendAirHigh = 'Alto risco';
  static const legendTempLow = 'Frio';
  static const legendTempHigh = 'Quente';
  static const legendRainLow = 'Seco';
  static const legendRainHigh = 'Chuvoso';
  static const legendBurnLow = 'Baixa';
  static const legendBurnHigh = 'Alta intensidade';

  static const legendAirSubtitle = 'Índice europeu (AQI)';

  static const loadError = 'Não foi possível carregar os dados do mapa.';
  static const staleDataNotice = 'Exibindo dados em cache.';
  static const noRainInRegion = 'Sem chuva prevista nesta região.';
  static const noTemperatureInRegion = 'Sem dados de temperatura nesta região.';
  static const noHotspotsInRegion = 'Nenhuma queimada detectada nesta região.';
  static const locationDeniedNotice =
      'Localização do dispositivo indisponível. Usando endereço cadastrado.';
  static const attribution = 'Dados: Open-Meteo (CC BY 4.0) · INPE Queimadas';
}

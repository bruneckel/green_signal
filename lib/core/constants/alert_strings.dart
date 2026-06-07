abstract final class AlertStrings {
  static const screenTitle = 'Alertas';

  static const tabAll = 'Todos';
  static const tabActive = 'Ativos';
  static const tabRecent = 'Recentes';
  static const tabInformative = 'Informativos';

  static const filterSheetTitle = 'Filtrar alertas';

  static const emptyAll =
      'Sua região está tranquila. Não há alertas no momento.';
  static const emptyActive = 'Nenhum alerta ativo no momento.';
  static const emptyRecent = 'Nenhum alerta recente.';
  static const emptyInformative = 'Nenhum informativo disponível.';

  static const sectionEmptyActive = 'Nenhum alerta ativo';
  static const sectionEmptyRecent = 'Nenhum alerta recente';
  static const sectionEmptyInformative = 'Nenhum informativo';

  static const inmetLoadError = 'Não foi possível carregar avisos do INMET.';

  static String filterSummary(String tabLabel, int count) {
    if (count == 1) return '$tabLabel · 1 alerta';
    return '$tabLabel · $count alertas';
  }
}

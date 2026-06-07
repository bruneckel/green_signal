import '../core/constants/alert_strings.dart';
import 'home_data.dart';

enum AlertTab {
  active,
  recent,
  informative;

  String get label => switch (this) {
        AlertTab.active => AlertStrings.tabActive,
        AlertTab.recent => AlertStrings.tabRecent,
        AlertTab.informative => AlertStrings.tabInformative,
      };
}

class AlertItem {
  const AlertItem({
    required this.id,
    required this.tab,
    required this.riskLevel,
    required this.title,
    required this.description,
    required this.region,
    required this.timeAgo,
  });

  final String id;
  final AlertTab tab;
  final RiskLevel riskLevel;
  final String title;
  final String description;
  final String region;
  final String timeAgo;
}

abstract final class AlertsData {
  static const mock = [
    AlertItem(
      id: 'active-1',
      tab: AlertTab.active,
      riskLevel: RiskLevel.high,
      title: 'Chuva intensa',
      description: 'Previsão de chuva forte nas próximas 6 horas.',
      region: 'Zona Norte',
      timeAgo: 'Há 10 min',
    ),
    AlertItem(
      id: 'active-2',
      tab: AlertTab.active,
      riskLevel: RiskLevel.medium,
      title: 'Calor extremo',
      description: 'Temperaturas acima de 35°C nos próximos dias.',
      region: 'Centro',
      timeAgo: 'Há 1 h',
    ),
    AlertItem(
      id: 'active-3',
      tab: AlertTab.active,
      riskLevel: RiskLevel.medium,
      title: 'Qualidade do ar moderada',
      description: 'Aumento de poluentes na atmosfera.',
      region: 'Vila Madalena',
      timeAgo: 'Há 2 h',
    ),
    AlertItem(
      id: 'recent-1',
      tab: AlertTab.recent,
      riskLevel: RiskLevel.medium,
      title: 'Vento forte',
      description: 'Rajadas de vento acima de 50 km/h encerradas.',
      region: 'Zona Leste',
      timeAgo: 'Há 5 h',
    ),
    AlertItem(
      id: 'recent-2',
      tab: AlertTab.recent,
      riskLevel: RiskLevel.low,
      title: 'Umidade baixa',
      description: 'Níveis de umidade abaixo do normal na região.',
      region: 'Zona Sul',
      timeAgo: 'Há 1 dia',
    ),
    AlertItem(
      id: 'informative-1',
      tab: AlertTab.informative,
      riskLevel: RiskLevel.low,
      title: 'Hidratação recomendada',
      description: 'Beba água com frequência em dias quentes.',
      region: 'São Paulo',
      timeAgo: 'Hoje',
    ),
    AlertItem(
      id: 'informative-2',
      tab: AlertTab.informative,
      riskLevel: RiskLevel.low,
      title: 'Boa qualidade do ar',
      description: 'Condições favoráveis para atividades ao ar livre.',
      region: 'Pinheiros',
      timeAgo: 'Hoje',
    ),
  ];
}

import 'package:flutter/material.dart';

import '../core/constants/community_strings.dart';
import '../core/theme/app_colors.dart';

enum ReportCategory {
  fire,
  flood,
  trash,
  airPollution,
  pollution,
  cleanup,
  other;

  String get label => switch (this) {
        ReportCategory.fire => CommunityStrings.typeFire,
        ReportCategory.flood => CommunityStrings.typeFlood,
        ReportCategory.trash => CommunityStrings.typeTrash,
        ReportCategory.airPollution => CommunityStrings.typeAirPollution,
        ReportCategory.pollution => CommunityStrings.categoryPollution,
        ReportCategory.cleanup => CommunityStrings.categoryCleanup,
        ReportCategory.other => CommunityStrings.typeOther,
      };

  IconData get icon => switch (this) {
        ReportCategory.fire => Icons.wb_sunny_outlined,
        ReportCategory.flood => Icons.flood_outlined,
        ReportCategory.trash => Icons.delete_outline,
        ReportCategory.airPollution => Icons.air,
        ReportCategory.pollution => Icons.factory_outlined,
        ReportCategory.cleanup => Icons.cleaning_services_outlined,
        ReportCategory.other => Icons.more_horiz,
      };

  Color get badgeColor => switch (this) {
        ReportCategory.flood || ReportCategory.fire => AppColors.riskHigh,
        ReportCategory.pollution ||
        ReportCategory.airPollution =>
          AppColors.alertWarning,
        ReportCategory.cleanup => AppColors.riskLow,
        ReportCategory.trash || ReportCategory.other => AppColors.textSecondary,
      };

  bool matchesFilter(CommunityFilter filter) => switch (filter) {
        CommunityFilter.all => true,
        CommunityFilter.flood => this == ReportCategory.flood,
        CommunityFilter.fire => this == ReportCategory.fire,
      };
}

enum CommunityFilter {
  all,
  flood,
  fire;

  String get label => switch (this) {
        CommunityFilter.all => CommunityStrings.filterAll,
        CommunityFilter.flood => CommunityStrings.filterFlood,
        CommunityFilter.fire => CommunityStrings.filterFire,
      };
}

class CommunityReport {
  const CommunityReport({
    required this.id,
    required this.authorName,
    required this.category,
    required this.description,
    required this.timeAgo,
    required this.engagement,
    required this.neighborhood,
  });

  final String id;
  final String authorName;
  final ReportCategory category;
  final String description;
  final String timeAgo;
  final String engagement;
  final String neighborhood;
}

abstract final class CommunityReportsData {
  static const mock = [
    CommunityReport(
      id: 'report-1',
      authorName: 'Maria R.',
      category: ReportCategory.flood,
      description:
          'Rua das Flores alagada após as últimas chuvas. Trânsito bloqueado.',
      timeAgo: 'Há 30 min',
      engagement: '12 confirmações',
      neighborhood: 'Centro',
    ),
    CommunityReport(
      id: 'report-2',
      authorName: 'João C.',
      category: ReportCategory.pollution,
      description:
          'Fumaça preta saindo de fábrica na região. Cheiro forte no bairro.',
      timeAgo: 'Há 1 h',
      engagement: '28 curtidas',
      neighborhood: 'Mooca',
    ),
    CommunityReport(
      id: 'report-3',
      authorName: 'Ana P.',
      category: ReportCategory.cleanup,
      description:
          'Mutirão de limpeza nos parques da região. Venha participar!',
      timeAgo: 'Há 3 h',
      engagement: '45 apoios',
      neighborhood: 'Alto de Pinheiros',
    ),
    CommunityReport(
      id: 'report-4',
      authorName: 'Carlos M.',
      category: ReportCategory.fire,
      description:
          'Foco de incêndio em área de mata no limite do bairro.',
      timeAgo: 'Há 5 h',
      engagement: '8 confirmações',
      neighborhood: 'Vila Madalena',
    ),
  ];
}

/// Categories shown in the new report occurrence type grid.
const newReportCategories = [
  ReportCategory.fire,
  ReportCategory.flood,
  ReportCategory.trash,
  ReportCategory.airPollution,
  ReportCategory.other,
];

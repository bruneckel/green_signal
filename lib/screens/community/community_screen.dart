import 'package:flutter/material.dart';

import '../../core/constants/community_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/community_report.dart';
import '../../widgets/community/community_filter_chips.dart';
import '../../widgets/community/community_location_selector.dart';
import '../../widgets/community/community_report_card.dart';
import '../../widgets/community/community_screen_header.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key, this.reports = CommunityReportsData.mock});

  final List<CommunityReport> reports;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  CommunityFilter _selectedFilter = CommunityFilter.all;

  List<CommunityReport> get _filteredReports => widget.reports
      .where((report) => report.category.matchesFilter(_selectedFilter))
      .toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredReports;

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            const CommunityScreenHeader(),
            const CommunityLocationSelector(),
            CommunityFilterChips(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) =>
                  setState(() => _selectedFilter = filter),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        CommunityStrings.emptyList,
                        style: AppTypography.bodySecondary.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        0,
                        AppSpacing.screenHorizontal,
                        AppSpacing.lg,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        return CommunityReportCard(report: filtered[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

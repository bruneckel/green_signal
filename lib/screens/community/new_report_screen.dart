import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/community_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/form_utils.dart';
import '../../models/community_report.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/community/occurrence_type_grid.dart';
import '../../widgets/community/photo_upload_slots.dart';
import '../../widgets/community/report_map_preview.dart';
import '../../widgets/primary_button.dart';

class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key});

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  ReportCategory? _selectedCategory;
  String? _categoryError;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectCategory(ReportCategory category) {
    setState(() {
      _selectedCategory = category;
      _categoryError = null;
    });
  }

  void _submit() {
    unfocus(context);

    final categoryValid = _selectedCategory != null;
    if (!categoryValid) {
      setState(() {
        _categoryError = CommunityStrings.selectTypeError;
      });
    }

    if (!_formKey.currentState!.validate() || !categoryValid) return;

    showAppSnackBar(context, CommunityStrings.reportSuccess);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xs,
                  AppSpacing.sm,
                  AppSpacing.screenHorizontal,
                  0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.textPrimary,
                    ),
                    const Expanded(
                      child: Column(
                        children: [
                          Text(
                            CommunityStrings.newReportTitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.appBarTitle,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            CommunityStrings.newReportSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.lg,
                    AppSpacing.screenHorizontal,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        CommunityStrings.occurrenceTypeLabel,
                        style: AppTypography.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      OccurrenceTypeGrid(
                        selectedCategory: _selectedCategory,
                        onCategorySelected: _selectCategory,
                      ),
                      if (_categoryError != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _categoryError!,
                          style: const TextStyle(
                            color: AppColors.riskHigh,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        CommunityStrings.descriptionLabel,
                        style: AppTypography.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        controller: _descriptionController,
                        hintText: CommunityStrings.descriptionHint,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 4,
                        minLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return CommunityStrings.descriptionRequiredError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        CommunityStrings.locationLabel,
                        style: AppTypography.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Material(
                        color: AppColors.surfaceMuted,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.borderRadius),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: InkWell(
                          onTap: () => showAppSnackBar(
                            context,
                            AppStrings.featureComingSoon,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.borderRadius),
                          child: SizedBox(
                            height: AppSpacing.inputHeight,
                            child: Row(
                              children: [
                                const SizedBox(width: AppSpacing.md),
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  CommunityStrings.locationHint,
                                  style: AppTypography.bodySecondary.copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const ReportMapPreview(),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        CommunityStrings.photosLabel,
                        style: AppTypography.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const PhotoUploadSlots(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  0,
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                ),
                child: PrimaryButton(
                  label: CommunityStrings.submitReport,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

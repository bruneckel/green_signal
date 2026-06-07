import 'package:flutter/material.dart';

import '../../core/constants/location_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/environment/unified_location_resolver.dart';
import '../../services/location/ibge_localities_client.dart';

Future<void> showCityPickerSheet(
  BuildContext context, {
  required UnifiedLocationResolver locationResolver,
  required AuthRepository authRepository,
  required IbgeLocalitiesClient ibgeClient,
  required String profileCityLabel,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return _CityPickerSheet(
        locationResolver: locationResolver,
        authRepository: authRepository,
        ibgeClient: ibgeClient,
        profileCityLabel: profileCityLabel,
      );
    },
  );
}

class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet({
    required this.locationResolver,
    required this.authRepository,
    required this.ibgeClient,
    required this.profileCityLabel,
  });

  final UnifiedLocationResolver locationResolver;
  final AuthRepository authRepository;
  final IbgeLocalitiesClient ibgeClient;
  final String profileCityLabel;

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  final _searchController = TextEditingController();

  List<IbgeState> _states = const [];
  List<IbgeMunicipality> _municipalities = const [];
  IbgeState? _selectedState;
  bool _isLoadingStates = true;
  bool _isLoadingMunicipalities = false;
  bool _isSelectingCity = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStates() async {
    try {
      final states = await widget.ibgeClient.fetchStates();
      if (!mounted) return;
      setState(() {
        _states = states;
        _isLoadingStates = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingStates = false;
        _errorMessage = LocationStrings.loadError;
      });
    }
  }

  Future<void> _loadMunicipalities(IbgeState state) async {
    setState(() {
      _selectedState = state;
      _isLoadingMunicipalities = true;
      _errorMessage = null;
      _searchController.clear();
    });

    try {
      final municipalities =
          await widget.ibgeClient.fetchMunicipalities(state.sigla);
      if (!mounted) return;
      setState(() {
        _municipalities = municipalities;
        _isLoadingMunicipalities = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingMunicipalities = false;
        _errorMessage = LocationStrings.loadError;
      });
    }
  }

  Future<void> _selectMunicipality(IbgeMunicipality municipality) async {
    final userEmail = widget.authRepository.currentUser?.email;
    if (userEmail == null || _selectedState == null) return;

    setState(() {
      _isSelectingCity = true;
      _errorMessage = null;
    });

    try {
      await widget.locationResolver.setExploredCity(
        city: municipality.nome,
        state: _selectedState!.sigla,
        userEmail: userEmail,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSelectingCity = false;
        _errorMessage = LocationStrings.geocodeError;
      });
    }
  }

  Future<void> _useProfileCity() async {
    final userEmail = widget.authRepository.currentUser?.email;
    if (userEmail == null) return;

    await widget.locationResolver.clearExploredCity(userEmail);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  List<IbgeMunicipality> get _filteredMunicipalities {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _municipalities;
    return _municipalities
        .where((m) => m.nome.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                ),
                child: Text(
                  LocationStrings.pickerTitle,
                  style: AppTypography.sectionTitle,
                ),
              ),
              if (widget.locationResolver.isExploring)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  leading: const Icon(Icons.home_outlined),
                  title: Text(LocationStrings.useMyCity),
                  subtitle: Text(widget.profileCityLabel),
                  onTap: _isSelectingCity ? null : _useProfileCity,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: _isLoadingStates
                    ? const LinearProgressIndicator()
                    : DropdownButtonFormField<IbgeState>(
                        initialValue: _selectedState,
                        decoration: const InputDecoration(
                          labelText: LocationStrings.stateLabel,
                        ),
                        items: _states
                            .map(
                              (state) => DropdownMenuItem(
                                value: state,
                                child: Text('${state.nome} (${state.sigla})'),
                              ),
                            )
                            .toList(),
                        onChanged: _isSelectingCity
                            ? null
                            : (state) {
                                if (state != null) {
                                  _loadMunicipalities(state);
                                }
                              },
                      ),
              ),
              if (_selectedState != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.md,
                    AppSpacing.screenHorizontal,
                    AppSpacing.sm,
                  ),
                  child: TextField(
                    controller: _searchController,
                    enabled: !_isSelectingCity,
                    decoration: const InputDecoration(
                      hintText: LocationStrings.searchCityHint,
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.riskHigh),
                  ),
                ),
              Expanded(
                child: _buildMunicipalityList(),
              ),
              if (_isSelectingCity)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMunicipalityList() {
    if (_selectedState == null) {
      return const SizedBox.shrink();
    }

    if (_isLoadingMunicipalities) {
      return const Center(child: CircularProgressIndicator());
    }

    final municipalities = _filteredMunicipalities;
    if (municipalities.isEmpty) {
      return Center(
        child: Text(
          LocationStrings.searchCityHint,
          style: AppTypography.bodySecondary,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
      ),
      itemCount: municipalities.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final municipality = municipalities[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(municipality.nome),
          onTap: _isSelectingCity
              ? null
              : () => _selectMunicipality(municipality),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/constants/map_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/map_layer_data.dart';
import '../../widgets/map/map_legend.dart';
import '../../widgets/shared/inline_error_banner.dart';

class MapScreenFooter extends StatelessWidget {
  const MapScreenFooter({
    super.key,
    required this.layer,
    required this.hasError,
    required this.isEmpty,
    required this.isLoading,
    required this.pointsEmpty,
    required this.hotspotMarkersEmpty,
  });

  final MapLayer layer;
  final bool hasError;
  final bool isEmpty;
  final bool isLoading;
  final bool pointsEmpty;
  final bool hotspotMarkersEmpty;

  String? get _emptyMessage {
    if (!isEmpty || isLoading) return null;
    return switch (layer) {
      MapLayer.rain => MapStrings.noRainInRegion,
      MapLayer.hotspots => MapStrings.noHotspotsInRegion,
      MapLayer.temperature => MapStrings.noTemperatureInRegion,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final emptyMessage = _emptyMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasError && pointsEmpty && hotspotMarkersEmpty)
          InlineErrorBanner(message: MapStrings.loadError),
        if (emptyMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: AppTypography.bodySecondary.copyWith(fontSize: 13),
            ),
          ),
        MapLegend(layer: layer),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            0,
            AppSpacing.screenHorizontal,
            AppSpacing.sm,
          ),
          child: Text(
            MapStrings.attribution,
            textAlign: TextAlign.center,
            style: AppTypography.bodySecondary.copyWith(fontSize: 11),
          ),
        ),
      ],
    );
  }
}

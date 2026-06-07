import 'package:flutter/material.dart';

import '../../core/constants/map_config.dart';
import '../../core/constants/map_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/map_layer_data.dart';

class MapLegend extends StatelessWidget {
  const MapLegend({super.key, required this.layer});

  final MapLayer layer;

  String? _subtitleFor(MapLayer layer) {
    return switch (layer) {
      MapLayer.airQuality => MapStrings.legendAirSubtitle,
      MapLayer.temperature =>
        '${MapConfig.tempScaleMinC.toInt()}°C — ${MapConfig.tempScaleMaxC.toInt()}°C',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final style = layer.style;
    final gradientColors = MapLayerData.gradientColors(style.gradient);
    final subtitle = _subtitleFor(layer);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(colors: gradientColors),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                style.legendLow,
                style: AppTypography.bodySecondary.copyWith(fontSize: 13),
              ),
              Text(
                style.legendHigh,
                style: AppTypography.bodySecondary.copyWith(fontSize: 13),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.bodySecondary.copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

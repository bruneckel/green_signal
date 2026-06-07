import 'package:flutter/material.dart';

import '../../core/constants/map_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/map_layer_data.dart';
import '../../widgets/map/environmental_map_view.dart';
import '../../widgets/map/map_filter_chips.dart';
import '../../widgets/map/map_legend.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapLayer _selectedLayer = MapLayer.airQuality;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            const Text(
              MapStrings.mapTitle,
              textAlign: TextAlign.center,
              style: AppTypography.appBarTitle,
            ),
            const SizedBox(height: AppSpacing.md),
            MapFilterChips(
              selectedLayer: _selectedLayer,
              onLayerChanged: (layer) => setState(() => _selectedLayer = layer),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: EnvironmentalMapView(layer: _selectedLayer),
            ),
            const MapLegend(),
          ],
        ),
      ),
    );
  }
}

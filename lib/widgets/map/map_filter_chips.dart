import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/map_layer_data.dart';

class MapFilterChips extends StatelessWidget {
  const MapFilterChips({
    super.key,
    required this.selectedLayer,
    required this.onLayerChanged,
  });

  final MapLayer selectedLayer;
  final ValueChanged<MapLayer> onLayerChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Row(
        children: MapLayer.values.map((layer) {
          final isSelected = layer == selectedLayer;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Material(
              color: isSelected ? AppColors.textPrimary : AppColors.background,
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? AppColors.textPrimary : AppColors.border,
                ),
              ),
              child: InkWell(
                onTap: () => onLayerChanged(layer),
                customBorder: const StadiumBorder(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(
                    layer.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../domain/search_models.dart';

class GlassSearchBarWidget extends StatelessWidget {
  const GlassSearchBarWidget({
    required this.onChanged,
    required this.activeFilters,
    required this.onFilterToggle,
    this.controller,
    this.isLoading = false,
    super.key,
  });

  final TextEditingController? controller;
  final ValueChanged<String> onChanged;
  final Set<SearchFilter> activeFilters;
  final ValueChanged<SearchFilter> onFilterToggle;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      glowColor: AppColors.primary,
      borderColor: AppColors.primary.withAlpha(70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'ابحث بالألمانية أو العربية…',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(13),
                      child: SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _filterChip('أفعال', SearchFilter.verbs, AppColors.primary),
              _filterChip('أسماء', SearchFilter.nouns, AppColors.secondary),
              _filterChip('der', SearchFilter.der, AppColors.articleDer),
              _filterChip('die', SearchFilter.die, AppColors.articleDie),
              _filterChip('das', SearchFilter.das, AppColors.articleDas),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, SearchFilter filter, Color color) {
    final selected = activeFilters.contains(filter);
    return FilterChip(
      label: Text(
        label,
        style: AppTypography.label.copyWith(
          color: selected ? color : null,
          fontWeight: FontWeight.w800,
        ),
      ),
      selected: selected,
      onSelected: (_) => onFilterToggle(filter),
      selectedColor: color.withAlpha(24),
      side: BorderSide(color: color.withAlpha(selected ? 150 : 70)),
      checkmarkColor: color,
    );
  }
}

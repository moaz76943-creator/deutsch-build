import 'package:flutter/material.dart';
import '../contracts/content_state_contract.dart';
import '../../language_bidi_helper.dart';
import '../../../design_system/app_typography.dart';
import '../tokens/app_spacing.dart';

class ResilientMediaPlaceholder extends StatelessWidget
    implements OptionalContentContract {
  @override
  final String semanticLabel;
  @override
  final String? bcp47LanguageCode;
  @override
  final String fallbackText;

  final IconData fallbackIcon;
  final double minHeight;

  const ResilientMediaPlaceholder({
    super.key,
    required this.semanticLabel,
    this.bcp47LanguageCode,
    required this.fallbackText,
    this.fallbackIcon = Icons.image_not_supported_outlined,
    this.minHeight = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = bcp47LanguageCode != null
        ? LanguageBiDiHelper.getDirection(bcp47LanguageCode!)
        : Directionality.of(context);

    return Semantics(
      label: semanticLabel,
      image: true,
      child: Container(
        constraints:
            BoxConstraints(minHeight: minHeight, minWidth: double.infinity),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadiusSm),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                fallbackIcon,
                size: 32,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.sm),
              Directionality(
                textDirection: direction,
                child: Text(
                  fallbackText,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: bcp47LanguageCode != null
                        ? LanguageBiDiHelper.getLineHeight(bcp47LanguageCode!)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

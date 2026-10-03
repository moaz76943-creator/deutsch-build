import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_typography.dart';

final class VisualColorContracts {
  const VisualColorContracts();

  Color primary(Brightness brightness) =>
      brightness == Brightness.dark ? AppColors.primaryDark : AppColors.primary;

  Color secondary(Brightness brightness) => brightness == Brightness.dark
      ? AppColors.secondaryDark
      : AppColors.secondary;

  Color tertiary(Brightness brightness) => brightness == Brightness.dark
      ? AppColors.tertiaryDark
      : AppColors.tertiary;

  Color background(Brightness brightness) => brightness == Brightness.dark
      ? AppColors.darkBackground
      : AppColors.lightBackground;

  Color surface(Brightness brightness) => brightness == Brightness.dark
      ? AppColors.darkSurface
      : AppColors.lightSurface;

  Color glassBorder(Brightness brightness) => brightness == Brightness.dark
      ? AppColors.glassBorderDark
      : AppColors.glassBorderLight;

  LinearGradient glassGradient(Brightness brightness) =>
      brightness == Brightness.dark
          ? AppColors.glassDarkGradient
          : AppColors.glassLightGradient;

  Color get articleDer => AppColors.articleDer;
  Color get articleDie => AppColors.articleDie;
  Color get articleDas => AppColors.articleDas;
  Color get articleOther => AppColors.articleOther;
  Color get streak => AppColors.streak;
  Color get xp => AppColors.xp;
  Color get achievement => AppColors.achievement;
  Color get mastery => AppColors.mastery;
}

final class VisualTypographyContracts {
  const VisualTypographyContracts();

  TextStyle get display => AppTypography.display;
  TextStyle get title => AppTypography.title;
  TextStyle get body => AppTypography.body;
  TextStyle get label => AppTypography.label;

  TextDirection directionFor(String languageCode) =>
      AppTextDirection.forLanguageCode(languageCode);
}

import 'package:flutter/material.dart';

abstract final class HousingDesignTokens {
  static const double spaceXs = 6;
  static const double spaceS = 10;
  static const double spaceM = 14;
  static const double spaceL = 18;
  static const double spaceXl = 28;

  static const double cardRadius = 24;
  static const double compactCardRadius = 20;
  static const double iconS = 20;
  static const double iconM = 28;
  static const double quickActionMinWidth = 156;

  static const EdgeInsetsDirectional screenPadding =
      EdgeInsetsDirectional.fromSTEB(spaceM, spaceM, spaceM, spaceXl);

  static const EdgeInsets cardPadding = EdgeInsets.all(spaceM);

  static const EdgeInsets compactCardPadding =
      EdgeInsets.symmetric(horizontal: spaceM, vertical: spaceS);
}

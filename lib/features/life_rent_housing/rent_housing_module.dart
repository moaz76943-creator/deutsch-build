import 'package:flutter/widgets.dart';

import 'rent_housing_screen.dart';

abstract final class RentHousingModule {
  static const String id = 'life_rent_housing';
  static const String routeName = '/life/rent-housing';
  static const String titleDe = 'Wohnen & Miete';
  static const String titleAr = 'السكن والإيجار';

  static Widget build() => const RentHousingMasterHub();
}

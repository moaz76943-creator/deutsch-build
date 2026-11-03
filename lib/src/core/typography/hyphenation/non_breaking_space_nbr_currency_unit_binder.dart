/// Task 1247: Binds numbers to units and currency with U+00A0 non-breaking spaces
class NonBreakingSpaceBinder {
  String bindUnits(String text) => text.replaceAll(' €', '\u00A0€').replaceAll(' km', '\u00A0km');
}

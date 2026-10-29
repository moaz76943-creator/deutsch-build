import 'package:flutter/foundation.dart';

enum ResponsiveWindowClass { compact, medium, expanded, wide }

enum ResponsiveNavigationPresentation {
  bottomBar,
  navigationRail,
  navigationDrawer,
}

@immutable
final class ResponsiveBreakpoints {
  const ResponsiveBreakpoints({
    this.compactMax = 599,
    this.mediumMax = 839,
    this.expandedMax = 1199,
  })  : assert(compactMax >= 0),
        assert(mediumMax > compactMax),
        assert(expandedMax > mediumMax);

  final double compactMax;
  final double mediumMax;
  final double expandedMax;

  ResponsiveWindowClass classify(double width) {
    if (!width.isFinite || width < 0) {
      throw ArgumentError.value(
        width,
        'width',
        'Responsive width must be finite and non-negative.',
      );
    }
    if (width <= compactMax) return ResponsiveWindowClass.compact;
    if (width <= mediumMax) return ResponsiveWindowClass.medium;
    if (width <= expandedMax) return ResponsiveWindowClass.expanded;
    return ResponsiveWindowClass.wide;
  }

  ResponsiveNavigationPresentation navigationFor(
    ResponsiveWindowClass windowClass,
  ) =>
      switch (windowClass) {
        ResponsiveWindowClass.compact =>
          ResponsiveNavigationPresentation.bottomBar,
        ResponsiveWindowClass.medium =>
          ResponsiveNavigationPresentation.navigationRail,
        ResponsiveWindowClass.expanded =>
          ResponsiveNavigationPresentation.navigationRail,
        ResponsiveWindowClass.wide =>
          ResponsiveNavigationPresentation.navigationDrawer,
      };

  int columnsFor(ResponsiveWindowClass windowClass) => switch (windowClass) {
        ResponsiveWindowClass.compact => 1,
        ResponsiveWindowClass.medium => 2,
        ResponsiveWindowClass.expanded => 3,
        ResponsiveWindowClass.wide => 4,
      };

  double horizontalPaddingFor(ResponsiveWindowClass windowClass) =>
      switch (windowClass) {
        ResponsiveWindowClass.compact => 16,
        ResponsiveWindowClass.medium => 24,
        ResponsiveWindowClass.expanded => 32,
        ResponsiveWindowClass.wide => 40,
      };

  double maxContentWidthFor(ResponsiveWindowClass windowClass) =>
      switch (windowClass) {
        ResponsiveWindowClass.compact => 599,
        ResponsiveWindowClass.medium => 760,
        ResponsiveWindowClass.expanded => 1040,
        ResponsiveWindowClass.wide => 1200,
      };
}

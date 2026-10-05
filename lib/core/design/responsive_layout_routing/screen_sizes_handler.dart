import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'responsive_breakpoints.dart';

@immutable
final class ScreenSizeSnapshot {
  const ScreenSizeSnapshot({
    required this.width,
    required this.height,
    required this.orientation,
    required this.windowClass,
    required this.navigation,
    required this.columns,
    required this.horizontalPadding,
    required this.contentWidth,
    required this.textScaleFactor,
  });

  final double width;
  final double height;
  final Orientation orientation;
  final ResponsiveWindowClass windowClass;
  final ResponsiveNavigationPresentation navigation;
  final int columns;
  final double horizontalPadding;
  final double contentWidth;
  final double textScaleFactor;

  bool get isLandscape => orientation == Orientation.landscape;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScreenSizeSnapshot &&
          width == other.width &&
          height == other.height &&
          orientation == other.orientation &&
          windowClass == other.windowClass &&
          navigation == other.navigation &&
          columns == other.columns &&
          horizontalPadding == other.horizontalPadding &&
          contentWidth == other.contentWidth &&
          textScaleFactor == other.textScaleFactor;

  @override
  int get hashCode => Object.hash(
        width,
        height,
        orientation,
        windowClass,
        navigation,
        columns,
        horizontalPadding,
        contentWidth,
        textScaleFactor,
      );
}

final class ScreenSizesHandler {
  const ScreenSizesHandler({
    this.breakpoints = const ResponsiveBreakpoints(),
  });

  final ResponsiveBreakpoints breakpoints;

  ScreenSizeSnapshot resolve(
    BoxConstraints constraints,
    MediaQueryData media,
  ) {
    final width = constraints.hasBoundedWidth
        ? math.max(0.0, constraints.maxWidth).toDouble()
        : media.size.width;
    final height = constraints.hasBoundedHeight
        ? math.max(0.0, constraints.maxHeight).toDouble()
        : media.size.height;
    final windowClass = breakpoints.classify(width);
    final padding = breakpoints.horizontalPaddingFor(windowClass);
    final maxContent = breakpoints.maxContentWidthFor(windowClass);
    final availableContent = math.max(0.0, width - (padding * 2)).toDouble();
    final contentWidth = math.min(availableContent, maxContent).toDouble();
    final orientation =
        width >= height ? Orientation.landscape : Orientation.portrait;

    return ScreenSizeSnapshot(
      width: width,
      height: height,
      orientation: orientation,
      windowClass: windowClass,
      navigation: breakpoints.navigationFor(windowClass),
      columns: breakpoints.columnsFor(windowClass),
      horizontalPadding: padding,
      contentWidth: contentWidth,
      textScaleFactor: media.textScaler.scale(14) / 14,
    );
  }
}

final class ResponsiveLayoutScope extends InheritedWidget {
  const ResponsiveLayoutScope({
    required this.snapshot,
    required super.child,
    super.key,
  });

  final ScreenSizeSnapshot snapshot;

  static ScreenSizeSnapshot of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ResponsiveLayoutScope>();
    assert(
      scope != null,
      'ResponsiveLayoutScope.of() called without ResponsiveLayoutHub.',
    );
    if (scope == null) {
      throw StateError(
        'ResponsiveLayoutScope requires a ResponsiveLayoutHub ancestor.',
      );
    }
    return scope.snapshot;
  }

  static ScreenSizeSnapshot? maybeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<ResponsiveLayoutScope>()
          ?.snapshot;

  @override
  bool updateShouldNotify(ResponsiveLayoutScope oldWidget) =>
      snapshot != oldWidget.snapshot;
}

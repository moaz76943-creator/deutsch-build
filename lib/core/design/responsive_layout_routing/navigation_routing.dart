import 'package:flutter/material.dart';

import 'responsive_breakpoints.dart';
import 'screen_sizes_handler.dart';

typedef ResponsiveModuleBuilder = Widget Function(
  BuildContext context,
  ResponsiveWindowClass windowClass,
);

enum ResponsiveRouteTransition { platform, fade, slideHorizontal }

@immutable
final class ResponsiveRouteDefinition {
  const ResponsiveRouteDefinition({
    required this.name,
    required this.builder,
    this.transition = ResponsiveRouteTransition.platform,
    this.allowedWindowClasses = const <ResponsiveWindowClass>{
      ResponsiveWindowClass.compact,
      ResponsiveWindowClass.medium,
      ResponsiveWindowClass.expanded,
      ResponsiveWindowClass.wide,
    },
  });

  final String name;
  final ResponsiveModuleBuilder builder;
  final ResponsiveRouteTransition transition;
  final Set<ResponsiveWindowClass> allowedWindowClasses;

  bool supports(ResponsiveWindowClass windowClass) =>
      allowedWindowClasses.contains(windowClass);
}

final class NavigationRoutingRegistry {
  NavigationRoutingRegistry({
    required Iterable<ResponsiveRouteDefinition> routes,
  }) : _routes = <String, ResponsiveRouteDefinition>{} {
    for (final route in routes) {
      _validateRouteName(route.name);
      if (_routes.containsKey(route.name)) {
        throw StateError('Duplicate responsive route: ${route.name}');
      }
      _routes[route.name] = route;
    }
  }

  final Map<String, ResponsiveRouteDefinition> _routes;

  Iterable<String> get registeredNames => _routes.keys;

  ResponsiveRouteDefinition? resolve(String? name) =>
      name == null ? null : _routes[name];

  bool contains(String name) => _routes.containsKey(name);

  Route<T> buildRoute<T>(
    RouteSettings settings,
    ResponsiveWindowClass windowClass,
  ) {
    final definition = _requireDefinition(settings.name);
    return _createRoute<T>(
      definition: definition,
      settings: settings,
      pageBuilder: (context) => _buildForClass(
        context,
        definition,
        windowClass,
      ),
    );
  }

  Route<dynamic>? buildAdaptiveRoute(RouteSettings settings) {
    final definition = resolve(settings.name);
    if (definition == null) return null;

    return _createRoute<dynamic>(
      definition: definition,
      settings: settings,
      pageBuilder: (context) {
        final snapshot = ResponsiveLayoutScope.of(context);
        return _buildForClass(
          context,
          definition,
          snapshot.windowClass,
        );
      },
    );
  }

  Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    if (!contains(routeName)) {
      throw StateError('Unregistered responsive route: $routeName');
    }
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  ResponsiveRouteDefinition _requireDefinition(String? name) {
    final definition = resolve(name);
    if (definition == null) {
      throw StateError('Unregistered responsive route: ${name ?? '<null>'}');
    }
    return definition;
  }

  Widget _buildForClass(
    BuildContext context,
    ResponsiveRouteDefinition definition,
    ResponsiveWindowClass windowClass,
  ) {
    if (!definition.supports(windowClass)) {
      return ResponsiveRouteUnavailable(
        routeName: definition.name,
        windowClass: windowClass,
      );
    }
    return definition.builder(context, windowClass);
  }

  Route<T> _createRoute<T>({
    required ResponsiveRouteDefinition definition,
    required RouteSettings settings,
    required WidgetBuilder pageBuilder,
  }) =>
      switch (definition.transition) {
        ResponsiveRouteTransition.platform => MaterialPageRoute<T>(
            settings: settings,
            builder: pageBuilder,
          ),
        ResponsiveRouteTransition.fade => PageRouteBuilder<T>(
            settings: settings,
            transitionDuration: const Duration(milliseconds: 180),
            reverseTransitionDuration: const Duration(milliseconds: 140),
            pageBuilder: (context, animation, secondaryAnimation) =>
                pageBuilder(context),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) =>
                FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
              child: child,
            ),
          ),
        ResponsiveRouteTransition.slideHorizontal => PageRouteBuilder<T>(
            settings: settings,
            transitionDuration: const Duration(milliseconds: 220),
            reverseTransitionDuration: const Duration(milliseconds: 180),
            pageBuilder: (context, animation, secondaryAnimation) =>
                pageBuilder(context),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) =>
                SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ),
              ),
              child: child,
            ),
          ),
      };

  static void _validateRouteName(String name) {
    if (name.isEmpty || !name.startsWith('/')) {
      throw ArgumentError.value(
        name,
        'name',
        'Responsive routes must start with "/".',
      );
    }
    if (name.length > 1 && name.endsWith('/')) {
      throw ArgumentError.value(
        name,
        'name',
        'Responsive routes must not end with "/".',
      );
    }
    if (name.contains('//')) {
      throw ArgumentError.value(
        name,
        'name',
        'Responsive routes must not contain empty path segments.',
      );
    }
  }
}

final class ResponsiveRouteUnavailable extends StatelessWidget {
  const ResponsiveRouteUnavailable({
    required this.routeName,
    required this.windowClass,
    super.key,
  });

  final String routeName;
  final ResponsiveWindowClass windowClass;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Semantics(
              liveRegion: true,
              label: 'Route unavailable for current layout',
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'The route $routeName is not available for the '
                  '${windowClass.name} layout.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );
}

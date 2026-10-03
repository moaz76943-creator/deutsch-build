import 'package:flutter/material.dart';

import 'navigation_routing.dart';
import 'screen_sizes_handler.dart';

final class ResponsiveLayoutHub extends StatelessWidget {
  const ResponsiveLayoutHub({
    required this.registry,
    required this.initialRoute,
    this.navigatorKey,
    this.screenSizesHandler = const ScreenSizesHandler(),
    super.key,
  });

  final NavigationRoutingRegistry registry;
  final String initialRoute;
  final GlobalKey<NavigatorState>? navigatorKey;
  final ScreenSizesHandler screenSizesHandler;

  @override
  Widget build(BuildContext context) {
    if (!registry.contains(initialRoute)) {
      throw StateError(
        'ResponsiveLayoutHub initial route is not registered: $initialRoute',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final snapshot = screenSizesHandler.resolve(constraints, media);

        return ResponsiveLayoutScope(
          snapshot: snapshot,
          child: Navigator(
            key: navigatorKey,
            initialRoute: initialRoute,
            onGenerateInitialRoutes: (navigator, routeName) {
              final route = registry.buildAdaptiveRoute(
                RouteSettings(name: routeName),
              );
              if (route == null) {
                throw StateError(
                  'ResponsiveLayoutHub could not build initial route: '
                  '$routeName',
                );
              }
              return <Route<dynamic>>[route];
            },
            onGenerateRoute: registry.buildAdaptiveRoute,
          ),
        );
      },
    );
  }
}

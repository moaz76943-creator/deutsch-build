import 'package:deutsch_bilarabi/core/design/responsive_layout_routing/navigation_routing.dart';
import 'package:deutsch_bilarabi/core/design/responsive_layout_routing/responsive_breakpoints.dart';
import 'package:deutsch_bilarabi/core/design/responsive_layout_routing/responsive_layout_hub.dart';
import 'package:deutsch_bilarabi/core/design/responsive_layout_routing/screen_sizes_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResponsiveBreakpoints', () {
    const breakpoints = ResponsiveBreakpoints();

    test('classifies exact boundaries without overlap', () {
      expect(breakpoints.classify(0), ResponsiveWindowClass.compact);
      expect(breakpoints.classify(599), ResponsiveWindowClass.compact);
      expect(breakpoints.classify(600), ResponsiveWindowClass.medium);
      expect(breakpoints.classify(839), ResponsiveWindowClass.medium);
      expect(breakpoints.classify(840), ResponsiveWindowClass.expanded);
      expect(breakpoints.classify(1199), ResponsiveWindowClass.expanded);
      expect(breakpoints.classify(1200), ResponsiveWindowClass.wide);
    });

    test('derives navigation presentation and grid density', () {
      expect(
        breakpoints.navigationFor(ResponsiveWindowClass.compact),
        ResponsiveNavigationPresentation.bottomBar,
      );
      expect(
        breakpoints.navigationFor(ResponsiveWindowClass.medium),
        ResponsiveNavigationPresentation.navigationRail,
      );
      expect(
        breakpoints.navigationFor(ResponsiveWindowClass.wide),
        ResponsiveNavigationPresentation.navigationDrawer,
      );
      expect(breakpoints.columnsFor(ResponsiveWindowClass.compact), 1);
      expect(breakpoints.columnsFor(ResponsiveWindowClass.medium), 2);
      expect(breakpoints.columnsFor(ResponsiveWindowClass.expanded), 3);
      expect(breakpoints.columnsFor(ResponsiveWindowClass.wide), 4);
    });
  });

  group('ScreenSizesHandler', () {
    const handler = ScreenSizesHandler();

    test('prefers finite layout constraints over full device width', () {
      const media = MediaQueryData(
        size: Size(1200, 900),
        textScaler: TextScaler.linear(1.25),
      );

      final snapshot = handler.resolve(
        const BoxConstraints(maxWidth: 720, maxHeight: 800),
        media,
      );

      expect(snapshot.width, 720);
      expect(snapshot.height, 800);
      expect(snapshot.windowClass, ResponsiveWindowClass.medium);
      expect(snapshot.navigation, ResponsiveNavigationPresentation.navigationRail);
      expect(snapshot.columns, 2);
      expect(snapshot.textScaleFactor, closeTo(1.25, 0.001));
    });

    test('falls back to MediaQuery when constraints are unbounded', () {
      const media = MediaQueryData(size: Size(390, 844));

      final snapshot = handler.resolve(
        const BoxConstraints(),
        media,
      );

      expect(snapshot.width, 390);
      expect(snapshot.height, 844);
      expect(snapshot.windowClass, ResponsiveWindowClass.compact);
      expect(snapshot.orientation, Orientation.portrait);
    });
  });

  group('NavigationRoutingRegistry', () {
    test('rejects malformed and duplicate route names', () {
      expect(
        () => NavigationRoutingRegistry(
          routes: <ResponsiveRouteDefinition>[
            ResponsiveRouteDefinition(
              name: 'home',
              builder: (_, __) => const SizedBox(),
            ),
          ],
        ),
        throwsArgumentError,
      );

      expect(
        () => NavigationRoutingRegistry(
          routes: <ResponsiveRouteDefinition>[
            ResponsiveRouteDefinition(
              name: '/home',
              builder: (_, __) => const SizedBox(),
            ),
            ResponsiveRouteDefinition(
              name: '/home',
              builder: (_, __) => const SizedBox(),
            ),
          ],
        ),
        throwsStateError,
      );
    });

    testWidgets('builds a registered route for the active window class', (tester) async {
      final registry = NavigationRoutingRegistry(
        routes: <ResponsiveRouteDefinition>[
          ResponsiveRouteDefinition(
            name: '/details',
            builder: (_, windowClass) => Text(windowClass.name),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final route = registry.buildRoute<void>(
                const RouteSettings(name: '/details'),
                ResponsiveWindowClass.expanded,
              );
              return Navigator(
                onGenerateInitialRoutes: (_, __) => <Route<void>>[route],
              );
            },
          ),
        ),
      );

      expect(find.text('expanded'), findsOneWidget);
    });
  });

  group('ResponsiveLayoutHub', () {
    testWidgets('routes modules using the current responsive window class', (tester) async {
      final registry = NavigationRoutingRegistry(
        routes: <ResponsiveRouteDefinition>[
          ResponsiveRouteDefinition(
            name: '/home',
            builder: (context, windowClass) => Scaffold(
              body: Column(
                children: <Widget>[
                  Text('home-${windowClass.name}'),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pushNamed('/module'),
                    child: const Text('open'),
                  ),
                ],
              ),
            ),
          ),
          ResponsiveRouteDefinition(
            name: '/module',
            transition: ResponsiveRouteTransition.fade,
            builder: (_, windowClass) => Scaffold(
              body: Text('module-${windowClass.name}'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(390, 844)),
            child: SizedBox(
              width: 390,
              height: 844,
              child: ResponsiveLayoutHub(
                registry: registry,
                initialRoute: '/home',
              ),
            ),
          ),
        ),
      );

      expect(find.text('home-compact'), findsOneWidget);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('module-compact'), findsOneWidget);
    });

    testWidgets('publishes screen metrics through ResponsiveLayoutScope', (tester) async {
      late ScreenSizeSnapshot captured;

      final registry = NavigationRoutingRegistry(
        routes: <ResponsiveRouteDefinition>[
          ResponsiveRouteDefinition(
            name: '/home',
            builder: (context, _) {
              captured = ResponsiveLayoutScope.of(context);
              return const SizedBox();
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1280, 900)),
            child: SizedBox(
              width: 1280,
              height: 900,
              child: ResponsiveLayoutHub(
                registry: registry,
                initialRoute: '/home',
              ),
            ),
          ),
        ),
      );

      expect(captured.windowClass, ResponsiveWindowClass.wide);
      expect(captured.navigation, ResponsiveNavigationPresentation.navigationDrawer);
      expect(captured.columns, 4);
      expect(captured.contentWidth, lessThanOrEqualTo(1200));
    });
  });
}

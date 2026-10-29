import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/core/ui/optimized_render_tile.dart';

void main() {
  group('OptimizedRenderTile Performance Tests', () {
    testWidgets('Wraps child in a RepaintBoundary by default to isolate paint layers', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: OptimizedRenderTile(
            child: Text('Performance Vocabulary Item'),
          ),
        ),
      );

      // Verify RepaintBoundary is active in the render tree
      expect(find.byType(RepaintBoundary), findsOneWidget);
      expect(find.text('Performance Vocabulary Item'), findsOneWidget);
    });

    testWidgets('Passes through unisolated when enableRepaintBoundary is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: OptimizedRenderTile(
            enableRepaintBoundary: false,
            child: Text('Raw Item'),
          ),
        ),
      );

      expect(find.byType(RepaintBoundary), findsNothing);
      expect(find.text('Raw Item'), findsOneWidget);
    });
  });
}

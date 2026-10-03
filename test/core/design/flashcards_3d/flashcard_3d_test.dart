import 'dart:math' as math;

import 'package:deutsch_bilarabi/core/design/flashcards_3d/flashcard_3d_animation.dart';
import 'package:deutsch_bilarabi/core/design/flashcards_3d/flashcard_3d_master_hub.dart';
import 'package:deutsch_bilarabi/core/design/flashcards_3d/flashcard_3d_models.dart';
import 'package:deutsch_bilarabi/core/design/flashcards_3d/flashcard_gesture_controller.dart';
import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/design_system/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Flashcard3DAnimationMath', () {
    const animation = Flashcard3DAnimationMath();

    test('maps progress to a full half-turn and exposes visible face', () {
      expect(animation.rotationFor(0), 0);
      expect(animation.rotationFor(.5), closeTo(math.pi / 2, .0001));
      expect(animation.rotationFor(1), closeTo(math.pi, .0001));

      expect(animation.visibleFaceFor(.49), Flashcard3DFace.front);
      expect(animation.visibleFaceFor(.51), Flashcard3DFace.back);
    });

    test('clamps animation progress and drag tilt safely', () {
      expect(animation.rotationFor(-2), 0);
      expect(animation.rotationFor(3), closeTo(math.pi, .0001));
      expect(animation.dragTiltFor(-4), closeTo(-.08, .0001));
      expect(animation.dragTiltFor(4), closeTo(.08, .0001));
    });
  });

  group('FlashcardGestureController', () {
    test('detects horizontal and vertical swipes from viewport-relative threshold', () {
      final controller = FlashcardGestureController();

      controller.beginDrag();
      controller.updateDrag(const Offset(-120, 8));
      expect(
        controller.endDrag(const Size(320, 560)),
        FlashcardSwipeDirection.left,
      );

      controller.beginDrag();
      controller.updateDrag(const Offset(4, 150));
      expect(
        controller.endDrag(const Size(320, 560)),
        FlashcardSwipeDirection.down,
      );
    });

    test('returns no swipe for short drag and resets the offset', () {
      final controller = FlashcardGestureController();

      controller.beginDrag();
      controller.updateDrag(const Offset(20, 12));
      expect(controller.endDrag(const Size(320, 560)), isNull);
      expect(controller.dragOffset, Offset.zero);
    });

    test('reports bounded drag fractions for renderer feedback', () {
      final controller = FlashcardGestureController();

      controller.beginDrag();
      controller.updateDrag(const Offset(500, -700));

      expect(controller.horizontalFraction(const Size(300, 600)), 1);
      expect(controller.verticalFraction(const Size(300, 600)), -1);
      controller.cancelDrag();
      expect(controller.dragOffset, Offset.zero);
    });
  });

  group('Flashcard3DMasterHub', () {
    const cards = <Flashcard3DData>[
      Flashcard3DData(
        id: 'haus',
        frontText: 'das Haus',
        backText: 'البيت',
        article: 'das',
      ),
      Flashcard3DData(
        id: 'lampe',
        frontText: 'die Lampe',
        backText: 'المصباح',
        article: 'die',
      ),
    ];

    testWidgets('renders canonical glass surface with explicit BiDi text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 390,
              height: 700,
              child: Flashcard3DMasterHub(cards: cards),
            ),
          ),
        ),
      );

      expect(find.byType(AppGlassCard), findsWidgets);

      final german = tester.widget<AppDirectionalText>(
        find.byWidgetPredicate(
          (widget) =>
              widget is AppDirectionalText &&
              widget.text == 'das Haus',
        ),
      );
      expect(german.languageCode, 'de');
      expect(find.text('1 / 2'), findsOneWidget);
    });

    testWidgets('tap flips the card with the 3D renderer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 390,
              height: 700,
              child: Flashcard3DMasterHub(cards: cards),
            ),
          ),
        ),
      );

      expect(find.text('das Haus'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('flashcard-gesture-surface')));
      await tester.pump(const Duration(milliseconds: 180));
      await tester.pumpAndSettle();

      expect(find.text('البيت'), findsOneWidget);
      expect(find.byType(Flashcard3DRenderer), findsOneWidget);
    });

    testWidgets('left swipe advances and right swipe goes back', (tester) async {
      final swipes = <FlashcardSwipeDirection>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 390,
              height: 700,
              child: Flashcard3DMasterHub(
                cards: cards,
                onSwipe: (direction, card, index) => swipes.add(direction),
              ),
            ),
          ),
        ),
      );

      final target = find.byKey(const ValueKey<String>('flashcard-gesture-surface'));

      await tester.drag(target, const Offset(-220, 0));
      await tester.pumpAndSettle();
      expect(find.text('die Lampe'), findsOneWidget);
      expect(swipes.last, FlashcardSwipeDirection.left);

      await tester.drag(target, const Offset(220, 0));
      await tester.pumpAndSettle();
      expect(find.text('das Haus'), findsOneWidget);
      expect(swipes.last, FlashcardSwipeDirection.right);
    });

    testWidgets('up and down swipes emit actions without changing the card', (tester) async {
      final swipes = <FlashcardSwipeDirection>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 390,
              height: 700,
              child: Flashcard3DMasterHub(
                cards: cards,
                onSwipe: (direction, card, index) => swipes.add(direction),
              ),
            ),
          ),
        ),
      );

      final target = find.byKey(const ValueKey<String>('flashcard-gesture-surface'));

      await tester.drag(target, const Offset(0, -260));
      await tester.pumpAndSettle();
      expect(find.text('das Haus'), findsOneWidget);
      expect(swipes.last, FlashcardSwipeDirection.up);

      await tester.drag(target, const Offset(0, 260));
      await tester.pumpAndSettle();
      expect(find.text('das Haus'), findsOneWidget);
      expect(swipes.last, FlashcardSwipeDirection.down);
    });
  });
}

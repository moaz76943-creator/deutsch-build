import 'package:deutsch_bilarabi/design_system/app_audio_button.dart';
import 'package:deutsch_bilarabi/design_system/app_colors.dart';
import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/design_system/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('design tokens keep the canonical light and dark palette stable', () {
    expect(AppColors.lightBackground, const Color(0xFFFFFBF5));
    expect(AppColors.darkBackground, const Color(0xFF12151A));
    expect(AppColors.primary, const Color(0xFF365AA8));
    expect(AppColors.glassLightGradient.colors.length, 2);
    expect(AppColors.glassDarkGradient.colors.length, 2);
  });

  testWidgets('AppGlassCard renders canonical glass surface and tap contract', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppGlassCard(
            key: const Key('glass'),
            onTap: () => taps++,
            child: const Text('content'),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('glass')), findsOneWidget);
    expect(find.text('content'), findsOneWidget);

    await tester.tap(find.byKey(const Key('glass')));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('AppAudioButton stays callback-only and keeps its 52px control', (
    tester,
  ) async {
    var presses = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppAudioButton(
            onPressed: () => presses++,
            semanticLabel: 'استماع',
          ),
        ),
      ),
    );

    expect(find.byType(AppAudioButton), findsOneWidget);
    await tester.tap(find.byType(AppAudioButton));
    await tester.pump();
    expect(presses, 1);

    final size = tester.getSize(find.byType(AppAudioButton));
    expect(size.width, 52);
    expect(size.height, 52);
  });

  test('direction helper keeps Arabic RTL and German LTR', () {
    expect(AppTextDirection.forLanguageCode('ar'), TextDirection.rtl);
    expect(AppTextDirection.forLanguageCode('de'), TextDirection.ltr);
  });

  test('typography is available for shared Cairo text styles', () {
    expect(AppTypography.body.fontFamily, isNotNull);
    expect(AppTypography.title.fontWeight, FontWeight.w800);
  });
}

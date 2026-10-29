import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/design_system/widgets/app_directional_text.dart';

import 'card_physics_helper.dart';

/// Screen-independent, multiscript flashcard. Review mutations stay in the session.
class FlashcardWidget extends StatelessWidget {
  final LexicalEntry entry;
  final Animation<double> animation;
  final VoidCallback? onFlip;

  const FlashcardWidget({
    super.key,
    required this.entry,
    required this.animation,
    this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final back = CardPhysicsHelper.isBackSide(animation.value);
        return Semantics(
          button: onFlip != null,
          label: 'اقلب البطاقة',
          child: GestureDetector(
            key: const Key('flashcard-toggle'),
            onTap: onFlip,
            child: Transform(
              alignment: Alignment.center,
              transform:
                  CardPhysicsHelper.compute3dFlipTransform(animation.value),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(back ? math.pi : 0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: back ? _back() : _front(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _front() => <Widget>[
        AppDirectionalText(
          entry.targetTerm,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (entry.partOfSpeech.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          AppDirectionalText(entry.partOfSpeech, textAlign: TextAlign.center),
        ],
      ];

  List<Widget> _back() => <Widget>[
        AppDirectionalText(
          entry.sourceMeaning,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (entry.targetExample.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          AppDirectionalText(entry.targetExample, textAlign: TextAlign.center),
        ],
        if (entry.sourceExampleTranslation.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          AppDirectionalText(
            entry.sourceExampleTranslation,
            textAlign: TextAlign.center,
          ),
        ],
      ];
}

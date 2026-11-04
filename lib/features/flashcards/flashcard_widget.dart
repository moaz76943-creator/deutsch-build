import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/design_system/widgets/app_directional_text.dart';

import 'card_physics_helper.dart';

/// Screen-independent, multiscript flashcard. Review mutations stay in the session.
class FlashcardWidget extends StatelessWidget {
  final LexicalEntry entry;
  final Animation<double> animation;
  final VoidCallback onFlip;

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
      builder: (context, child) {
        final transform = CardPhysicsHelper.compute3dFlipTransform(animation.value);
        final isBack = CardPhysicsHelper.isBackSide(animation.value);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: onFlip,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: isBack ? _buildBackSide() : _buildFrontSide(),
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
        const Spacer(),
        const Text('Tap to flip', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildBackSide() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(pi),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppDirectionalText(
            entry.sourceMeaning,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (entry.targetExample.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 12),
            AppDirectionalText(
              entry.targetExample,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
              forceDirection: TextDirection.ltr,
            ),
            if (entry.sourceExampleTranslation.isNotEmpty) ...[
              const SizedBox(height: 8),
              AppDirectionalText(
                entry.sourceExampleTranslation,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

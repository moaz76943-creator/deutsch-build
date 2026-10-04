import 'dart:async';

import 'package:flutter/material.dart' as material;

import '../../design_system/app_typography.dart'
    show AppTextDirection, AppTypography;
import 'life_feature_runtime.dart';

class Text extends material.StatelessWidget {
  const Text(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  final String data;
  final material.TextStyle? style;
  final material.StrutStyle? strutStyle;
  final material.TextAlign? textAlign;
  final material.TextDirection? textDirection;
  final material.Locale? locale;
  final bool? softWrap;
  final material.TextOverflow? overflow;
  final material.TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final material.TextWidthBasis? textWidthBasis;
  final material.TextHeightBehavior? textHeightBehavior;
  final material.Color? selectionColor;

  @override
  material.Widget build(material.BuildContext context) {
    final runtime = LifeFeatureRuntime.shared;
    return material.AnimatedBuilder(
      animation: runtime,
      builder: (context, _) => material.Text(
        runtime.resolveUiLiteral(data),
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      ),
    );
  }
}

class AppDirectionalText extends material.StatelessWidget {
  const AppDirectionalText(
    this.text, {
    required this.languageCode,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.speechSpeed = 1.0,
    super.key,
  });

  final String text;
  final String languageCode;
  final material.TextStyle? style;
  final material.TextAlign? textAlign;
  final int? maxLines;
  final material.TextOverflow? overflow;
  final double speechSpeed;

  @override
  material.Widget build(material.BuildContext context) {
    final runtime = LifeFeatureRuntime.shared;
    return material.AnimatedBuilder(
      animation: runtime,
      builder: (context, _) {
        final rendered = runtime.resolveDirectionalLiteral(
          text,
          languageCode: languageCode,
        );
        final canSpeak = runtime.isTargetLanguage(languageCode);

        final child = material.Directionality(
          textDirection: AppTextDirection.forLanguageCode(languageCode),
          child: material.Text(
            rendered,
            style: style ?? AppTypography.body,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          ),
        );

        if (!canSpeak || rendered.trim().isEmpty) {
          return child;
        }

        return material.Semantics(
          hint: 'Long press to pronounce this target-language text.',
          child: material.GestureDetector(
            behavior: material.HitTestBehavior.translucent,
            onLongPress: () {
              unawaited(
                _speakSafely(
                  runtime,
                  rendered,
                  languageCode,
                  speechSpeed,
                ),
              );
            },
            child: child,
          ),
        );
      },
    );
  }
}


Future<void> _speakSafely(
  LifeFeatureRuntime runtime,
  String text,
  String languageCode,
  double speed,
) async {
  try {
    await runtime.requestSpeech(
      text: text,
      languageTag: languageCode,
      speed: speed,
    );
  } on Object {
    return;
  }
}

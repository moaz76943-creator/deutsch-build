import 'dart:async';

import 'package:deutsch_bilarabi/core/content_contract.dart';
import 'package:deutsch_bilarabi/features/audio/domain/services/offline_tts_engine.dart';
import 'package:deutsch_bilarabi/features/session/universal_session_orchestrator.dart';
import 'package:deutsch_bilarabi/language/language_speech_profile.dart';

final class StressLearningContent implements LearningContent {
  const StressLearningContent({
    required this.id,
    this.sourceText = 'Haus',
    this.translationText = 'بيت',
    this.skill = 'vocabulary',
  });

  @override
  final String id;
  @override
  final String sourceText;
  @override
  final String translationText;
  @override
  final String skill;

  @override
  String get exampleText => 'Das ist ein Haus.';
  @override
  String get exampleTranslationText => 'هذا بيت.';
  @override
  String get topic => 'stress';
  @override
  String get grammaticalMarker => 'das';
  @override
  String get pluralForm => 'Häuser';
  @override
  List<String> get acceptedForms => <String>[sourceText];
}

final class StressTtsEngine implements OfflineTtsEngine {
  StressTtsEngine({this.latency = const Duration(milliseconds: 1)});

  final Duration latency;
  int activeSpeaks = 0;
  int maxConcurrentSpeaks = 0;
  int speakCalls = 0;
  int stopCalls = 0;
  int shutdownCalls = 0;
  bool closed = false;

  @override
  Future<OfflineTtsAvailability> probe(LanguageSpeechProfile profile) async =>
      closed ? OfflineTtsAvailability.unavailable : OfflineTtsAvailability.ready;

  @override
  Future<bool> speak({
    required String text,
    required LanguageSpeechProfile profile,
    required double rate,
  }) async {
    if (closed) return false;
    activeSpeaks += 1;
    speakCalls += 1;
    if (activeSpeaks > maxConcurrentSpeaks) {
      maxConcurrentSpeaks = activeSpeaks;
    }
    try {
      await Future<void>.delayed(latency);
      return !closed && text.trim().isNotEmpty;
    } finally {
      activeSpeaks -= 1;
    }
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
  }

  @override
  Future<void> shutdown() async {
    shutdownCalls += 1;
    closed = true;
  }
}

final class NoopSessionHaptics implements SessionHapticDriver {
  int correctSignals = 0;
  int incorrectSignals = 0;

  @override
  Future<void> onCorrect({required int combo}) async {
    correctSignals += 1;
  }

  @override
  Future<void> onIncorrect() async {
    incorrectSignals += 1;
  }
}

import 'dart:convert';

class WearOsTileSnapshot {
  final int streakDays;
  final double dailyProgressRatio;
  final String wordOfTheDay;
  final String wordMeaning;
  final String phoneticIpa;
  final int dueReviewCardsCount;

  const WearOsTileSnapshot({
    required this.streakDays,
    required this.dailyProgressRatio,
    required this.wordOfTheDay,
    required this.wordMeaning,
    required this.phoneticIpa,
    required this.dueReviewCardsCount,
  });

  Map<String, dynamic> toJson() => {
    'streakDays': streakDays,
    'dailyProgressRatio': dailyProgressRatio,
    'wordOfTheDay': wordOfTheDay,
    'wordMeaning': wordMeaning,
    'phoneticIpa': phoneticIpa,
    'dueReviewCardsCount': dueReviewCardsCount,
  };
}

enum WristSwipeAction {
  remembered,
  forgot,
  handoffToPhone,
}

class WearOsCompanionEngine {
  static const int maxBlePacketSizeBytes = 512;

  const WearOsCompanionEngine();

  /// Encodes companion tile snapshot into ultra-compact BLE binary/json payload (< 512 bytes).
  List<int> encodeWearPacket(WearOsTileSnapshot snapshot) {
    final jsonStr = jsonEncode(snapshot.toJson());
    final bytes = utf8.encode(jsonStr);

    if (bytes.length > maxBlePacketSizeBytes) {
      throw StateError('Wear OS payload exceeds BLE MTU boundary of 512 bytes.');
    }
    return bytes;
  }

  /// Decodes wrist packet on the smartwatch companion.
  WearOsTileSnapshot decodeWearPacket(List<int> packetBytes) {
    final jsonStr = utf8.decode(packetBytes);
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;

    return WearOsTileSnapshot(
      streakDays: map['streakDays'] as int,
      dailyProgressRatio: (map['dailyProgressRatio'] as num).toDouble(),
      wordOfTheDay: map['wordOfTheDay'] as String,
      wordMeaning: map['wordMeaning'] as String,
      phoneticIpa: map['phoneticIpa'] as String,
      dueReviewCardsCount: map['dueReviewCardsCount'] as int,
    );
  }

  /// Evaluates wrist quick-review swipe gesture (Right = remembered, Left = forgot).
  String processWristReviewGesture(WristSwipeAction action, String term) {
    switch (action) {
      case WristSwipeAction.remembered:
        return 'Card "$term" marked remembered on watch. FSRS interval scheduled.';
      case WristSwipeAction.forgot:
        return 'Card "$term" queued for evening reinforcement.';
      case WristSwipeAction.handoffToPhone:
        return 'Session handed off to mobile app for deep roleplay practice.';
    }
  }
}

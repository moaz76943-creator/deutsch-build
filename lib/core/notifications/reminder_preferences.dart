class ReminderPreferences {
  final bool isOptedIn;
  final int preferredHour;
  final int quietHourStart;
  final int quietHourEnd;

  const ReminderPreferences({
    this.isOptedIn = false,
    this.preferredHour = 18,
    this.quietHourStart = 22,
    this.quietHourEnd = 8,
  });

  ReminderPreferences copyWith({
    bool? isOptedIn,
    int? preferredHour,
    int? quietHourStart,
    int? quietHourEnd,
  }) {
    return ReminderPreferences(
      isOptedIn: isOptedIn ?? this.isOptedIn,
      preferredHour: preferredHour ?? this.preferredHour,
      quietHourStart: quietHourStart ?? this.quietHourStart,
      quietHourEnd: quietHourEnd ?? this.quietHourEnd,
    );
  }
}

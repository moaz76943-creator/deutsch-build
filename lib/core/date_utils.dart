extension LocalNormalizedDate on DateTime {
  /// Converts the date's local representation to UTC, retaining the exact
  /// local year, month, and day while setting time to midnight. This allows
  /// DST-safe date comparisons (e.g. difference in days) across midnight boundaries.
  DateTime get toUtcMidnight {
    final local = toLocal();
    return DateTime.utc(local.year, local.month, local.day);
  }

  /// Converts the date's local representation to UTC, retaining the exact
  /// local year, month, day, and time. This allows safe, constant-interval
  /// time comparisons without local DST skips impacting difference calculations.
  DateTime get toUtcNominal {
    final local = toLocal();
    return DateTime.utc(
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
      local.second,
      local.millisecond,
    );
  }
}

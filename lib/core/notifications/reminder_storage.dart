import 'dart:convert';
import 'dart:io';

abstract class ReminderStorage {
  Future<void> saveNextReminder(DateTime? time);
  Future<DateTime?> getNextReminder();
}

class InMemoryReminderStorage implements ReminderStorage {
  DateTime? _nextReminder;

  @override
  Future<void> saveNextReminder(DateTime? time) async {
    _nextReminder = time;
  }

  @override
  Future<DateTime?> getNextReminder() async {
    return _nextReminder;
  }
}

class FileReminderStorage implements ReminderStorage {
  final File _file;

  FileReminderStorage(String filePath) : _file = File(filePath);

  @override
  Future<void> saveNextReminder(DateTime? time) async {
    if (time == null) {
      if (await _file.exists()) {
        await _file.delete();
      }
      return;
    }
    await _file
        .writeAsString(jsonEncode({'nextReminder': time.toIso8601String()}));
  }

  @override
  Future<DateTime?> getNextReminder() async {
    if (!(await _file.exists())) return null;
    try {
      final content = await _file.readAsString();
      final data = jsonDecode(content);
      if (data != null && data is Map<String, dynamic>) {
        if (data['nextReminder'] != null && data['nextReminder'] is String) {
          return DateTime.parse(data['nextReminder'] as String);
        }
      }
    } catch (_) {
      // Return null on parsing errors
    }
    return null;
  }
}

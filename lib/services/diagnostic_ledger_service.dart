import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Best-effort, device-local FIFO journal. Never transmits diagnostic data.
/// Writes are serialized and the complete UTF-8 file is bounded to 2 MiB.
class DiagnosticLedgerService {
  DiagnosticLedgerService({Directory? cacheDirectory})
      : _cacheDirectory = cacheDirectory;

  static const int maximumBytes = 2 * 1024 * 1024;
  static final DiagnosticLedgerService instance = DiagnosticLedgerService();

  final Directory? _cacheDirectory;
  Future<void> _pending = Future<void>.value();

  Future<File> _journal() async {
    final root = _cacheDirectory ?? await getTemporaryDirectory();
    await root.create(recursive: true);
    return File(p.join(root.path, 'sqlite_diagnostics.jsonl'));
  }

  /// Records only a category, language code and exception description.
  /// Callers must not pass dictionary content or other personal data.
  Future<void> record({
    required String category,
    required String languageCode,
    required Object error,
  }) {
    final completer = Completer<void>();
    _pending = _pending.then((_) async {
      try {
        final file = await _journal();
        final line = jsonEncode(<String, String>{
          'time': DateTime.now().toUtc().toIso8601String(),
          'category': category,
          'language': languageCode,
          'error': error.toString(),
        });
        // Keep a single record strictly below the file cap.
        var bytes = utf8.encode('$line\n');
        if (bytes.length > maximumBytes ~/ 4) {
          bytes = utf8.encode('${jsonEncode(<String, String>{
                'time': DateTime.now().toUtc().toIso8601String(),
                'category': category,
                'language': languageCode,
                'error': 'Error description exceeds the offline ledger limit',
              })}\n');
        }
        final existing =
            await file.exists() ? await file.readAsBytes() : <int>[];
        if (existing.length + bytes.length <= maximumBytes) {
          await file.writeAsBytes(<int>[...existing, ...bytes], flush: true);
        } else {
          // Discard oldest COMPLETE records; never split a UTF-8 sequence.
          final old = utf8.decode(existing, allowMalformed: true).split('\n');
          final retained = <String>[];
          var used = bytes.length;
          for (final entry in old.reversed) {
            if (entry.isEmpty) continue;
            final length = utf8.encode('$entry\n').length;
            if (used + length > maximumBytes) break;
            retained.add(entry);
            used += length;
          }
          final data = utf8.encode(
            '${retained.reversed.join('\n')}${retained.isEmpty ? '' : '\n'}',
          );
          final temporary = File('${file.path}.tmp');
          await temporary.writeAsBytes(<int>[...data, ...bytes], flush: true);
          // Android/POSIX rename replaces the old file atomically.
          await temporary.rename(file.path);
        }
      } catch (_) {
        // A failure in diagnostics must never fail a database operation.
      } finally {
        completer.complete();
      }
    });
    return completer.future;
  }

  /// The returned cache file can be shared using the app's existing UI.
  Future<File> exportFile() async {
    await _pending;
    final file = await _journal();
    if (!await file.exists()) await file.writeAsString('');
    // Repair oversized legacy files without ever exporting more than the cap.
    if (await file.length() > maximumBytes) {
      final bytes = await file.readAsBytes();
      final cut = math.max(0, bytes.length - maximumBytes);
      final suffix = utf8.decode(bytes.sublist(cut), allowMalformed: true);
      final start = suffix.indexOf('\n');
      final safe = start < 0 ? '' : suffix.substring(start + 1);
      await file.writeAsString(safe, flush: true);
    }
    return file;
  }
}

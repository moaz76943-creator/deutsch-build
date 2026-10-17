import 'dart:async';

import 'package:sqflite/sqflite.dart';

/// Cross-references shared concept IDs across currently open offline packs.
///
/// The pack owner must register only verified, installed SQLite connections.
/// This service deliberately does not open, close, download, or discover packs:
/// DatabaseService keeps its connection cache private, and opening new packs
/// here would violate both the latency budget and connection ownership.
///
/// All queries are asynchronous and the returned map is a frozen snapshot.
/// SQLite operations already dispatched cannot be cancelled when time expires.
class ConceptBridgeService {
  ConceptBridgeService({
    Map<String, Database> openPackConnections = const <String, Database>{},
  }) {
    for (final entry in openPackConnections.entries) {
      registerOpenPack(entry.key, entry.value);
    }
  }

  static const Duration lookupBudget = Duration(milliseconds: 50);

  final Map<String, Database> _connections = <String, Database>{};

  /// Register an already-open database belonging to an installed language pack.
  /// The caller retains ownership of this connection and its lifetime.
  void registerOpenPack(String languageCode, Database connection) {
    _connections[_normalizeLanguage(languageCode)] = connection;
  }

  /// Unregister when a pack is closed, evicted or uninstalled.
  ///
  /// [connection] guards against removing a newer replacement connection.
  void unregisterOpenPack(String languageCode, {Database? connection}) {
    final code = _normalizeLanguage(languageCode);
    if (connection == null || identical(_connections[code], connection)) {
      _connections.remove(code);
    }
  }

  /// Map target language tags to surface forms for exactly [conceptId].
  ///
  /// The active pack is excluded; missing concepts, closed databases and
  /// failed/locked databases contribute no result. All registered connections
  /// are queried concurrently. Returns whatever completed within 50ms rather
  /// than waiting on a locked or slow pack; an empty map is a valid result.
  Future<Map<String, String>> findTranslations({
    required String conceptId,
    required String activeLanguageCode,
  }) async {
    final id = conceptId.trim();
    if (id.isEmpty) return const <String, String>{};

    final clock = Stopwatch()..start();
    final active = _normalizeLanguage(activeLanguageCode).split('-').first;
    // Exclude the active language even if its locale tag differs (de vs de-DE).
    // Snapshot the registry to protect this lookup against pack removals.
    final targets = _connections.entries
        .where((entry) => entry.key.split('-').first != active)
        .toList(growable: false);
    if (targets.isEmpty) return const <String, String>{};

    final found = <String, String>{};
    var expired = false;

    final requests = <Future<void>>[
      for (final target in targets)
        _readSurface(target.value, id).then<void>((surface) {
          if (!expired && surface != null) {
            found[target.key] = surface;
          }
        }),
    ];

    final remaining = lookupBudget - clock.elapsed;
    await Future.any<void>(<Future<void>>[
      Future.wait<void>(requests).then<void>((_) {}),
      Future<void>.delayed(
        remaining > Duration.zero ? remaining : Duration.zero,
      ),
    ]);

    expired = true;
    // Late SQLite completions cannot modify the snapshot returned to callers.
    return Map<String, String>.unmodifiable(found);
  }

  static Future<String?> _readSurface(Database db, String conceptId) async {
    try {
      if (!db.isOpen) return null;
      // concepts.concept_id is the primary key in the pack schema.
      final rows = await db.rawQuery(
        'SELECT surface FROM concepts WHERE concept_id = ? LIMIT 1',
        <Object?>[conceptId],
      );
      if (rows.isEmpty) return null;
      final surface = rows.first['surface'];
      return surface is String && surface.trim().isNotEmpty ? surface : null;
    } catch (_) {
      // A locked, closed or incompatible pack must not block peers.
      return null;
    }
  }

  static String _normalizeLanguage(String value) {
    final normalized = value.trim().toLowerCase().replaceAll('_', '-');
    if (!RegExp(r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$').hasMatch(normalized)) {
      throw ArgumentError.value(value, 'languageCode', 'Invalid language tag');
    }
    return normalized;
  }
}

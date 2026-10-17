import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'fts_search_service.dart';

typedef ClipboardTextReader = Future<String?> Function();
typedef DictionaryEntryExists = Future<bool> Function(
  String word,
  String languageCode,
);

enum QuickSearchOrigin { clipboard, processText }

/// Foreground-only, opt-in polling. Flutter's Clipboard API exposes no
/// cross-platform change stream. Nothing is uploaded, logged, or persisted.
///
/// Android PROCESS_TEXT additionally needs a native Activity/manifest intent
/// filter; the MethodChannel below is only the Dart-side integration hook.
class ClipboardQuickSearchService with WidgetsBindingObserver {
  ClipboardQuickSearchService({
    required String activeLanguageCode,
    required this.onMatch,
    ClipboardTextReader? readClipboard,
    DictionaryEntryExists? entryExists,
    bool Function()? isFocused,
    this.pollInterval = const Duration(seconds: 2),
    MethodChannel? processTextChannel,
  })  : _activeLanguageCode = activeLanguageCode,
        _readClipboard = readClipboard ?? _readSystemClipboard,
        _entryExists = entryExists ?? _findExactDictionaryEntry,
        _isFocused = isFocused ?? _defaultIsFocused,
        _channel = processTextChannel ??
            const MethodChannel('com.deutsch_bilarabi.app/process_text') {
    if (activeLanguageCode.trim().isEmpty) {
      throw ArgumentError.value(activeLanguageCode, 'activeLanguageCode');
    }
    if (pollInterval <= Duration.zero) {
      throw ArgumentError.value(pollInterval, 'pollInterval');
    }
  }

  final FutureOr<void> Function(String word, QuickSearchOrigin origin) onMatch;
  final ClipboardTextReader _readClipboard;
  final DictionaryEntryExists _entryExists;
  final bool Function() _isFocused;
  final MethodChannel _channel;
  final Duration pollInterval;
  String _activeLanguageCode;
  String? _lastClipboardText;
  Timer? _timer;
  bool _running = false;
  bool _disposed = false;
  bool _busy = false;
  bool _resumed = true;

  bool get isRunning => _running;
  String get activeLanguageCode => _activeLanguageCode;

  void setActiveLanguageCode(String languageCode) {
    if (languageCode.trim().isEmpty) {
      throw ArgumentError.value(languageCode, 'languageCode');
    }
    if (_activeLanguageCode == languageCode) return;
    _activeLanguageCode = languageCode;
    _lastClipboardText = null;
  }

  void start() {
    if (_disposed) throw StateError('Clipboard service has been disposed');
    if (_running) return;
    _running = true;
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _resumed = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    FocusManager.instance.addListener(_onFocusChange);
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'processText' || call.arguments is! String) {
        throw MissingPluginException('Unsupported process text method');
      }
      return handleProcessText(call.arguments as String);
    });
    // Explicit native handshake prevents cold-start selections being sent
    // before the Dart MethodChannel listener exists.
    unawaited(_notifyNative('ready'));
    _timer = Timer.periodic(pollInterval, (_) {
      unawaited(checkNow());
    });
  }

  void _onFocusChange() {
    if (_running && _resumed && _isFocused()) {
      unawaited(checkNow());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    if (_resumed && _running && _isFocused()) {
      unawaited(checkNow());
    }
  }

  /// One foreground clipboard sample; deduplicated and bounded to one token.
  Future<void> checkNow() async {
    if (!_running || _disposed || !_resumed || !_isFocused() || _busy) return;
    _busy = true;
    try {
      final clipboard = await _readClipboard();
      if (!_running || !_resumed || !_isFocused()) return;
      if (clipboard == _lastClipboardText) return;
      _lastClipboardText = clipboard;
      final word = _candidate(clipboard);
      if (word != null) {
        await _findAndNotify(word, QuickSearchOrigin.clipboard);
      }
    } catch (_) {
      // Platform clipboard read can be denied while device state changes.
    } finally {
      _busy = false;
    }
  }

  /// Called by the native PROCESS_TEXT bridge after the user selects text.
  /// This explicit action is allowed without the clipboard focus/poll gate.
  Future<bool> handleProcessText(String? selectedText) async {
    if (!_running || _disposed) return false;
    final word = _candidate(selectedText);
    if (word == null) return false;
    return _findAndNotify(word, QuickSearchOrigin.processText);
  }

  Future<bool> _findAndNotify(String word, QuickSearchOrigin origin) async {
    try {
      final languageAtLookup = _activeLanguageCode;
      final found = await _entryExists(word, languageAtLookup);
      if (!found ||
          !_running ||
          _disposed ||
          languageAtLookup != _activeLanguageCode) {
        return false;
      }
      await onMatch(word, origin);
      return true;
    } catch (_) {
      // Missing/corrupt/uninstalled packs must never crash the active UI.
      return false;
    }
  }

  static String? _candidate(String? text) {
    if (text == null || text.length > 160) return null;
    final word = text.trim();
    if (word.isEmpty ||
        word.runes.length > 80 ||
        !RegExp(r'^[^\s]+$').hasMatch(word)) {
      return null;
    }
    return word;
  }

  static bool _defaultIsFocused() =>
      FocusManager.instance.primaryFocus?.hasFocus ?? false;

  static Future<String?> _readSystemClipboard() async =>
      (await Clipboard.getData(Clipboard.kTextPlain))?.text;

  static Future<bool> _findExactDictionaryEntry(
    String word,
    String languageCode,
  ) async {
    final results = await FtsSearchService().searchDictionary(
      word,
      languageCode,
      limit: 20,
    );
    final normalized = word.toLowerCase();
    return results.any((row) {
      final surface = row['surface']?.toString().trim().toLowerCase();
      return surface == normalized;
    });
  }

  Future<void> _notifyNative(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
    } on MissingPluginException {
      // No native bridge on non-Android platforms or legacy installations.
    } on PlatformException {
      // Native bridge is optional; clipboard lookups still work offline.
    }
  }

  void stop() {
    if (!_running) return;
    _running = false;
    _timer?.cancel();
    _timer = null;
    _lastClipboardText = null;
    WidgetsBinding.instance.removeObserver(this);
    FocusManager.instance.removeListener(_onFocusChange);
    unawaited(_notifyNative('notReady'));
    _channel.setMethodCallHandler(null);
  }

  void dispose() {
    if (_disposed) return;
    stop();
    _disposed = true;
  }
}

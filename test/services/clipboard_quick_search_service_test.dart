import 'package:deutsch_bilarabi/services/clipboard_quick_search_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('looks up only new single-word clipboard content while focused', () async {
    var clipboard = 'Haus';
    var focused = true;
    final matches = <String>[];
    final service = ClipboardQuickSearchService(
      activeLanguageCode: 'de',
      isFocused: () => focused,
      readClipboard: () async => clipboard,
      entryExists: (word, lang) async => word == 'Haus' && lang == 'de',
      onMatch: (word, source) {
        matches.add(word);
        expect(source, QuickSearchOrigin.clipboard);
      },
      pollInterval: const Duration(hours: 1),
    );
    addTearDown(service.dispose);
    service.start();
    await service.checkNow();
    await service.checkNow();
    expect(matches, ['Haus']);

    focused = false;
    clipboard = 'neu';
    await service.checkNow();
    expect(matches, ['Haus']);
    focused = true;
    clipboard = 'Hallo Welt';
    await service.checkNow();
    expect(matches, ['Haus'], reason: 'Never query full clipboard passages');
  });

  test('never matches uninstalled words and catches lookup failures', () async {
    final matches = <String>[];
    final service = ClipboardQuickSearchService(
      activeLanguageCode: 'fr',
      isFocused: () => true,
      readClipboard: () async => 'inconnu',
      entryExists: (_, __) async => throw StateError('Pack not installed'),
      onMatch: (word, _) => matches.add(word),
      pollInterval: const Duration(hours: 1),
    );
    addTearDown(service.dispose);
    service.start();
    await service.checkNow();
    expect(matches, isEmpty);
  });

  test('announces ready only after installing native PROCESS_TEXT handler', () async {
    const channel = MethodChannel('test/process_text_lifecycle');
    final methods = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      methods.add(call.method);
      return null;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
    final service = ClipboardQuickSearchService(
      activeLanguageCode: 'de',
      onMatch: (_, __) {},
      entryExists: (_, __) async => true,
      readClipboard: () async => null,
      processTextChannel: channel,
      pollInterval: const Duration(hours: 1),
    );
    addTearDown(service.dispose);

    service.start();
    await Future<void>.delayed(Duration.zero);
    expect(methods, contains('ready'));

    service.stop();
    await Future<void>.delayed(Duration.zero);
    expect(methods, contains('notReady'));
  });

  test('native PROCESS_TEXT hook handles explicit selections without focus', () async {
    final words = <String>[];
    final service = ClipboardQuickSearchService(
      activeLanguageCode: 'tr',
      isFocused: () => false,
      readClipboard: () async => 'ignored',
      entryExists: (word, language) async => word == 'kitap' && language == 'tr',
      onMatch: (word, source) {
        expect(source, QuickSearchOrigin.processText);
        words.add(word);
      },
      pollInterval: const Duration(hours: 1),
    );
    addTearDown(service.dispose);
    service.start();
    expect(await service.handleProcessText('kitap'), isTrue);
    expect(await service.handleProcessText('kitap'), isTrue);
    expect(await service.handleProcessText('several words'), isFalse);
    expect(words, ['kitap', 'kitap']);
  });

  test('pausing app disables polling and updating pack resets dedupe', () async {
    var clipboard = 'Haus';
    final matches = <String>[];
    final service = ClipboardQuickSearchService(
      activeLanguageCode: 'de',
      isFocused: () => true,
      readClipboard: () async => clipboard,
      entryExists: (_, __) async => true,
      onMatch: (word, _) => matches.add(word),
      pollInterval: const Duration(hours: 1),
    );
    addTearDown(service.dispose);
    service.start();
    await service.checkNow();
    service.didChangeAppLifecycleState(AppLifecycleState.paused);
    clipboard = 'Baum';
    await service.checkNow();
    expect(matches, ['Haus']);
    service.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
    await service.checkNow();
    expect(matches, ['Haus', 'Baum']);
    service.setActiveLanguageCode('fr');
    await service.checkNow();
    expect(matches, ['Haus', 'Baum', 'Baum']);
  });
}

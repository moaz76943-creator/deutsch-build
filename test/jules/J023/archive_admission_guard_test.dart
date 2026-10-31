import 'package:deutsch_bilarabi/providers/active_language_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ArchiveOnlyStorage extends LanguagePackStorage {
  int downloads = 0;
  int deletions = 0;

  @override
  Future<void> download(
    LanguagePackMetadata pack, {
    required void Function(double progress) onProgress,
  }) async {
    downloads++;
    onProgress(1);
  }

  @override
  Future<void> delete(String code) async {
    deletions++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  const french = LanguagePackMetadata(
    code: 'fr',
    name: 'French',
    nativeName: 'Français',
    sizeBytes: 42,
    packFile: 'fr.pack.gz',
    sha256Hex: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    isAvailable: true,
  );

  test('cached archive is not equivalent to an installed database', () {
    final state = ActiveLanguageState.initial().copyWith(
      verifiedArchiveCodes: {'fr'},
    );

    expect(state.hasVerifiedArchive('fr'), isTrue);
    expect(state.isInstalled('fr'), isFalse);
    expect(state.isInstalled('de'), isTrue);
    expect(state.visiblePacks.any((pack) => pack.code == 'fr'), isTrue);
  });

  test('archive-only download is not selectable before pack admission',
      () async {
    final storage = _ArchiveOnlyStorage();
    final container = ProviderContainer(
      overrides: [languagePackStorageProvider.overrideWith((ref) => storage)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(activeLanguageProvider.notifier);
    notifier.updateRemoteCatalog([french]);
    await notifier.downloadPack('fr');

    final afterDownload = container.read(activeLanguageProvider);
    expect(storage.downloads, 1);
    expect(afterDownload.hasVerifiedArchive('fr'), isTrue);
    expect(afterDownload.isInstalled('fr'), isFalse);
    expect(afterDownload.activeLanguageCode, 'de');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('language_manager.active_code.v1'), isNull);
    await expectLater(notifier.selectLanguage('fr'), throwsStateError);
    expect(prefs.getString('language_manager.active_code.v1'), isNull);

    // Only a separately validated installer may admit content into the
    // installed set. This test simulates that explicit hand-off.
    notifier.updateInstalledList(['fr']);
    expect(container.read(activeLanguageProvider).isInstalled('fr'), isTrue);
    await notifier.selectLanguage('fr');
    expect(container.read(activeLanguageProvider).activeLanguageCode, 'fr');
    expect(prefs.getString('language_manager.active_code.v1'), 'fr');
  });

  test('discarding a downloaded archive does not mark a pack installed',
      () async {
    final storage = _ArchiveOnlyStorage();
    final container = ProviderContainer(
      overrides: [languagePackStorageProvider.overrideWith((ref) => storage)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(activeLanguageProvider.notifier);
    notifier.updateRemoteCatalog([french]);
    await notifier.downloadPack('fr');
    await notifier.deletePack('fr');

    final state = container.read(activeLanguageProvider);
    expect(storage.deletions, 1);
    expect(state.hasVerifiedArchive('fr'), isFalse);
    expect(state.isInstalled('fr'), isFalse);
    expect(state.isInstalled('de'), isTrue);
  });
}

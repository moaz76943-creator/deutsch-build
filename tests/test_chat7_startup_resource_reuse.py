from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
MAIN = (ROOT / 'lib/main.dart').read_text(encoding='utf-8')


def _boot_body() -> str:
    start = MAIN.index('Future<void> main() async')
    end = MAIN.index('\nclass _BootFailureApp')
    return MAIN[start:end]


def test_startup_does_not_rematerialize_content_pack_items():
    boot = _boot_body()
    assert 'contentPack.items.toList(growable: false)' not in boot
    assert re.search(r'final\s+corpus\s*=\s*contentPack\.items\s*;', boot)


def test_startup_constructs_verb_index_once_and_reuses_it():
    boot = _boot_body()
    assert boot.count('contentPack.verbIndex') == 1
    assert re.search(r'final\s+verbIndex\s*=\s*contentPack\.verbIndex\s*;', boot)
    assert re.search(r'SearchIndex\(\s*corpus,\s*verbIndex,', boot)
    assert 'verbIndex: verbIndex,' in boot


def test_startup_reuses_same_corpus_for_search_and_app_dependencies():
    boot = _boot_body()
    assert re.search(r'SearchIndex\(\s*corpus,', boot)
    assert 'corpus: corpus,' in boot

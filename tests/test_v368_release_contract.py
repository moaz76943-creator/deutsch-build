from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_v368_release_contract_declares_neutral_shared_service_projection():
    pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
    gradle = (ROOT / "android/app/build.gradle").read_text(encoding="utf-8")
    ci = (ROOT / "lib/services/content_intelligence.dart").read_text(encoding="utf-8")
    li = (ROOT / "lib/services/learning_intelligence.dart").read_text(encoding="utf-8")
    me = (ROOT / "lib/services/mistake_engine.dart").read_text(encoding="utf-8")
    assert "version:" in pubspec
    assert "versionCode " in gradle
    assert 'versionName "' in gradle
    assert "../core/content_contract.dart" in ci
    assert "List<LearningContent>" in ci
    assert "ContentItem" not in ci
    assert "../core/content_contract.dart" in li
    assert "List<LearningContent>" in li
    assert "ContentItem" not in li
    assert "../core/content_contract.dart" in me
    assert "LearningContent" in me
    assert "ContentItem" not in me

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_v360_release_contract_declares_human_friendly_content_authoring():
    pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
    gradle = (ROOT / "android" / "app" / "build.gradle").read_text(encoding="utf-8")
    tool = (ROOT / "tool" / "content_authoring.py").read_text(encoding="utf-8")
    docs = (ROOT / "docs" / "V360_CONTENT_AUTHORING_SCHEMA.md").read_text(encoding="utf-8")
    template = (ROOT / "content" / "german" / "batches" / "authoring_template.json").read_text(encoding="utf-8")
    assert "version:" in pubspec
    assert "versionCode " in gradle
    assert 'versionName "' in gradle
    assert "prepare_authoring" in tool
    assert "reviewable batch" in tool
    assert '"entries"' in docs
    assert '"verbs"' in template

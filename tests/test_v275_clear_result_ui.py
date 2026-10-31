from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = (ROOT / 'lib/ui_v35/account_pages.dart').read_text(encoding='utf-8')

def test_clear_progress_ui_checks_repository_result_before_success_message():
    start = SRC.index("final ok = await showDialog<bool>")
    body = SRC[start:SRC.index("ScaffoldMessenger", start)]
    assert 'final cleared = await repo.clearLocalData();' in body
    assert 'if (cleared)' in body
    assert "تعذر حذف بيانات التعلم المحلية" in SRC

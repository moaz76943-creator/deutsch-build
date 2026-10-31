from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
DASH = ROOT / 'lib/services/mastery_dashboard.dart'
PROGRESS = ROOT / 'lib/ui_v35/progress_pages.dart'
LEGACY = ROOT / 'lib/ui/app.dart'


def test_mastery_dashboard_has_no_content_engine_fallback():
    text = DASH.read_text(encoding='utf-8')
    assert "import 'content_engine.dart';" not in text
    assert 'ContentEngine.instance' not in text
    assert 'required List<LearningContent> corpus' in text


def test_all_dashboard_callers_pass_corpus():
    progress = PROGRESS.read_text(encoding='utf-8')
    legacy = LEGACY.read_text(encoding='utf-8')
    pattern = r'MasteryDashboard\.build\(\s*repo\.load\(\),\s*corpus:\s*corpus,\s*contentIntelligence:\s*contentIntelligence,?\s*\)'
    assert re.search(pattern, progress)
    assert re.search(pattern, legacy)

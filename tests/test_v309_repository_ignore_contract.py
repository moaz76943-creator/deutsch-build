from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_repository_ignore_contract_covers_generated_and_sensitive_artifacts():
    path = ROOT / '.gitignore'
    assert path.is_file(), '.gitignore must define repository artifact hygiene'
    text = path.read_text(encoding='utf-8')
    required = [
        '.dart_tool/',
        'build/',
        '.gradle/',
        '.pytest_cache/',
        '__pycache__/',
        '*.pyc',
        '*.log',
        '*.apk',
        '*.aab',
        '*.jks',
        '*.keystore',
        '.env',
        '.env.*',
    ]
    for entry in required:
        assert entry in text, f'.gitignore missing {entry}'

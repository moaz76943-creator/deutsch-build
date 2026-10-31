from pathlib import Path
from tempfile import TemporaryDirectory

from tool.content_compiler import compile_to


def test_generated_content_is_chunked_for_build_health():
    with TemporaryDirectory() as tmp:
        generated = Path(tmp) / 'generated'
        compile_to(generated)
        content_chunks = sorted(generated.glob('content_items_chunk_*.dart'))
        verb_chunks = sorted(generated.glob('verb_conjugations_chunk_*.dart'))
        assert len(content_chunks) >= 2
        assert len(verb_chunks) >= 2
        assert all(len(p.read_text(encoding='utf-8').splitlines()) < 1000 for p in content_chunks + verb_chunks)

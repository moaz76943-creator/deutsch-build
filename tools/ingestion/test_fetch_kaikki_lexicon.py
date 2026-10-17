"""Focused offline tests for the Kaikki harvester (standard library only)."""
import gzip
import json
import tempfile
import unittest
from pathlib import Path

from fetch_kaikki_lexicon import harvest, main


def sample(word, pos='noun', lang='en', translations=None, gloss='meaning', **extra):
    return {
        'word': word,
        'lang_code': lang,
        'pos': pos,
        'senses': [{'glosses': [gloss]}],
        'translations': translations or [],
        **extra,
    }


class KaikkiHarvestTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.src = self.root / 'input.jsonl'
        self.output = self.root / 'out'

    def tearDown(self):
        self.tmp.cleanup()

    def write_lines(self, items, compressed=False):
        self.src = self.root / ('input.jsonl.gz' if compressed else 'input.jsonl')
        op = gzip.open if compressed else open
        with op(self.src, 'wt', encoding='utf-8') as fh:
            for item in items:
                fh.write(json.dumps(item, ensure_ascii=False) + '\n')

    def document(self, lang='en'):
        return json.loads((self.output / lang / 'canonical' / f'{lang}-1.0.0.json').read_text(encoding='utf-8'))

    def test_canonical_contract_translation_dedup_and_priority(self):
        self.write_lines([
            sample('book', translations=[{'lang_code':'ar','word':'كتاب'}]),
            sample('Book', translations=[{'lang_code':'en','word':'volume'}]),
            sample('run', 'verb', gloss='To move quickly', cefr='A1'),
            sample('the', 'article'),
            sample('casa', 'noun', 'es'),
            sample('bad\ufffdword'),
            sample('apple', gloss='a fruit'),
        ])
        ranks = self.root / 'frequency.csv'
        ranks.write_text('word,rank,cefr\napple,1,A1\nbook,2,A2\nrun,3,B1\n',encoding='utf-8')
        result = harvest('en', self.src, self.output, limit=3, frequency_file=ranks)
        self.assertEqual(result['written'], 3)
        doc = self.document()
        self.assertEqual(set(doc), {'schemaVersion','pack','requiredLocalizationKeys','localization','lexicon','grammar'})
        self.assertEqual(doc['schemaVersion'], 1)
        self.assertEqual(doc['pack']['id'], 'en')
        self.assertEqual(doc['pack']['contractVersion'], '1.0.0')
        self.assertEqual(doc['grammar'], [])
        self.assertEqual({x['surface'].casefold() for x in doc['lexicon']}, {'book','run','apple'})
        book = next(x for x in doc['lexicon'] if x['surface'].casefold() == 'book')
        self.assertEqual(book['fields']['translation']['language'], 'ar')
        self.assertEqual(book['fields']['translation']['text'], 'كتاب')
        self.assertEqual(book['fields']['canonical']['cefr'], 'A2')
        self.assertTrue(all(x['direction']=='ltr' for x in doc['lexicon']))
        self.assertTrue(all(x['id'].startswith('en.') for x in doc['lexicon']))
        self.assertTrue(all('source' in x['fields'] for x in doc['lexicon']))

    def test_gz_jsonl_and_english_gloss_fallback(self):
        self.write_lines([sample('école','noun',lang='fr',gloss='school'), sample('lire','verb',lang='fr',gloss='to read')], compressed=True)
        result = harvest('fr', self.src, self.output, limit=5)
        self.assertEqual(result['written'],2)
        doc=self.document('fr')
        self.assertEqual([x['fields']['translation']['language'] for x in doc['lexicon']], ['en','en'])
        self.assertTrue(all(x['fields']['translation']['method']=='gloss' for x in doc['lexicon']))

    def test_json_array_and_utf8_replacement_filter(self):
        self.src = self.root / 'input.json'
        self.src.write_text(json.dumps([sample('hola',lang='es',gloss='hello'),sample('mal\ud800',lang='es')]),encoding='utf-8')
        result = harvest('es',self.src,self.output,limit=5)
        self.assertEqual(result['written'],1)
        self.assertEqual(self.document('es')['lexicon'][0]['surface'],'hola')

    def test_rejects_empty_without_overwriting_existing(self):
        self.write_lines([sample('swim','verb')])
        harvest('en',self.src,self.output,limit=1)
        path=self.output/'en'/'canonical'/'en-1.0.0.json'
        original=path.read_bytes()
        self.write_lines([sample('the','article')])
        with self.assertRaises(ValueError):
            harvest('en',self.src,self.output,limit=1)
        self.assertEqual(path.read_bytes(),original)

    def test_cli_and_invalid_utf8_line(self):
        self.src.write_bytes(b'\xff\n'+(json.dumps(sample('merhaba',lang='tr',gloss='hello')).encode('utf-8'))+b'\n')
        code=main(['--lang','tr','--limit','2','--input',str(self.src),'--output-dir',str(self.output)])
        self.assertEqual(code,0)
        self.assertEqual(self.document('tr')['lexicon'][0]['surface'],'merhaba')


if __name__ == '__main__':
    unittest.main()

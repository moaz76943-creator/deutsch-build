import sqlite3
import csv
import json
import gzip
import shutil
import os

TSV_FILE = "pilot_matrix.tsv"
PACKS_DIR = "assets/content/packs"
LANGS = ["de", "ar", "en", "es", "fr"]

def get_table_info(cursor, table_name):
    cursor.execute(f"PRAGMA table_info({table_name});")
    return {row[1]: {"notnull": row[3], "type": row[2]} for row in cursor.fetchall()}

def ensure_schema(conn):
    cur = conn.cursor()
    cur.execute("PRAGMA table_info(concepts);")
    cols = [c[1] for c in cur.fetchall()]
    
    # إضافة الأعمدة الناقصة في concepts
    if "section_id" not in cols:
        cur.execute("ALTER TABLE concepts ADD COLUMN section_id TEXT;")
    if "cefr" not in cols:
        cur.execute("ALTER TABLE concepts ADD COLUMN cefr TEXT;")
    conn.commit()

    # إنشاء الفهرس المركب لتسريع التصفية حسب القسم والمرحلة
    cur.execute("""
        CREATE INDEX IF NOT EXISTS idx_concepts_section_cefr 
        ON concepts(section_id, cefr);
    """)
    conn.commit()

def _get_surface(lang, r):
    if lang == "de":
        return r["lemma_de"]
    elif lang == "ar":
        return r["translation_ar"]
    elif lang == "en":
        return r["translation_en"]
    return r["translation_en"] or r["lemma_de"]

def _build_metadata(r, sec, lvl):
    return json.dumps({
        "example_de": r.get("example_de", ""),
        "example_ar": r.get("example_ar", ""),
        "section": sec,
        "stage": lvl,
        "translation_ar": r.get("translation_ar", ""),
        "translation_en": r.get("translation_en", "")
    }, ensure_ascii=False)

def _build_concept_row(con_info, c_id, sec, surface, pos, lvl, lang, metadata):
    con_row = {}
    for col, meta in con_info.items():
        if col in ("concept_id", "id"):
            con_row[col] = c_id
        elif col == "sense_id":
            con_row[col] = f"{c_id}_s1"
        elif col == "section_id":
            con_row[col] = sec
        elif col in ("lemma", "surface"):
            con_row[col] = surface
        elif col in ("part_of_speech", "pos"):
            con_row[col] = pos
        elif col in ("cefr", "cefr_level"):
            con_row[col] = lvl
        elif col == "direction":
            con_row[col] = "rtl" if lang == "ar" else "ltr"
        elif col in ("legacy_fields_json", "metadata_json", "fields_json"):
            con_row[col] = metadata
        elif meta["notnull"]:
            con_row[col] = ""
    return con_row

def _build_lexicon_row(lex_info, c_id, surface, pos, lvl, lang, metadata):
    lex_row = {}
    for col, meta in lex_info.items():
        if col in ("id", "concept_id", "word_id"):
            lex_row[col] = c_id
        elif col in ("surface", "lemma", "word"):
            lex_row[col] = surface
        elif col in ("part_of_speech", "pos"):
            lex_row[col] = pos
        elif col in ("cefr_level", "cefr"):
            lex_row[col] = lvl
        elif col in ("language_code", "lang"):
            lex_row[col] = lang
        elif col == "direction":
            lex_row[col] = "rtl" if lang == "ar" else "ltr"
        elif col == "fields_json":
            lex_row[col] = metadata
        elif meta["notnull"]:
            lex_row[col] = ""
    return lex_row

def _process_language(lang, rows):
    db_path = f"{PACKS_DIR}/{lang}/sqlite/{lang}-1.0.0.sqlite"
    if not os.path.exists(db_path):
        return

    conn = sqlite3.connect(db_path)
    ensure_schema(conn)
    cur = conn.cursor()

    con_info = get_table_info(cur, "concepts")
    lex_info = get_table_info(cur, "lexicon")

    for r in rows:
        c_id = r["concept_id"]
        sec = r["section_id"]
        lvl = r["cefr"]
        pos = r["pos"]

        surface = _get_surface(lang, r)
        metadata = _build_metadata(r, sec, lvl)

        con_row = _build_concept_row(con_info, c_id, sec, surface, pos, lvl, lang, metadata)
        c_cols = ", ".join(con_row.keys())
        c_place = ", ".join(["?"] * len(con_row))
        cur.execute(f"INSERT OR REPLACE INTO concepts ({c_cols}) VALUES ({c_place});", list(con_row.values()))

        lex_row = _build_lexicon_row(lex_info, c_id, surface, pos, lvl, lang, metadata)
        l_cols = ", ".join(lex_row.keys())
        l_place = ", ".join(["?"] * len(lex_row))
        cur.execute(f"INSERT OR REPLACE INTO lexicon ({l_cols}) VALUES ({l_place});", list(lex_row.values()))

    conn.commit()
    conn.close()

    gz_path = f"{PACKS_DIR}/{lang}/{lang}-1.0.0.pack.gz"
    with open(db_path, "rb") as f_in:
        with gzip.open(gz_path, "wb") as f_out:
            shutil.copyfileobj(f_in, f_out)
    print(f"✅ تم تحديث حزمة ({lang}) بنجاح.")

def ingest():
    if not os.path.exists(TSV_FILE):
        print("❌ ملف TSV غير موجود.")
        return

    with open(TSV_FILE, "r", encoding="utf-8") as f:
        rows = list(csv.DictReader(f, delimiter="\t"))

    print(f"⚡ [بدء المعالجة] جاري حقن {len(rows)} مدخلاً مصنفاً عبر القواعد...")

    for lang in LANGS:
        _process_language(lang, rows)

if __name__ == "__main__":
    ingest()

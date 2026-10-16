import os
import sqlite3
import gzip
import shutil
import json

PACKS_DIR = "assets/content/packs"

def ensure_pack(lang_code, name, direction):
    lang_dir = f"{PACKS_DIR}/{lang_code}"
    sqlite_dir = f"{lang_dir}/sqlite"
    os.makedirs(sqlite_dir, exist_ok=True)

    db_path = f"{sqlite_dir}/{lang_code}-1.0.0.sqlite"
    gz_path = f"{lang_dir}/{lang_code}-1.0.0.pack.gz"

    if not os.path.exists(db_path):
        conn = sqlite3.connect(db_path)
        cur = conn.cursor()
        cur.execute("CREATE TABLE IF NOT EXISTS concepts (concept_id TEXT PRIMARY KEY, section_id TEXT, cefr TEXT, category TEXT, priority INTEGER DEFAULT 1);")
        cur.execute("CREATE TABLE IF NOT EXISTS lexicon (concept_id TEXT PRIMARY KEY, display_text TEXT, lemma TEXT, part_of_speech TEXT, cefr_level TEXT, language_code TEXT, direction TEXT, gender TEXT, plural TEXT, ipa TEXT, audio_key TEXT);")
        cur.execute("CREATE TABLE IF NOT EXISTS exercises (exercise_id TEXT PRIMARY KEY, concept_id TEXT, exercise_type TEXT, prompt TEXT, correct_answer TEXT, distractors_json TEXT);")
        cur.execute("CREATE TABLE IF NOT EXISTS dataset_metadata (key TEXT PRIMARY KEY, value TEXT);")

        # بيانات بذرة أساسية
        seeds = [
            ("c_kit_n01", "HOME_KITCHEN", "A1", "noun", "der Kühlschrank" if lang_code == "de" else "الثلاجة"),
            ("c_kit_v01", "HOME_KITCHEN", "A1", "verb", "kochen" if lang_code == "de" else "يطبخ"),
            ("c_bth_n01", "HOME_BATHROOM", "A1", "noun", "die Seife" if lang_code == "de" else "الصابون"),
            ("c_pha_n01", "PHARMA", "A1", "noun", "die Tablette" if lang_code == "de" else "قرص الدواء"),
            ("c_emg_p01", "EMERGENCY", "A1", "phrase", "Rufen Sie den Krankenwagen!" if lang_code == "de" else "اتصل بالإسعاف فوراً!")
        ]

        for cid, sec, cefr, pos, text in seeds:
            cur.execute("INSERT OR REPLACE INTO concepts VALUES (?, ?, ?, ?, 1);", (cid, sec, cefr, sec))
            cur.execute("INSERT OR REPLACE INTO lexicon (concept_id, display_text, lemma, part_of_speech, cefr_level, language_code, direction) VALUES (?, ?, ?, ?, ?, ?, ?);", (cid, text, text, pos, cefr, lang_code, direction))
            cur.execute("INSERT OR REPLACE INTO exercises VALUES (?, ?, 'MCQ', ?, ?, ?);", (f"ex_{lang_code}_{cid}", cid, f"اختر: {text}", text, json.dumps(["خيار 1", "خيار 2", "خيار 3"], ensure_ascii=False)))

        cur.execute("CREATE VIRTUAL TABLE IF NOT EXISTS lexicon_fts USING fts5(concept_id UNINDEXED, display_text, lemma, tokenize='unicode61');")
        for cid, sec, cefr, pos, text in seeds:
            cur.execute("INSERT INTO lexicon_fts (concept_id, display_text, lemma) VALUES (?, ?, ?);", (cid, text, text))

        cur.executemany("INSERT OR REPLACE INTO dataset_metadata VALUES (?, ?);", [
            ("source", "Kaikki.org / Wiktionary"),
            ("license", "CC BY-SA 4.0 / GFDL 1.3"),
            ("language_code", lang_code),
            ("direction", direction)
        ])
        conn.commit()
        conn.close()

    # ضغط الحزمة إلى pack.gz
    with open(db_path, "rb") as f_in:
        with gzip.open(gz_path, "wb") as f_out:
            shutil.copyfileobj(f_in, f_out)
    print(f"📦 تم تأمين حزمة الأصول الأساسية: {gz_path}")

ensure_pack("de", "German", "ltr")
ensure_pack("ar", "Arabic", "rtl")

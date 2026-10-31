import sqlite3
import json
import random
import gzip
import shutil
import hashlib
import os

PACKS_DIR = "assets/content/packs"
MANIFEST_FILE = "assets/content/packs/manifest.json"

TTS_LOCALES = {
    "de": "de-DE", "ar": "ar-SA", "en": "en-US", "fr": "fr-FR",
    "es": "es-ES", "it": "it-IT", "tr": "tr-TR", "pt": "pt-BR",
    "ru": "ru-RU", "nl": "nl-NL"
}

def get_sha256(filepath):
    hasher = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(8192):
            hasher.update(chunk)
    return hasher.hexdigest()

def enrich_database(lang, db_path):
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()

    # 1. إنشاء جدول تتبع الحفظ والمراجعة (Spaced Repetition System - SRS)
    cur.execute("""
        CREATE TABLE IF NOT EXISTS user_progress (
            concept_id TEXT PRIMARY KEY,
            box_level INTEGER DEFAULT 0,
            ease_factor REAL DEFAULT 2.5,
            interval_days INTEGER DEFAULT 0,
            repetitions INTEGER DEFAULT 0,
            last_reviewed_at INTEGER,
            next_review_at INTEGER
        );
    """)

    # 2. إنشاء جدول الفهرسة النصية الكاملة للبحث الفوري (FTS5)
    cur.execute("DROP TABLE IF EXISTS lexicon_fts;")
    cur.execute("""
        CREATE VIRTUAL TABLE lexicon_fts USING fts5(
            concept_id UNINDEXED,
            display_text,
            lemma,
            tokenize = 'unicode61'
        );
    """)
    cur.execute("""
        INSERT INTO lexicon_fts (concept_id, display_text, lemma)
        SELECT concept_id, COALESCE(display_text, ''), COALESCE(lemma, '')
        FROM lexicon;
    """)

    # 3. جلب المفاهيم لتوليد التمارين والمشتتات الذكية
    cur.execute("""
        SELECT c.concept_id, c.section_id, c.cefr, COALESCE(l.display_text, l.lemma, '')
        FROM concepts c
        LEFT JOIN lexicon l ON l.concept_id = c.concept_id;
    """)
    items = cur.fetchall()

    # تصنيف الكلمات حسب القسم لسحب الخيارات الخاطئة بدقة
    section_map = {}
    for cid, sec, lvl, word in items:
        if sec not in section_map:
            section_map[sec] = []
        if word:
            section_map[sec].append(word)

    cur.execute("DELETE FROM exercises;")
    exercise_records = []

    for cid, sec, lvl, word in items:
        if not word:
            continue
        # توليد 3 خيارات خاطئة من نفس القسم
        pool = [w for w in section_map.get(sec, []) if w != word]
        distractors = random.sample(pool, min(3, len(pool)))

        # تمرين اختيار الترجمة الصحيحة
        ex_id = f"ex_{lang}_{cid}_mc"
        prompt = f"Wähle die richtige Bedeutung: ({word})" if lang != "de" else f"اختر المعنى المناسب للكلمة: ({word})"
        exercise_records.append((
            ex_id,
            cid,
            "MULTIPLE_CHOICE",
            prompt,
            word,
            json.dumps(distractors, ensure_ascii=False)
        ))

    cur.executemany("""
        INSERT OR REPLACE INTO exercises (exercise_id, concept_id, exercise_type, prompt, correct_answer, distractors_json)
        VALUES (?, ?, ?, ?, ?, ?);
    """, exercise_records)

    conn.commit()
    conn.close()

def main():
    if not os.path.exists(PACKS_DIR):
        print("❌ المجلد assets/content/packs غير موجود.")
        return

    manifest = {"version": "2.0.0", "packs": {}}
    langs = [d for d in os.listdir(PACKS_DIR) if os.path.isdir(os.path.join(PACKS_DIR, d))]
    print(f"🚀 بدء تفعيل طبقة التمارين و FTS5 و SRS عبر {len(langs)} لغة...")

    for lang in langs:
        db_path = f"{PACKS_DIR}/{lang}/sqlite/{lang}-1.0.0.sqlite"
        gz_path = f"{PACKS_DIR}/{lang}/{lang}-1.0.0.pack.gz"

        if not os.path.exists(db_path):
            continue

        enrich_database(lang, db_path)

        # ضغط الحزمة بعد الترقية
        with open(db_path, "rb") as f_in:
            with gzip.open(gz_path, "wb") as f_out:
                shutil.copyfileobj(f_in, f_out)

        # توثيق في المانيفست
        conn = sqlite3.connect(db_path)
        cur = conn.cursor()
        cur.execute("SELECT count(*) FROM exercises;")
        total_ex = cur.fetchone()[0]
        cur.execute("SELECT count(*) FROM concepts;")
        total_concepts = cur.fetchone()[0]
        conn.close()

        manifest["packs"][lang] = {
            "size_bytes": os.path.getsize(gz_path),
            "sha256": get_sha256(gz_path),
            "total_concepts": total_concepts,
            "total_exercises": total_ex,
            "tts_locale": TTS_LOCALES.get(lang, "en-US"),
            "db_version": "2.0.0"
        }
        print(f"  ✓ [{lang.upper()}] تم توليد {total_ex} تمريناً مدمجاً وفهرسة FTS5.")

    with open(MANIFEST_FILE, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)

    print(f"\n🎉 اكتمل بناء محرك الإنتاج وتحديث {MANIFEST_FILE} بنجاح.")

if __name__ == "__main__":
    main()

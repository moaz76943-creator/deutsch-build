import sqlite3
import json
import hashlib
import gzip
import os

PACKS_DIR = "assets/content/packs"
MANIFEST_FILE = "assets/content/packs/manifest.json"

def get_sha256(filepath):
    hasher = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(8192):
            hasher.update(chunk)
    return hasher.hexdigest()

def upgrade_and_manifest():
    manifest = {"version": "1.0.0", "packs": {}}

    if not os.path.exists(PACKS_DIR):
        print("❌ المجلد assets/content/packs غير موجود.")
        return

    langs = [d for d in os.listdir(PACKS_DIR) if os.path.isdir(os.path.join(PACKS_DIR, d))]
    print(f"🔧 ترقية البنية الهيكلية لـ {len(langs)} لغة وتوليد الـ Manifest...")

    for lang in langs:
        db_path = f"{PACKS_DIR}/{lang}/sqlite/{lang}-1.0.0.sqlite"
        gz_path = f"{PACKS_DIR}/{lang}/{lang}-1.0.0.pack.gz"

        if not os.path.exists(db_path):
            continue

        conn = sqlite3.connect(db_path)
        cur = conn.cursor()

        # 1. ترقية جدول lexicon بالأعمدة النحوية والصوتية
        cur.execute("PRAGMA table_info(lexicon);")
        existing_cols = [c[1] for c in cur.fetchall()]

        grammar_cols = {
            "gender": "TEXT",       # m, f, n
            "plural": "TEXT",       # صيغة الجمع
            "ipa": "TEXT",          # النطق الصوتي
            "audio_key": "TEXT"     # معرف ملف الصوت
        }

        for col, col_type in grammar_cols.items():
            if col not in existing_cols:
                cur.execute(f"ALTER TABLE lexicon ADD COLUMN {col} {col_type};")

        # 2. إنشاء جدول التمارين المدمجة إن لم يكن موجوداً
        cur.execute("""
            CREATE TABLE IF NOT EXISTS exercises (
                exercise_id TEXT PRIMARY KEY,
                concept_id TEXT,
                exercise_type TEXT,
                prompt TEXT,
                correct_answer TEXT,
                distractors_json TEXT
            );
        """)

        # إحصائيات الحزمة
        cur.execute("SELECT count(*) FROM concepts;")
        total_concepts = cur.fetchone()[0]

        conn.commit()
        conn.close()

        # التأكد من سلامة ملف الـ GZ وتوثيقه في الـ Manifest
        if os.path.exists(gz_path):
            manifest["packs"][lang] = {
                "size_bytes": os.path.getsize(gz_path),
                "sha256": get_sha256(gz_path),
                "total_concepts": total_concepts,
                "db_version": "1.0.0"
            }

    with open(MANIFEST_FILE, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)

    print(f"✅ تم تحديث جميع القواعد وإنشاء {MANIFEST_FILE} بنجاح.")

if __name__ == "__main__":
    upgrade_and_manifest()

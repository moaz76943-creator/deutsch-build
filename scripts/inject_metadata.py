import sqlite3
import json
import gzip
import shutil
import hashlib
import os

PACKS_DIR = "assets/content/packs"
MANIFEST_FILE = os.path.join(PACKS_DIR, "manifest.json")

METADATA_ENTRIES = [
    ("source", "Kaikki.org / Wiktionary"),
    ("license", "CC BY-SA 4.0 / GFDL 1.3"),
    ("attribution_url", "https://kaikki.org"),
    ("share_alike", "True"),
    ("db_version", "2.1.0"),
    ("pipeline_build", "2026-10-12")
]

def get_sha256(filepath):
    hasher = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(8192):
            hasher.update(chunk)
    return hasher.hexdigest()

def inject_metadata():
    if not os.path.exists(PACKS_DIR):
        print("❌ المسار assets/content/packs غير موجود.")
        return

    langs = [d for d in os.listdir(PACKS_DIR) if os.path.isdir(os.path.join(PACKS_DIR, d))]
    print(f"⚖️ حقن جدول التراخيص والنسب القانوني في {len(langs)} لغة...")

    with open(MANIFEST_FILE, "r", encoding="utf-8") as f:
        manifest = json.load(f)

    for lang in langs:
        db_path = f"{PACKS_DIR}/{lang}/sqlite/{lang}-1.0.0.sqlite"
        gz_path = f"{PACKS_DIR}/{lang}/{lang}-1.0.0.pack.gz"

        if not os.path.exists(db_path):
            continue

        conn = sqlite3.connect(db_path)
        cur = conn.cursor()

        # إنشاء جدول التوثيق والنسب القانوني
        cur.execute("""
            CREATE TABLE IF NOT EXISTS dataset_metadata (
                key TEXT PRIMARY KEY,
                value TEXT
            );
        """)

        cur.executemany("""
            INSERT OR REPLACE INTO dataset_metadata (key, value)
            VALUES (?, ?);
        """, METADATA_ENTRIES)

        conn.commit()
        conn.close()

        # إعادة ضغط الحزمة بعد التعديل
        with open(db_path, "rb") as f_in:
            with gzip.open(gz_path, "wb") as f_out:
                shutil.copyfileobj(f_in, f_out)

        # تحديث المانيفست بالبصمة والحجم الجديد
        if lang in manifest["packs"]:
            manifest["packs"][lang]["sha256"] = get_sha256(gz_path)
            manifest["packs"][lang]["size_bytes"] = os.path.getsize(gz_path)
            manifest["packs"][lang]["license"] = "CC BY-SA 4.0"

    with open(MANIFEST_FILE, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)

    print("✅ تم توثيق شروط CC BY-SA وتحديث manifest.json بنجاح تام.")

if __name__ == "__main__":
    inject_metadata()

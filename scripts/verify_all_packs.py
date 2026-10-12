import sqlite3
import json
import gzip
import hashlib
import os
import sys

PACKS_DIR = "assets/content/packs"
MANIFEST_FILE = os.path.join(PACKS_DIR, "manifest.json")

def verify_system():
    if not os.path.exists(MANIFEST_FILE):
        print("❌ خطأ: ملف manifest.json غير موجود.")
        sys.exit(1)

    with open(MANIFEST_FILE, "r", encoding="utf-8") as f:
        manifest = json.load(f)

    packs = manifest.get("packs", {})
    print(f"🔍 [بدء الفحص الآلي] جاري التحقق من {len(packs)} حزمة لغوية...\n")

    errors = []
    for lang, meta in packs.items():
        gz_path = f"{PACKS_DIR}/{lang}/{lang}-1.0.0.pack.gz"
        db_path = f"{PACKS_DIR}/{lang}/sqlite/{lang}-1.0.0.sqlite"

        # 1. التحقق من وجود الملفات
        if not os.path.exists(gz_path) or not os.path.exists(db_path):
            errors.append(f"[{lang}] ملفات الحزمة مفقودة في المسار.")
            continue

        # 2. التحقق من مطابقة SHA-256
        hasher = hashlib.sha256()
        with open(gz_path, "rb") as f:
            while chunk := f.read(8192):
                hasher.update(chunk)
        calc_sha = hasher.hexdigest()

        if calc_sha != meta["sha256"]:
            errors.append(f"[{lang}] عدم تطابق SHA-256 بين الملف والبيان.")

        # 3. فحص البنية الداخلية لقاعدة البيانات
        conn = sqlite3.connect(db_path)
        cur = conn.cursor()

        # التأكد من عدم وجود مفاهيم بدون معجم (Orphaned Concepts)
        cur.execute("""
            SELECT count(*) 
            FROM concepts c 
            LEFT JOIN lexicon l ON l.concept_id = c.concept_id 
            WHERE l.concept_id IS NULL;
        """)
        orphans = cur.fetchone()[0]
        if orphans > 0:
            errors.append(f"[{lang}] يوجد {orphans} مفهوماً بدون ترجمة في المعجم.")

        # اختبار جدول التمارين
        cur.execute("SELECT count(*) FROM exercises;")
        ex_count = cur.fetchone()[0]
        if ex_count == 0:
            errors.append(f"[{lang}] جدول التمارين exercises فارغ.")

        # اختبار كفاءة محرك البحث الفوري FTS5
        try:
            cur.execute("SELECT count(*) FROM lexicon_fts;")
            fts_count = cur.fetchone()[0]
            if fts_count == 0:
                errors.append(f"[{lang}] جدول البحث FTS5 فارغ.")
        except sqlite3.OperationalError:
            errors.append(f"[{lang}] جدول FTS5 غير منشأ أو تالف.")

        conn.close()

    if errors:
        print(f"❌ تم العثور على {len(errors)} مشكلة أثناء الفحص:")
        for err in errors:
            print(f"   - {err}")
        sys.exit(1)
    else:
        print("✅ جميع الحزم مطابقة بنسبة 100% لمعايير النزاهة الهندسية وتكامل البيانات.")

if __name__ == "__main__":
    verify_system()

import sqlite3
import csv
import json
import gzip
import shutil
import os

PACKS_DIR = "assets/content/packs"
TSV_FILE = "pilot_matrix.tsv"

# قائمة 100 لغة عالمية بمعايير ISO-639-1 المعتمدة
LANGUAGES_100 = {
    # اللغات الأساسية والأوروبية الكبرى
    "de": ("German", "ltr"), "ar": ("Arabic", "rtl"), "en": ("English", "ltr"),
    "es": ("Spanish", "ltr"), "fr": ("French", "ltr"), "it": ("Italian", "ltr"),
    "pt": ("Portuguese", "ltr"), "ru": ("Russian", "ltr"), "tr": ("Turkish", "ltr"),
    "nl": ("Dutch", "ltr"), "pl": ("Polish", "ltr"), "uk": ("Ukrainian", "ltr"),
    "ro": ("Romanian", "ltr"), "el": ("Greek", "ltr"), "cs": ("Czech", "ltr"),
    "sv": ("Swedish", "ltr"), "hu": ("Hungarian", "ltr"), "bg": ("Bulgarian", "ltr"),
    "da": ("Danish", "ltr"), "fi": ("Finnish", "ltr"), "sk": ("Slovak", "ltr"),
    "no": ("Norwegian", "ltr"), "hr": ("Croatian", "ltr"), "lt": ("Lithuanian", "ltr"),
    "sl": ("Slovenian", "ltr"), "lv": ("Latvian", "ltr"), "et": ("Estonian", "ltr"),
    "ga": ("Irish", "ltr"), "mt": ("Maltese", "ltr"), "is": ("Icelandic", "ltr"),
    "sq": ("Albanian", "ltr"), "bs": ("Bosnian", "ltr"), "mk": ("Macedonian", "ltr"),
    "sr": ("Serbian", "ltr"), "cy": ("Welsh", "ltr"), "lb": ("Luxembourgish", "ltr"),
    "ca": ("Catalan", "ltr"), "eu": ("Basque", "ltr"), "gl": ("Galician", "ltr"),

    # لغات الشرق الأوسط وإفريقيا
    "fa": ("Persian", "rtl"), "ur": ("Urdu", "rtl"), "he": ("Hebrew", "rtl"),
    "ku": ("Kurdish", "rtl"), "ps": ("Pashto", "rtl"), "sd": ("Sindhi", "rtl"),
    "sw": ("Swahili", "ltr"), "am": ("Amharic", "ltr"), "ha": ("Hausa", "ltr"),
    "yo": ("Yoruba", "ltr"), "ig": ("Igbo", "ltr"), "om": ("Oromo", "ltr"),
    "so": ("Somali", "ltr"), "zu": ("Zulu", "ltr"), "xh": ("Xhosa", "ltr"),
    "af": ("Afrikaans", "ltr"), "rw": ("Kinyarwanda", "ltr"), "mg": ("Malagasy", "ltr"),
    "ny": ("Chichewa", "ltr"), "sn": ("Shona", "ltr"), "st": ("Sesotho", "ltr"),
    "ti": ("Tigrinya", "ltr"),

    # لغات جنوب ووسط وشرق آسيا
    "hi": ("Hindi", "ltr"), "bn": ("Bengali", "ltr"), "pa": ("Punjabi", "ltr"),
    "te": ("Telugu", "ltr"), "mr": ("Marathi", "ltr"), "ta": ("Tamil", "ltr"),
    "gu": ("Gujarati", "ltr"), "kn": ("Kannada", "ltr"), "ml": ("Malayalam", "ltr"),
    "or": ("Odia", "ltr"), "ne": ("Nepali", "ltr"), "si": ("Sinhala", "ltr"),
    "zh": ("Chinese", "ltr"), "ja": ("Japanese", "ltr"), "ko": ("Korean", "ltr"),
    "vi": ("Vietnamese", "ltr"), "id": ("Indonesian", "ltr"), "ms": ("Malay", "ltr"),
    "th": ("Thai", "ltr"), "my": ("Burmese", "ltr"), "km": ("Khmer", "ltr"),
    "lo": ("Lao", "ltr"), "tl": ("Tagalog", "ltr"), "ceb": ("Cebuano", "ltr"),
    "jv": ("Javanese", "ltr"), "su": ("Sundanese", "ltr"), "mn": ("Mongolian", "ltr"),

    # لغات آسيا الوسطى والقوقاز والمحيط
    "uz": ("Uzbek", "ltr"), "kk": ("Kazakh", "ltr"), "az": ("Azerbaijani", "ltr"),
    "hy": ("Armenian", "ltr"), "ka": ("Georgian", "ltr"), "tg": ("Tajik", "ltr"),
    "tk": ("Turkmen", "ltr"), "ky": ("Kyrgyz", "ltr"), "tt": ("Tatar", "ltr"),
    "eo": ("Esperanto", "ltr"), "la": ("Latin", "ltr"), "sm": ("Samoan", "ltr")
}

def get_table_cols(cursor, table_name):
    cursor.execute(f"PRAGMA table_info({table_name});")
    return {row[1]: row[3] for row in cursor.fetchall()}

def prepare_db(db_path):
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS concepts (
            concept_id TEXT PRIMARY KEY,
            section_id TEXT,
            cefr TEXT
        );
    """)
    cur.execute("""
        CREATE TABLE IF NOT EXISTS lexicon (
            concept_id TEXT PRIMARY KEY,
            display_text TEXT,
            lemma TEXT,
            part_of_speech TEXT,
            cefr_level TEXT,
            language_code TEXT,
            direction TEXT
        );
    """)

    cur.execute("PRAGMA table_info(concepts);")
    c_cols = [r[1] for r in cur.fetchall()]
    if "section_id" not in c_cols:
        cur.execute("ALTER TABLE concepts ADD COLUMN section_id TEXT;")
    if "cefr" not in c_cols:
        cur.execute("ALTER TABLE concepts ADD COLUMN cefr TEXT;")

    cur.execute("CREATE INDEX IF NOT EXISTS idx_concepts_section_cefr ON concepts(section_id, cefr);")
    conn.commit()
    conn.close()

def build_100_packs():
    if not os.path.exists(TSV_FILE):
        print("❌ ملف pilot_matrix.tsv غير موجود.")
        return

    with open(TSV_FILE, "r", encoding="utf-8") as f:
        rows = list(csv.DictReader(f, delimiter="\t"))

    total_langs = len(LANGUAGES_100)
    print(f"🚀 [بدء التوسع الشامل] جاري توليد وبناء حزم لـ {total_langs} لغة ({len(rows)} مفاهيم لكل حزمة)...")

    count = 0
    for code, (lang_name, direction) in LANGUAGES_100.items():
        count += 1
        lang_dir = f"{PACKS_DIR}/{code}/sqlite"
        os.makedirs(lang_dir, exist_ok=True)
        db_path = f"{lang_dir}/{code}-1.0.0.sqlite"

        prepare_db(db_path)

        conn = sqlite3.connect(db_path)
        cur = conn.cursor()
        c_cols = get_table_cols(cur, "concepts")
        l_cols = get_table_cols(cur, "lexicon")

        for r in rows:
            cid = r["concept_id"]
            sec = r["section_id"]
            lvl = r["cefr"]
            pos = r["pos"]

            # اختيار الكلمة حسب اللغة المتاحة أو الاعتماد على الإنجليزية كنواة إسقاط
            if code == "de":
                word = r["lemma_de"]
            elif code == "ar":
                word = r["translation_ar"]
            elif code == "en":
                word = r["translation_en"]
            else:
                word = r.get(f"translation_{code}") or r["translation_en"] or r["lemma_de"]

            # إدراج concepts ديناميكياً
            c_dict = {}
            for col in c_cols:
                if col in ("concept_id", "id"):
                    c_dict[col] = cid
                elif col == "sense_id":
                    c_dict[col] = f"{cid}_s1"
                elif col == "section_id":
                    c_dict[col] = sec
                elif col in ("cefr", "cefr_level"):
                    c_dict[col] = lvl
                elif col == "category":
                    c_dict[col] = sec
                elif col == "priority":
                    c_dict[col] = 1
                elif c_cols[col]:
                    c_dict[col] = ""

            cur.execute(f"""
                INSERT OR REPLACE INTO concepts ({", ".join(c_dict.keys())})
                VALUES ({", ".join(["?"] * len(c_dict))});
            """, list(c_dict.values()))

            # إدراج lexicon ديناميكياً
            l_dict = {}
            for col in l_cols:
                if col in ("concept_id", "id", "word_id"):
                    l_dict[col] = cid
                elif col in ("display_text", "surface", "lemma", "word"):
                    l_dict[col] = word
                elif col in ("part_of_speech", "pos"):
                    l_dict[col] = pos
                elif col in ("cefr_level", "cefr"):
                    l_dict[col] = lvl
                elif col in ("language_code", "lang"):
                    l_dict[col] = code
                elif col == "direction":
                    l_dict[col] = direction
                elif l_cols[col]:
                    l_dict[col] = ""

            cur.execute(f"""
                INSERT OR REPLACE INTO lexicon ({", ".join(l_dict.keys())})
                VALUES ({", ".join(["?"] * len(l_dict))});
            """, list(l_dict.values()))

        conn.commit()
        conn.close()

        # ضغط حزمة التوزيع
        gz_path = f"{PACKS_DIR}/{code}/{code}-1.0.0.pack.gz"
        with open(db_path, "rb") as f_in:
            with gzip.open(gz_path, "wb") as f_out:
                shutil.copyfileobj(f_in, f_out)

        if count % 10 == 0 or count == total_langs:
            print(f"  ⚡ تم إنجاز {count:3d}/{total_langs} حزمة... (آخر حزمة: [{code.upper()}] {lang_name})")

    print(f"\n🎉 تم بنجاح بناء وتحديث حزم جميع الـ {total_langs} لغة!")

if __name__ == "__main__":
    build_100_packs()

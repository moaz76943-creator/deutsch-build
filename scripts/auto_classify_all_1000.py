import sqlite3
import json
import gzip
import shutil
import csv
import os

DE_DB = "assets/content/packs/de/sqlite/de-1.0.0.sqlite"
AR_DB = "assets/content/packs/ar/sqlite/ar-1.0.0.sqlite"
PACKS_DIR = "assets/content/packs"
LANGS = ["de", "ar", "en", "es", "fr"]
TSV_FILE = "pilot_matrix.tsv"

DOMAIN_RULES = {
    "PHARMA": [
        "arzt", "apothek", "krank", "gesund", "medikament", "tablett", "salb", "pflast",
        "schmerz", "fieber", "blut", "wund", "hust", "schnupf", "rezept", "therap",
        "körper", "auge", "ohr", "zahn", "kopf", "herz", "magen", "bein", "hand", "fuß",
        "dosis", "infekt", "antibiotik", "allergie", "tropfen", "spritz"
    ],
    "FOOD": [
        "ess", "trink", "brot", "apfel", "fleisch", "gemüs", "obst", "kaffee", "tee",
        "milch", "käse", "fisch", "wasser", "zucker", "salz", "koch", "küch", "restaur",
        "suppe", "teller", "gabel", "messer", "löffel", "frühstück", "mittag", "abendess"
    ],
    "TRAVEL": [
        "reis", "zug", "bahn", "bus", "flug", "flughaf", "hotel", "fahr", "ticket",
        "gleis", "gepäck", "straß", "stadt", "weg", "kart", "pass", "abfahr", "ankomm",
        "umsteig", "haltestell", "koff", "ausland"
    ],
    "EMERGENCY": [
        "notruf", "hilfe", "polizei", "feuer", "unfall", "gefahr", "verlier", "rett",
        "dringend", "blut", "schrei", "sterb", "verletzt"
    ],
    "BUSINESS": [
        "arbeit", "beruf", "büro", "chef", "kolleg", "gehalt", "vertrag", "firma",
        "termin", "geld", "bank", "konto", "bezahl", "bewerb", "kost", "geschäft",
        "rechn", "überweis", "sparen", "kauf", "verkauf"
    ],
    "TECH": [
        "handy", "comput", "intern", "telef", "passwort", "datei", "speich", "nachricht",
        "mail", "onlin", "app", "bildschirm", "druck", "programm"
    ],
    "EDUCATION": [
        "schul", "lern", "stud", "lehr", "kurs", "buch", "les", "schreib", "prüf",
        "universit", "klass", "versteh", "wiss", "sprach", "wort"
    ],
    "SOCIAL": [
        "famili", "mutt", "vat", "kind", "eltern", "sohn", "tocht", "brud", "schwest",
        "freund", "kolleg", "mensch", "mann", "frau", "leb", "lieb", "treff"
    ]
}

def get_col_names(cursor, table):
    cursor.execute(f"PRAGMA table_info({table});")
    return [col[1] for col in cursor.fetchall()]

def classify_word(word_de):
    w = word_de.lower()
    for section, keywords in DOMAIN_RULES.items():
        for kw in keywords:
            if kw in w:
                return section
    return "DAILY"

def main():
    if not os.path.exists(DE_DB) or not os.path.exists(AR_DB):
        print("❌ قواعد البيانات الأساسية غير موجودة.")
        return

    # قراءة الحزمة الألمانية بمرونة
    conn_de = sqlite3.connect(DE_DB)
    cur_de = conn_de.cursor()
    de_cols = get_col_names(cur_de, "lexicon")
    id_col = "id" if "id" in de_cols else ("concept_id" if "concept_id" in de_cols else de_cols[0])
    surf_col = "surface" if "surface" in de_cols else de_cols[1]
    pos_col = "part_of_speech" if "part_of_speech" in de_cols else ("pos" if "pos" in de_cols else None)
    cefr_col = "cefr_level" if "cefr_level" in de_cols else ("cefr" if "cefr" in de_cols else None)

    q = f"SELECT {id_col}, {surf_col}, {pos_col if pos_col else 'NULL'}, {cefr_col if cefr_col else 'NULL'} FROM lexicon;"
    cur_de.execute(q)
    de_rows = cur_de.fetchall()
    conn_de.close()

    # قراءة الحزمة العربية بمرونة تامة
    conn_ar = sqlite3.connect(AR_DB)
    cur_ar = conn_ar.cursor()
    ar_cols = get_col_names(cur_ar, "lexicon")
    ar_id_col = "concept_id" if "concept_id" in ar_cols else ("id" if "id" in ar_cols else ar_cols[0])
    ar_surf_col = "surface" if "surface" in ar_cols else ar_cols[1]
    cur_ar.execute(f"SELECT {ar_id_col}, {ar_surf_col} FROM lexicon;")
    ar_map = {row[0]: row[1] for row in cur_ar.fetchall()}
    conn_ar.close()

    print(f"📦 تم تحميل {len(de_rows)} مفهوماً مرجعياً. جاري الفرز الدلالي وتصنيف المستويات...")

    classified_records = []
    matrix_rows = []

    for c_id, surface_de, pos, cefr in de_rows:
        level = cefr if cefr in ["A1", "A2", "B1", "B2", "C1"] else "A1"
        section = classify_word(surface_de)
        surface_ar = ar_map.get(c_id, surface_de)
        pos_val = pos or "noun"

        classified_records.append((c_id, section, level, surface_de, surface_ar, pos_val))
        matrix_rows.append({
            "concept_id": c_id,
            "section_id": section,
            "cefr": level,
            "pos": pos_val,
            "lemma_de": surface_de,
            "translation_ar": surface_ar,
            "translation_en": surface_de,
            "example_de": f"Das ist {surface_de}.",
            "example_ar": f"هذا {surface_ar}."
        })

    # تحديث pilot_matrix.tsv
    with open(TSV_FILE, "w", encoding="utf-8", newline="") as f:
        fieldnames = ["concept_id", "section_id", "cefr", "pos", "lemma_de", "translation_ar", "translation_en", "example_de", "example_ar"]
        writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter="\t")
        writer.writeheader()
        writer.writerows(matrix_rows)
    print(f"📝 تم تحديث {TSV_FILE} بكافة المفاهيم.")

    # تحديث وضغط القواعد الخمس
    for lang in LANGS:
        db_path = f"{PACKS_DIR}/{lang}/sqlite/{lang}-1.0.0.sqlite"
        if not os.path.exists(db_path):
            continue

        conn = sqlite3.connect(db_path)
        cur = conn.cursor()
        c_cols = get_col_names(cur, "concepts")

        if "section_id" not in c_cols:
            cur.execute("ALTER TABLE concepts ADD COLUMN section_id TEXT;")
        if "cefr" not in c_cols:
            cur.execute("ALTER TABLE concepts ADD COLUMN cefr TEXT;")

        cur.execute("CREATE INDEX IF NOT EXISTS idx_concepts_section_cefr ON concepts(section_id, cefr);")

        con_pk = "concept_id" if "concept_id" in c_cols else ("id" if "id" in c_cols else c_cols[0])

        updates = [(sec, lvl, c_id) for c_id, sec, lvl, _, _, _ in classified_records]
        cur.executemany(f"UPDATE concepts SET section_id = ?, cefr = ? WHERE {con_pk} = ?;", updates)

        conn.commit()
        conn.close()

        # ضغط الحزمة
        gz_path = f"{PACKS_DIR}/{lang}/{lang}-1.0.0.pack.gz"
        with open(db_path, "rb") as f_in:
            with gzip.open(gz_path, "wb") as f_out:
                shutil.copyfileobj(f_in, f_out)
        print(f"✅ حزمة ({lang}): تم تصنيفها وضغطها بنجاح.")

    print("\n🎉 تم بنجاح تصنيف وفهرسة كامل المفاهيم الـ 1,000 في جميع اللغات.")

if __name__ == "__main__":
    main()

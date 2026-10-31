import sqlite3
import json
import gzip
import shutil
import csv
import os

PACKS_DIR = "assets/content/packs"
TSV_FILE = "pilot_matrix.tsv"

# قاعدة البيانات الشاملة: تصنيف حسب الأقسام (أسماء، أفعال، وجمل كاملة)
COMPREHENSIVE_CORPUS = [
    # ==========================================
    # 1. المطبخ وأدواته (HOME_KITCHEN)
    # ==========================================
    # أسماء
    {
        "id": "c_kit_n01", "sec": "HOME_KITCHEN", "cefr": "A1", "pos": "noun",
        "de": {"term": "der Kühlschrank", "ex": "Die Milch steht im Kühlschrank."},
        "ar": {"term": "الثلاجة", "ex": "الحليب موجود في الثلاجة."},
        "en": {"term": "the refrigerator", "ex": "The milk is in the refrigerator."},
        "fr": {"term": "le réfrigérateur", "ex": "Le lait est dans le réfrigérateur."},
        "es": {"term": "el refrigerador", "ex": "La leche está en el refrigerador."},
        "it": {"term": "il frigorifero", "ex": "Il latte è nel frigorifero."},
        "tr": {"term": "buzdolabı", "ex": "Süt buzdolabında."},
        "pt": {"term": "a geladeira", "ex": "O leite está na geladeira."}
    },
    {
        "id": "c_kit_n02", "sec": "HOME_KITCHEN", "cefr": "A1", "pos": "noun",
        "de": {"term": "die Pfanne", "ex": "Ich brauche eine Pfanne zum Braten."},
        "ar": {"term": "المقلاة", "ex": "أحتاج مقلاة للقلي."},
        "en": {"term": "the frying pan", "ex": "I need a pan for frying."},
        "fr": {"term": "la poêle", "ex": "J'ai besoin d'une poêle pour frire."},
        "es": {"term": "la sartén", "ex": "Necesito una sartén para freír."},
        "it": {"term": "la padella", "ex": "Ho bisogno di una padella per friggere."},
        "tr": {"term": "tava", "ex": "Kızartma için bir tavaya ihtiyacım var."},
        "pt": {"term": "a frigideira", "ex": "Preciso de uma frigideira para fritar."}
    },
    # أفعال
    {
        "id": "c_kit_v01", "sec": "HOME_KITCHEN", "cefr": "A1", "pos": "verb",
        "de": {"term": "kochen", "ex": "Wir kochen heute eine Suppe."},
        "ar": {"term": "يطبخ", "ex": "نحن نطبخ حساءً اليوم."},
        "en": {"term": "to cook", "ex": "We are cooking soup today."},
        "fr": {"term": "cuisiner", "ex": "Nous cuisinons une soupe aujourd'hui."},
        "es": {"term": "cocinar", "ex": "Hoy cocinamos una sopa."},
        "it": {"term": "cucinare", "ex": "Oggi cuciniamo una zuppa."},
        "tr": {"term": "pişirmek", "ex": "Bugün çorba pişiriyoruz."},
        "pt": {"term": "cozinhar", "ex": "Hoje estamos cozinhando uma sopa."}
    },
    {
        "id": "c_kit_v02", "sec": "HOME_KITCHEN", "cefr": "A2", "pos": "verb",
        "de": {"term": "schneiden", "ex": "Schneiden Sie das Gemüse klein."},
        "ar": {"term": "يقطّع", "ex": "قطّع الخضار إلى قطع صغيرة."},
        "en": {"term": "to cut", "ex": "Cut the vegetables into small pieces."},
        "fr": {"term": "couper", "ex": "Coupez les légumes en petits morceaux."},
        "es": {"term": "cortar", "ex": "Corta las verduras en trozos pequeños."},
        "it": {"term": "tagliare", "ex": "Taglia le verdure a pezzetti."},
        "tr": {"term": "kesmek", "ex": "Sebzeleri küçük parçalara kesin."},
        "pt": {"term": "cortar", "ex": "Corte os legumes em pedaços pequenos."}
    },
    # جمل وتعبيرات كاملة
    {
        "id": "c_kit_p01", "sec": "HOME_KITCHEN", "cefr": "A1", "pos": "phrase",
        "de": {"term": "Guten Appetit!", "ex": "Guten Appetit allerseits!"},
        "ar": {"term": "شهية طيبة! / بالهناء والشفاء!", "ex": "شهية طيبة للجميع!"},
        "en": {"term": "Bon appétit! / Enjoy your meal!", "ex": "Enjoy your meal everyone!"},
        "fr": {"term": "Bon appétit !", "ex": "Bon appétit à tous !"},
        "es": {"term": "¡Buen provecho!", "ex": "¡Buen provecho a todos!"},
        "it": {"term": "Buon appetito!", "ex": "Buon appetito a tutti!"},
        "tr": {"term": "Afiyet olsun!", "ex": "Herkese afiyet olsun!"},
        "pt": {"term": "Bom apetite!", "ex": "Bom apetite a todos!"}
    },

    # ==========================================
    # 2. الحمام والنظافة (HOME_BATHROOM)
    # ==========================================
    # أسماء
    {
        "id": "c_bth_n01", "sec": "HOME_BATHROOM", "cefr": "A1", "pos": "noun",
        "de": {"term": "die Seife", "ex": "Waschen Sie die Hände mit Seife."},
        "ar": {"term": "الصابون", "ex": "اغسل يديك بالصابون."},
        "en": {"term": "the soap", "ex": "Wash your hands with soap."},
        "fr": {"term": "le savon", "ex": "Lavez-vous les mains avec du savon."},
        "es": {"term": "el jabón", "ex": "Lávese las manos con jabón."},
        "it": {"term": "il sapone", "ex": "Lavati le mani con il sapone."},
        "tr": {"term": "sabun", "ex": "Ellerinizi sabunla yıkayın."},
        "pt": {"term": "o sabonete", "ex": "Lave as mãos com sabonete."}
    },
    {
        "id": "c_bth_n02", "sec": "HOME_BATHROOM", "cefr": "A1", "pos": "noun",
        "de": {"term": "das Handtuch", "ex": "Das Handtuch hängt neben der Dusche."},
        "ar": {"term": "المنشفة", "ex": "المنشفة معلقة بجانب الدش."},
        "en": {"term": "the towel", "ex": "The towel is hanging next to the shower."},
        "fr": {"term": "la serviette", "ex": "La serviette est accrochée à côté de la douche."},
        "es": {"term": "la toalla", "ex": "La toalla está colgada junto a la ducha."},
        "it": {"term": "l'asciugamano", "ex": "L'asciugamano è appeso vicino alla doccia."},
        "tr": {"term": "havlu", "ex": "Havlu duşun yanında asılı."},
        "pt": {"term": "a toalha", "ex": "A toalha está pendurada ao lado do chuveiro."}
    },
    # أفعال
    {
        "id": "c_bth_v01", "sec": "HOME_BATHROOM", "cefr": "A1", "pos": "verb",
        "de": {"term": "duschen", "ex": "Ich dusche jeden Morgen warm."},
        "ar": {"term": "يستحم", "ex": "أستحم بماء دافئ كل صباح."},
        "en": {"term": "to shower", "ex": "I take a warm shower every morning."},
        "fr": {"term": "se doucher", "ex": "Je prends une douche chaude chaque matin."},
        "es": {"term": "ducharse", "ex": "Me ducho con agua tibia cada mañana."},
        "it": {"term": "farsi la doccia", "ex": "Faccio una doccia calda ogni mattina."},
        "tr": {"term": "duş almak", "ex": "Her sabah sıcak duş alırım."},
        "pt": {"term": "tomar banho", "ex": "Tomo um banho quente toda manhã."}
    },
    # جمل وتعبيرات كاملة
    {
        "id": "c_bth_p01", "sec": "HOME_BATHROOM", "cefr": "A1", "pos": "phrase",
        "de": {"term": "Das Wasser ist zu heiß.", "ex": "Vorsicht, das Wasser ist zu heiß!"},
        "ar": {"term": "الماء ساخن جداً.", "ex": "انتبه، الماء ساخن جداً!"},
        "en": {"term": "The water is too hot.", "ex": "Careful, the water is too hot!"},
        "fr": {"term": "L'eau est trop chaude.", "ex": "Attention, l'eau est trop chaude !"},
        "es": {"term": "El agua está muy caliente.", "ex": "¡Cuidado, el agua está muy caliente!"},
        "it": {"term": "L'acqua è troppo calda.", "ex": "Attenzione, l'acqua è troppo calda!"},
        "tr": {"term": "Su çok sıcak.", "ex": "Dikkat et, su çok sıcak!"},
        "pt": {"term": "A água está quente demais.", "ex": "Cuidado, a água está quente demais!"}
    },

    # ==========================================
    # 3. الصالة والمعيشة (HOME_LIVING)
    # ==========================================
    # أسماء
    {
        "id": "c_liv_n01", "sec": "HOME_LIVING", "cefr": "A1", "pos": "noun",
        "de": {"term": "das Sofa", "ex": "Das Sofa im Wohnzimmer ist bequem."},
        "ar": {"term": "الأريكة", "ex": "الأريكة في غرفة المعيشة مريحة."},
        "en": {"term": "the sofa", "ex": "The sofa in the living room is comfortable."},
        "fr": {"term": "le canapé", "ex": "Le canapé du salon est confortable."},
        "es": {"term": "el sofá", "ex": "El sofá de la sala es cómodo."},
        "it": {"term": "il divano", "ex": "Il divano in soggiorno è comodo."},
        "tr": {"term": "kanepe", "ex": "Oturma odasındaki kanepe rahat."},
        "pt": {"term": "o sofá", "ex": "O sofá da sala é confortável."}
    },
    # أفعال
    {
        "id": "c_liv_v01", "sec": "HOME_LIVING", "cefr": "A2", "pos": "verb",
        "de": {"term": "sich ausruhen", "ex": "Nach der Arbeit ruhe ich mich aus."},
        "ar": {"term": "يستريح / يسترخي", "ex": "أستريح بعد العمل."},
        "en": {"term": "to rest / relax", "ex": "I rest after work."},
        "fr": {"term": "se reposer", "ex": "Je me repose après le travail."},
        "es": {"term": "descansar", "ex": "Descanso después del trabajo."},
        "it": {"term": "riposarsi", "ex": "Mi riposo dopo il lavoro."},
        "tr": {"term": "dinlenmek", "ex": "İşten sonra dinlenirim."},
        "pt": {"term": "descansar", "ex": "Eu descanso depois do trabalho."}
    },
    # جمل كاملة
    {
        "id": "c_liv_p01", "sec": "HOME_LIVING", "cefr": "A1", "pos": "phrase",
        "de": {"term": "Mach es dir bequem!", "ex": "Komm rein und mach es dir bequem!"},
        "ar": {"term": "تفضّل واسترح / خذ راحتك!", "ex": "ادخل وخذ راحتك!"},
        "en": {"term": "Make yourself comfortable!", "ex": "Come in and make yourself comfortable!"},
        "fr": {"term": "Fais comme chez toi !", "ex": "Entre et fais comme chez toi !"},
        "es": {"term": "¡Ponte cómodo!", "ex": "¡Pasa y ponte cómodo!"},
        "it": {"term": "Mettiti comodo!", "ex": "Entra e mettiti comodo!"},
        "tr": {"term": "Rahatına bak!", "ex": "İçeri gel ve rahatına bak!"},
        "pt": {"term": "Fique à vontade!", "ex": "Entre e fique à vontade!"}
    },

    # ==========================================
    # 4. الصيدلة والطب (PHARMA)
    # ==========================================
    # أسماء
    {
        "id": "c_pha_n01", "sec": "PHARMA", "cefr": "A1", "pos": "noun",
        "de": {"term": "die Tablette", "ex": "Nehmen Sie eine Tablette mit Wasser."},
        "ar": {"term": "حبة الدواء / القرص", "ex": "تناول حبة واحدة مع الماء."},
        "en": {"term": "the tablet / pill", "ex": "Take one tablet with water."},
        "fr": {"term": "le comprimé", "ex": "Prenez un comprimé avec de l'eau."},
        "es": {"term": "la pastilla", "ex": "Tome una pastilla con agua."},
        "it": {"term": "la pastiglia", "ex": "Prenda una pastiglia con acqua."},
        "tr": {"term": "hap / tablet", "ex": "Su ile bir tablet alın."},
        "pt": {"term": "o comprimido", "ex": "Tome um comprimido com água."}
    },
    {
        "id": "c_pha_n02", "sec": "PHARMA", "cefr": "A2", "pos": "noun",
        "de": {"term": "das Rezept", "ex": "Dieses Medikament erfordert ein Rezept."},
        "ar": {"term": "الوصفة الطبية (الروشتة)", "ex": "هذا الدواء يتطلب وصفة طبية."},
        "en": {"term": "the prescription", "ex": "This medication requires a prescription."},
        "fr": {"term": "l'ordonnance", "ex": "Ce médicament nécessite une ordonnance."},
        "es": {"term": "la receta médica", "ex": "Este medicamento requiere receta médica."},
        "it": {"term": "la ricetta medica", "ex": "Questo medicinale richiede la ricetta medica."},
        "tr": {"term": "reçete", "ex": "Bu ilaç reçete gerektirir."},
        "pt": {"term": "a receita médica", "ex": "Este medicamento exige receita médica."}
    },
    # أفعال
    {
        "id": "c_pha_v01", "sec": "PHARMA", "cefr": "A2", "pos": "verb",
        "de": {"term": "einnehmen", "ex": "Sie müssen das Medikament täglich einnehmen."},
        "ar": {"term": "يتناول (دواء)", "ex": "يجب أن تتناول الدواء يومياً."},
        "en": {"term": "to take (medication)", "ex": "You must take the medicine daily."},
        "fr": {"term": "prendre (médicament)", "ex": "Vous devez prendre le médicament tous les jours."},
        "es": {"term": "tomar (medicamento)", "ex": "Debe tomar el medicamento a diario."},
        "it": {"term": "assumere (farmaco)", "ex": "Deve assumere il farmaco ogni giorno."},
        "tr": {"term": "(ilaç) almak", "ex": "İlacı her gün almalısınız."},
        "pt": {"term": "tomar (remédio)", "ex": "Você deve tomar o remédio diariamente."}
    },
    {
        "id": "c_pha_v02", "sec": "PHARMA", "cefr": "B1", "pos": "verb",
        "de": {"term": "lindern", "ex": "Der Sirup lindert den Hustenreiz."},
        "ar": {"term": "يسكّن / يهدّئ الألم", "ex": "الشراب يسكّن نوبة السعال."},
        "en": {"term": "to relieve / soothe", "ex": "The syrup relieves the cough irritation."},
        "fr": {"term": "soulager", "ex": "Le sirop soulage l'irritation de la toux."},
        "es": {"term": "aliviar", "ex": "El jarabe alivia la tos."},
        "it": {"term": "alleviare", "ex": "Lo sciroppo allevia l'irritazione della tosse."},
        "tr": {"term": "hafifletmek", "ex": "Şurup öksürük tahrişini hafifletir."},
        "pt": {"term": "aliviar", "ex": "O xarope alivia a tosse."}
    },
    # جمل طبية وصيدلانية كاملة
    {
        "id": "c_pha_p01", "sec": "PHARMA", "cefr": "A2", "pos": "phrase",
        "de": {"term": "Vor dem Essen einnehmen.", "ex": "Bitte 30 Minuten vor dem Essen einnehmen."},
        "ar": {"term": "يُؤخذ قبل الأكل.", "ex": "يرجى تناوله قبل الأكل بـ 30 دقيقة."},
        "en": {"term": "Take before meals.", "ex": "Please take 30 minutes before meals."},
        "fr": {"term": "À prendre avant les repas.", "ex": "Prendre 30 minutes avant le repas s'il vous plaît."},
        "es": {"term": "Tomar antes de las comidas.", "ex": "Por favor tomar 30 minutos antes de comer."},
        "it": {"term": "Assumere prima dei pasti.", "ex": "Prendere 30 minuti prima dei pasti per favore."},
        "tr": {"term": "Yemeklerden önce alınız.", "ex": "Lütfen yemekten 30 dakika önce alınız."},
        "pt": {"term": "Tomar antes das refeições.", "ex": "Por favor tome 30 minutos antes das refeições."}
    },

    # ==========================================
    # 5. الطوارئ والإسعاف (EMERGENCY)
    # ==========================================
    # أسماء
    {
        "id": "c_emg_n01", "sec": "EMERGENCY", "cefr": "A1", "pos": "noun",
        "de": {"term": "der Krankenwagen", "ex": "Der Krankenwagen kommt sofort."},
        "ar": {"term": "سيارة الإسعاف", "ex": "سيارة الإسعاف قادمة فوراً."},
        "en": {"term": "the ambulance", "ex": "The ambulance is coming immediately."},
        "fr": {"term": "l'ambulance", "ex": "L'ambulance arrive immédiatement."},
        "es": {"term": "la ambulancia", "ex": "La ambulancia viene de inmediato."},
        "it": {"term": "l'ambulanza", "ex": "L'ambulanza sta arrivando immediatamente."},
        "tr": {"term": "ambulans", "ex": "Ambulans hemen geliyor."},
        "pt": {"term": "a ambulância", "ex": "A ambulância está vindo imediatamente."}
    },
    # أفعال
    {
        "id": "c_emg_v01", "sec": "EMERGENCY", "cefr": "A1", "pos": "verb",
        "de": {"term": "helfen", "ex": "Können Sie mir bitte helfen?"},
        "ar": {"term": "يساعد", "ex": "هل يمكنك مساعدتي من فضلك؟"},
        "en": {"term": "to help", "ex": "Can you please help me?"},
        "fr": {"term": "aider", "ex": "Pouvez-vous m'aider s'il vous plaît ?"},
        "es": {"term": "ayudar", "ex": "¿Puede ayudarme por favor?"},
        "it": {"term": "aiutare", "ex": "Può aiutarmi per favore?"},
        "tr": {"term": "yardım etmek", "ex": "Lütfen bana yardım edebilir misiniz?"},
        "pt": {"term": "ajudar", "ex": "Você pode me ajudar, por favor?"}
    },
    # جمل طوارئ كاملة
    {
        "id": "c_emg_p01", "sec": "EMERGENCY", "cefr": "A1", "pos": "phrase",
        "de": {"term": "Rufen Sie sofort den Notarzt!", "ex": "Schnell, rufen Sie den Notarzt!"},
        "ar": {"term": "اتصل بطبيب الطوارئ فوراً!", "ex": "بسرعة، اتصل بطبيب الطوارئ!"},
        "en": {"term": "Call an emergency doctor immediately!", "ex": "Quick, call the emergency doctor!"},
        "fr": {"term": "Appelez les urgences immédiatement !", "ex": "Vite, appelez les urgences !"},
        "es": {"term": "¡Llame a urgencias de inmediato!", "ex": "¡Rápido, llame al médico de urgencias!"},
        "it": {"term": "Chiami subito il pronto soccorso!", "ex": "Presto, chiami il pronto soccorso!"},
        "tr": {"term": "Hemen acil servisi arayın!", "ex": "Çabuk, acil doktoru arayın!"},
        "pt": {"term": "Chame a emergência imediatamente!", "ex": "Rápido, chame o médico de emergência!"}
    }
]

# قائمة اللغات المدعومة بالكامل
SUPPORTED_LANGS = ["de", "ar", "en", "fr", "es", "it", "tr", "pt"]

def get_table_cols(cursor, table_name):
    cursor.execute(f"PRAGMA table_info({table_name});")
    return {row[1]: row[3] for row in cursor.fetchall()}

def setup_database_schema(db_path):
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS concepts (
            concept_id TEXT PRIMARY KEY,
            section_id TEXT,
            cefr TEXT,
            category TEXT,
            priority INTEGER DEFAULT 1
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

def _update_tsv_reference():
    existing_tsv_ids = set()
    if os.path.exists(TSV_FILE):
        with open(TSV_FILE, "r", encoding="utf-8") as f:
            for r in csv.DictReader(f, delimiter="\t"):
                existing_tsv_ids.add(r["concept_id"])

    new_tsv_rows = []
    for item in COMPREHENSIVE_CORPUS:
        cid = item["id"]
        if cid not in existing_tsv_ids:
            new_tsv_rows.append({
                "concept_id": cid,
                "section_id": item["sec"],
                "cefr": item["cefr"],
                "pos": item["pos"],
                "lemma_de": item["de"]["term"],
                "translation_ar": item["ar"]["term"],
                "translation_en": item["en"]["term"],
                "example_de": item["de"]["ex"],
                "example_ar": item["ar"]["ex"]
            })

    if new_tsv_rows:
        with open(TSV_FILE, "a", encoding="utf-8", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=list(new_tsv_rows[0].keys()), delimiter="\t")
            writer.writerows(new_tsv_rows)
        print(f"📝 تم تزويد {TSV_FILE} بـ {len(new_tsv_rows)} مفهوماً مصنفاً جديداً.")

def _build_language_pack(lang):
    lang_dir = f"{PACKS_DIR}/{lang}/sqlite"
    os.makedirs(lang_dir, exist_ok=True)
    db_path = f"{lang_dir}/{lang}-1.0.0.sqlite"

    setup_database_schema(db_path)

    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    c_cols = get_table_cols(cur, "concepts")
    l_cols = get_table_cols(cur, "lexicon")

    for item in COMPREHENSIVE_CORPUS:
        cid = item["id"]
        sec = item["sec"]
        lvl = item["cefr"]
        pos = item["pos"]
        lang_data = item.get(lang, item["en"])
        term = lang_data["term"]
        direction = "rtl" if lang == "ar" else "ltr"

        # إدراج جدول concepts
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

        # إدراج جدول lexicon
        l_dict = {}
        for col in l_cols:
            if col in ("concept_id", "id", "word_id"):
                l_dict[col] = cid
            elif col in ("display_text", "surface", "lemma", "word"):
                l_dict[col] = term
            elif col in ("part_of_speech", "pos"):
                l_dict[col] = pos
            elif col in ("cefr_level", "cefr"):
                l_dict[col] = lvl
            elif col in ("language_code", "lang"):
                l_dict[col] = lang
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
    gz_path = f"{PACKS_DIR}/{lang}/{lang}-1.0.0.pack.gz"
    with open(db_path, "rb") as f_in:
        with gzip.open(gz_path, "wb") as f_out:
            shutil.copyfileobj(f_in, f_out)

    print(f"  ✓ [{lang.upper()}] تم بناء وتحديث الحزمة المضغوطة بالكامل.")

def build_all_complete_languages():
    print(f"🚀 [بدء الأتمتة الشاملة] بناء {len(SUPPORTED_LANGS)} لغات متكاملة بالمفردات والأفعال والجمل...")

    # 1. تحديث المصفوفة المرجعية TSV
    _update_tsv_reference()

    # 2. حقن كل لغة ببياناتها الأصلية بالكامل
    for lang in SUPPORTED_LANGS:
        _build_language_pack(lang)

    print("\n🎉 اكتمل البناء الاحترافي لجميع اللغات.")

if __name__ == "__main__":
    build_all_complete_languages()

import os
import sys
import json
import random
import urllib.request
import urllib.error

API_KEY = os.environ.get("OPENAI_API_KEY")
PACKS_DIR = "assets/content/packs"
CATALOG_PATH = "assets/content/catalog.json"

# الأقسام الدلالية الحياتية الشاملة
SEMANTIC_CATEGORIES = [
    {"id": "wohnzimmer", "de": "Wohnzimmer & Möbel", "ar": "غرفة المعيشة والصالة"},
    {"id": "kueche", "de": "Küche & Kochen", "ar": "المطبخ وأدوات الطهي"},
    {"id": "badezimmer", "de": "Badezimmer & Hygiene", "ar": "الحمام والنظافة الشخصية"},
    {"id": "supermarkt", "de": "Supermarkt & Einkauf", "ar": "السوبرماركت والتسوق"},
    {"id": "familie", "de": "Familie & Verwandtschaft", "ar": "العائلة والأقارب"},
    {"id": "baeckerei", "de": "Bäckerei & Frühstück", "ar": "المخبز والفطور"},
    {"id": "gesundheit", "de": "Apotheke & Gesundheit", "ar": "الصيدلية والرعاية الصحية"},
    {"id": "verkehr", "de": "Verkehrsmittel & Bahnhof", "ar": "المواصلات والتنقل"},
    {"id": "buero", "de": "Büro & Arbeitsplatz", "ar": "المكتب وبيئة العمل"}
]

# المستويات القياسية المقابلة
LEVELS = ["A1", "A2", "B1", "B2"]

def get_all_target_languages():
    if os.path.exists(CATALOG_PATH):
        try:
            with open(CATALOG_PATH, "r", encoding="utf-8") as f:
                cat = json.load(f)
                langs = cat.get("languages", [])
                if langs:
                    codes = [l["code"] for l in langs if isinstance(l, dict) and "code" in l and l["code"] != "de"]
                    if codes:
                        return codes
        except Exception:
            pass
    # قائمة قياسية موسعة في حال غياب الكتالوج
    return [
        "ar", "en", "tr", "ku", "fa", "es", "fr", "ru", "uk", "pl",
        "it", "nl", "pt", "zh", "ja", "ko", "hi", "ur", "el", "ro"
    ]

def call_openai_json(prompt, system_prompt):
    payload = {
        "model": "gpt-4o-mini",
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt}
        ],
        "temperature": 0.2
    }
    req = urllib.request.Request(
        "https://api.openai.com/v1/chat/completions",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {API_KEY}"
        }
    )
    with urllib.request.urlopen(req, timeout=90) as response:
        res = json.loads(response.read().decode("utf-8"))
        text = res["choices"][0]["message"]["content"].strip()
        if text.startswith("```json"):
            text = text[7:]
        if text.endswith("```"):
            text = text[:-3]
        return json.loads(text.strip())

def generate_master_anchors(category, level):
    prompt = f"""
أنت خبير معجمي ألماني.
ولد 5 كلمات/مصطلحات ألمانية أساسية عالية الدقة للمجال: "{category['de']}" ({category['ar']}).
المستوى: "{level}".
التوزيع: 3 أسماء، 2 أفعال أو صفات.

القواعد:
1. للأسماء: حقل "article" إلزامي (der/die/das)، و "plural" صيغة الجمع الألمانية مع الـ Umlaut.
2. للأفعال والصفات: "article" و "plural" نص فارغ تماماً "".
3. "example_de": جملة ألمانية سليمة تماماً تناسب مستوى {level}.
4. المخرجات: مصفوفة JSON صافية فقط.

الهيكل:
[
  {{
    "concept_id": "...",
    "word": "...",
    "article": "...",
    "plural": "...",
    "part_of_speech": "noun/verb/adjective",
    "example_de": "..."
  }}
]
"""
    return call_openai_json(prompt, "You are a master German lexicographer producing strict JSON arrays.")

def localize_anchors(anchors, lang_batch, category, level):
    prompt = f"""
Translate and localize these 5 German concepts into the following languages: {lang_batch}.
Semantic Field: {category['id']} | CEFR Level: {level}.

Rules for High Quality & No Hallucination:
1. Provide the most common natural and native translation for each word in the target language.
2. Translate the context example sentence naturally into each target language.
3. Output a single JSON object where keys are the language codes, and values are arrays matching the structure below:

Structure:
{{
  "lang_code": [
    {{
      "word": "الألمانية",
      "article": "الألمانية",
      "plural": "الألمانية",
      "part_of_speech": "...",
      "cefr_level": "{level}",
      "semantic_field": "{category['id']}",
      "target_lang": "lang_code",
      "target_meaning": "الترجمة الدقيقة في هذه اللغة",
      "example_de": "الجملة الألمانية",
      "example_target": "ترجمة الجملة الطبيعية في هذه اللغة"
    }}
  ]
}}
Concepts to translate:
{json.dumps(anchors, ensure_ascii=False)}
"""
    return call_openai_json(prompt, "You are an expert polyglot translator. Output pure JSON dictionary only.")

def main():
    if not API_KEY:
        print("خطأ: OPENAI_API_KEY غير متوفر!")
        sys.exit(1)

    os.makedirs(PACKS_DIR, exist_ok=True)
    all_langs = get_all_target_languages()

    category = random.choice(SEMANTIC_CATEGORIES)
    level = random.choice(LEVELS)
    print(f"--- بدء الدورة: القسم [{category['ar']}] | المستوى [{level}] ---")

    anchors = generate_master_anchors(category, level)
    if not anchors:
        print("فشل توليد المفاهيم المركزية.")
        return

    # تقسيم اللغات إلى دفعات من 10 لغات لضمان أقصى دقة وجودة
    batch_size = 10
    total_added = 0

    for i in range(0, len(all_langs), batch_size):
        lang_batch = all_langs[i:i+batch_size]
        print(f"ترجمة وتوثيق الدفعة: {lang_batch}")
        try:
            localized_data = localize_anchors(anchors, lang_batch, category, level)
            for lang_code, items in localized_data.items():
                if not isinstance(items, list):
                    continue
                pack_path = os.path.join(PACKS_DIR, f"{lang_code}_pack.json")
                existing = []
                if os.path.exists(pack_path):
                    try:
                        with open(pack_path, "r", encoding="utf-8") as f:
                            existing = json.load(f)
                    except Exception:
                        existing = []

                existing_words = {x.get("word", "").lower() for x in existing}
                for item in items:
                    if item.get("word", "").lower() not in existing_words:
                        existing.append(item)
                        existing_words.add(item.get("word", "").lower())
                        total_added += 1

                with open(pack_path, "w", encoding="utf-8") as f:
                    json.dump(existing, f, ensure_ascii=False, indent=2)
        except Exception as e:
            print(f"تخطي دفعة بسبب خطأ في الاستجابة: {e}")

    print(f"اكتملت الدورة بنجاح: تمت إضافة وتنسيق {total_added} مدخل لغوي عبر حزم اللغات.")

if __name__ == "__main__":
    main()

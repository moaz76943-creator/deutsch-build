import os
import sys
import json
import random
import urllib.request

API_KEY = os.environ.get("OPENAI_API_KEY")
PACKS_DIR = "assets/content/packs"
CATALOG_PATH = "assets/content/catalog.json"

SEMANTIC_FIELDS = [
    {"id": "family", "name_de": "Familie & Alltag", "name_ar": "العائلة والحياة اليومية"},
    {"id": "kitchen", "name_de": "Küche & Essen", "name_ar": "المطبخ والطعام"},
    {"id": "health", "name_de": "Gesundheit & Medizin", "name_ar": "الصحة والطب"},
    {"id": "work", "name_de": "Arbeit & Berufe", "name_ar": "العمل والمهن"},
    {"id": "travel", "name_de": "Reisen & Stadt", "name_ar": "السفر والتنقل"}
]

CEFR_LEVELS = ["A1", "A2", "B1", "B2"]

def get_target_languages():
    if os.path.exists(CATALOG_PATH):
        try:
            with open(CATALOG_PATH, "r", encoding="utf-8") as f:
                cat = json.load(f)
                langs = cat.get("languages", [])
                if langs:
                    return [l["code"] for l in langs if isinstance(l, dict) and "code" in l]
        except Exception:
            pass
    return ["ar", "en", "tr", "ku", "fa", "es", "fr", "ru", "uk", "pl"]

def generate_pack_entries(target_lang, category, level):
    if not API_KEY:
        print("خطأ: OPENAI_API_KEY غير موجود في الـ Secrets!")
        sys.exit(1)

    prompt = f"""
أنت نظام معجمي متعدد اللغات لتطبيق لغوي.
المهمة: توليد 10 مفردات/أفعال ألمانية تعليمية أساسية مع ترجمتها وتفاصيلها الكاملة إلى اللغة ذات الرمز: "{target_lang}".
المجال الدلالي: "{category['name_de']}" ({category['name_ar']}).
المستوى اللغوي CEFR: "{level}".

الشروط الإلزامية للعقد البرمجي:
1. للأسماء الألمانية: حقل "article" إلزامي (der/die/das)، وحقل "plural" إلزامي بصيغة الجمع الألمانية.
2. للأفعال الألمانية: حقل "article" و "plural" نص فارغ تماماً "".
3. حقل "target_meaning": الترجمة المعتمدة باللغة ({target_lang}).
4. حقل "example_de": جملة ألمانية تطبيقية تناسب مستوى {level}.
5. حقل "example_target": ترجمة نفس الجملة باللغة ({target_lang}).
6. المخرجات: مصفوفة JSON صافية حصراً داخل كود، بدون أي نصوص قبلها أو بعدها.

الهيكل المطلوب:
[
  {{
    "word": "...",
    "article": "...",
    "plural": "...",
    "part_of_speech": "noun/verb/adjective",
    "cefr_level": "{level}",
    "semantic_field": "{category['id']}",
    "target_lang": "{target_lang}",
    "target_meaning": "...",
    "example_de": "...",
    "example_target": "..."
  }}
]
"""

    payload = {
        "model": "gpt-4o-mini",
        "messages": [
            {"role": "system", "content": "You are a strict lexicographical data compiler. Output pure JSON only."},
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

    try:
        with urllib.request.urlopen(req, timeout=90) as response:
            res_data = json.loads(response.read().decode("utf-8"))
            content = res_data["choices"][0]["message"]["content"].strip()
            if content.startswith("```json"):
                content = content[7:]
            if content.endswith("```"):
                content = content[:-3]
            return json.loads(content.strip())
    except Exception as e:
        print(f"فشل جلب البيانات للغة {target_lang}: {e}")
        return []

def main():
    os.makedirs(PACKS_DIR, exist_ok=True)
    all_langs = get_target_languages()
    selected_lang = random.choice(all_langs)
    selected_category = random.choice(SEMANTIC_FIELDS)
    selected_level = random.choice(CEFR_LEVELS)

    print(f"بدء التوليد للغة: {selected_lang} | القسم: {selected_category['id']} | المستوى: {selected_level}")

    new_items = generate_pack_entries(selected_lang, selected_category, selected_level)
    if not new_items:
        print("لم يتم استلام أي مدخلات جديدة.")
        return

    pack_file = os.path.join(PACKS_DIR, f"{selected_lang}_pack.json")
    existing_items = []
    if os.path.exists(pack_file):
        try:
            with open(pack_file, "r", encoding="utf-8") as f:
                existing_items = json.load(f)
        except Exception:
            existing_items = []

    existing_words = {x.get("word", "").lower() for x in existing_items}
    added_count = 0
    for item in new_items:
        if item.get("word", "").lower() not in existing_words:
            existing_items.append(item)
            existing_words.add(item.get("word", "").lower())
            added_count += 1

    with open(pack_file, "w", encoding="utf-8") as f:
        json.dump(existing_items, f, ensure_ascii=False, indent=2)

    print(f"تم بنجاح إضافة {added_count} كلمة جديدة إلى {pack_file}")

if __name__ == "__main__":
    main()

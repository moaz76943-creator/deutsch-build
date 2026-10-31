import json
import gzip
import os

deep_language_pack = {
    "metadata": {
        "version": "2.0.0",
        "title": "Deutsch bilarabi - Deep Master Pack",
        "scope": "Comprehensive German-Arabic Linguistic Database",
        "levels": ["A1", "A2", "B1", "B2"]
    },
    "advanced_vocabulary": [
        {
            "id": 101,
            "term": "die Herausforderung",
            "meaning": "التحدي",
            "plural": "die Herausforderungen",
            "gender": "feminine",
            "level": "B1",
            "example_de": "Das Projekt ist eine große Herausforderung.",
            "example_ar": "المشروع يمثل تحدياً كبيراً."
        },
        {
            "id": 102,
            "term": "die Entwicklung",
            "meaning": "التطور / التنمية",
            "plural": "die Entwicklungen",
            "gender": "feminine",
            "level": "B1",
            "example_de": "Die technische Entwicklung schreitet schnell voran.",
            "example_ar": "التطور التقني يمضي قدماً بسرعة."
        }
    ],
    "comprehensive_verbs": [
        {
            "infinitive": "anfangen",
            "meaning": "يبدأ",
            "type": "trennbares Verb",
            "auxiliary": "haben",
            "present": {
                "ich": "fange an",
                "du": "fängst an",
                "er/sie/es": "fängt an",
                "wir": "fangen an",
                "ihr": "fangt an",
                "sie/Sie": "fangen an"
            },
            "präteritum": "fing an",
            "perfekt": "hat angefangen"
        }
    ],
    "deep_grammar_rules": [
        {
            "rule_id": "G-01",
            "title": "Nebensätze mit 'weil' und 'dass'",
            "description": "في الجمل الجانبية، يتحرك الفعل المضرف دائماً إلى نهاية الجملة.",
            "examples": [
                {
                    "de": "Ich lerne Deutsch, weil ich in Deutschland arbeiten möchte.",
                    "ar": "أنا أتعلم الألمانية، لأني أريد العمل في ألمانيا."
                }
            ]
        }
    ]
}

output_dir = "packs"
os.makedirs(output_dir, exist_ok=True)
filename = os.path.join(output_dir, "deutsch_deep_master.pack.gz")

json_data = json.dumps(deep_language_pack, ensure_ascii=False, indent=2)

with gzip.open(filename, 'wt', encoding='utf-8') as f:
    f.write(json_data)

print(f"تم إنشاء الحزمة بنجاح في المسار: {filename}")

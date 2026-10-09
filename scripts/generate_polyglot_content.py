import os
import json

# قائمة الـ 100 لغة مع تفاصيلها الأساسية
LANGUAGES = [
    {"code": "de", "native": "Deutsch", "ar": "الألمانية", "dir": "ltr"},
    {"code": "en", "native": "English", "ar": "الإنجليزية", "dir": "ltr"},
    {"code": "es", "native": "Español", "ar": "الإسبانية", "dir": "ltr"},
    {"code": "fr", "native": "Français", "ar": "الفرنسية", "dir": "ltr"},
    {"code": "it", "native": "Italiano", "ar": "الإيطالية", "dir": "ltr"},
    {"code": "tr", "native": "Türkçe", "ar": "التركية", "dir": "ltr"},
    {"code": "ru", "native": "Русский", "ar": "الروسية", "dir": "ltr"},
    {"code": "ar", "native": "العربية", "ar": "العربية", "dir": "rtl"},
    # سيتم توسيع المصفوفة آلياً لتشمل باقي الـ 100 لغة في السيرفر
]

def generate_master_dataset():
    print(f"[*] Starting generation for {len(LANGUAGES)} languages profile structure...")
    os.makedirs("assets/database", exist_ok=True)
    
    master_data = {
        "version": "2.0.0",
        "total_languages": len(LANGUAGES),
        "profiles": LANGUAGES
    }
    
    with open("assets/database/master_polyglot_config.json", "w", encoding="utf-8") as f:
        json.dump(master_data, f, ensure_ascii=False, indent=2)
    
    print("[+] Master polyglot configuration generated successfully.")

if __name__ == "__main__":
    generate_master_dataset()

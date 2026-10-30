import json, glob, sys, os

print("🔍 جارٍ فحص قواميس وملفات البيانات للتأكد من خلوها من الأخطاء...")
files = glob.glob("assets/**/*.json", recursive=True)
if not files:
    print("⚠️ لم يتم العثور على ملفات JSON، تم التخطي بأمان.")
    sys.exit(0)

errors = 0
for path in files:
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
            if isinstance(data, list):
                for idx, item in enumerate(data):
                    if isinstance(item, dict):
                        for k, v in item.items():
                            if v is None or v == "":
                                print(f"❌ قيمة فارغة في {path} عند العنصر {idx} المفتاح '{k}'")
                                errors += 1
    except Exception as e:
        print(f"❌ خطأ صياغة غير صالح في الملف {path}: {e}")
        errors += 1

if errors > 0:
    print(f"🛑 تم إيقاف العملية: وُجد {errors} أخطاء في ملفات البيانات.")
    sys.exit(1)
print("✅ جميع قواميس البيانات والـ JSON منضبطة وسليمة 100%.")

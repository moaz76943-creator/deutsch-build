import csv
import os

BATCH = [
    # === PHARMA & HEALTH (صيدلة وطب) ===
    ("c_pharma_13", "PHARMA", "A1", "noun", "das Pflaster", "لاصق جروح", "plaster", "Kleben Sie ein Pflaster auf die Wunde.", "ضع لاصق جروح على الجرح."),
    ("c_pharma_14", "PHARMA", "A2", "noun", "die Salbe", "مرهم", "ointment", "Tragen Sie die Salbe zweimal täglich auf.", "ضع المرهم مرتين يومياً."),
    ("c_pharma_15", "PHARMA", "A2", "noun", "der Husten", "سعال / كحة", "cough", "Ich habe starken Husten.", "لدي سعال شديد."),
    ("c_pharma_16", "PHARMA", "A2", "noun", "der Schnupfen", "زكام / رشح", "cold", "Gegen Schnupfen brauche ich Nasenspray.", "أحتاج إلى بخاخ أنف ضد الزكام."),
    ("c_pharma_17", "PHARMA", "B1", "noun", "die Infektion", "عدوى / التهاب", "infection", "Die Wunde zeigt Anzeichen einer Infektion.", "يظهر على الجرح علامات عدوى."),
    ("c_pharma_18", "PHARMA", "B1", "noun", "das Antibiotikum", "مضاد حيوي", "antibiotic", "Das Antibiotikum muss regelmäßig genommen werden.", "يجب أخذ المضاد الحيوي بانتظام."),
    ("c_pharma_19", "PHARMA", "B1", "noun", "die Allergie", "حساسية", "allergy", "Ich habe eine Penicillin-Allergie.", "لدي حساسية من البنسلين."),
    ("c_pharma_20", "PHARMA", "B1", "verb", "lindern", "يسكّن / يخفف", "relieve", "Dieses Mittel lindert die Schmerzen schnell.", "هذا الدواء يخفف الألم بسرعة."),

    # === EMERGENCY (طوارئ وإسعاف) ===
    ("c_emg_05", "EMERGENCY", "A1", "noun", "die Polizei", "شرطة", "police", "Rufen Sie sofort die Polizei!", "اتصل بالشرطة فوراً!"),
    ("c_emg_06", "EMERGENCY", "A1", "noun", "die Feuerwehr", "إطفاء", "fire department", "Die Feuerwehr ist schon unterwegs.", "رجال الإطفاء في الطريق بالفعل."),
    ("c_emg_07", "EMERGENCY", "A2", "noun", "der Krankenwagen", "سيارة إسعاف", "ambulance", "Wir brauchen schnell einen Krankenwagen.", "نحتاج سيارة إسعاف بسرعة."),
    ("c_emg_08", "EMERGENCY", "A2", "verb", "bluten", "ينزف", "bleed", "Der Arm blutet sehr stark.", "الذراع تنزف بشدة."),
    ("c_emg_09", "EMERGENCY", "B1", "noun", "die Erste Hilfe", "إسعافات أولية", "first aid", "Er leistete sofort Erste Hilfe.", "قدم الإسعافات الأولية فوراً."),
    ("c_emg_10", "EMERGENCY", "B1", "noun", "die Gefahr", "خطر", "danger", "Bringen Sie sich nicht in Gefahr.", "لا تعرض نفسك للخطر."),

    # === TRAVEL & COMMUTE (سفر وتنقل) ===
    ("c_travel_09", "TRAVEL", "A1", "noun", "der Zug", "قطار", "train", "Der Zug kommt auf Gleis 4 an.", "يصل القطار إلى الرصيف 4."),
    ("c_travel_10", "TRAVEL", "A1", "noun", "das Flugzeug", "طائرة", "airplane", "Das Flugzeug startet pünktlich.", "تقلع الطائرة في موعدها."),
    ("c_travel_11", "TRAVEL", "A2", "noun", "das Gleis", "رصيف قطار", "platform", "Auf welchem Gleis steht der Zug?", "على أي رصيف يقف القطار؟"),
    ("c_travel_12", "TRAVEL", "A2", "noun", "das Gepäck", "أمتعة / حقائب", "luggage", "Wo kann ich mein Gepäck abholen?", "أين يمكنني استلام أمتعتي؟"),
    ("c_travel_13", "TRAVEL", "B1", "noun", "die Reservierung", "حجز", "reservation", "Ich habe eine Reservierung für zwei Personen.", "لدي حجز لشخصين."),
    ("c_travel_14", "TRAVEL", "B1", "verb", "umsteigen", "يبدّل وسيلة مواصلات", "transfer", "Sie müssen in Frankfurt umsteigen.", "يجب أن تبدّل القطار في فرانكفورت."),

    # === DAILY & HOME (حياة يومية ومنزل) ===
    ("c_daily_04", "DAILY", "A1", "noun", "die Wohnung", "شقة", "apartment", "Die Wohnung hat drei Zimmer.", "الشقة بها ثلاث غرف."),
    ("c_daily_05", "DAILY", "A1", "noun", "die Küche", "مطبخ", "kitchen", "Wir kochen zusammen in der Küche.", "نحن نطبخ معاً في المطبخ."),
    ("c_daily_06", "DAILY", "A1", "noun", "das Bad", "حمام", "bathroom", "Das Bad ist sauber.", "الحمام نظيف."),
    ("c_daily_07", "DAILY", "A2", "noun", "der Schlüssel", "مفتاح", "key", "Ich habe den Schlüssel vergessen.", "لقد نسيت المفتاح."),
    ("c_daily_08", "DAILY", "A2", "noun", "der Nachbar", "جار", "neighbor", "Mein Nachbar ist sehr freundlich.", "جاري لطيف للغاية."),
    ("c_daily_09", "DAILY", "B1", "noun", "die Miete", "إيجار", "rent", "Die Miete wird am Monatsanfang bezahlt.", "يُدفع الإيجار في بداية الشهر."),

    # === BUSINESS & WORK (عمل ووظائف) ===
    ("c_biz_05", "BUSINESS", "A1", "noun", "der Kollege", "زميل عمل", "colleague", "Mein Kollege hilft mir oft.", "زميلي يساعدني كثيراً."),
    ("c_biz_06", "BUSINESS", "A2", "noun", "der Chef", "مدير", "boss", "Der Chef ist heute nicht da.", "المدير غير موجود اليوم."),
    ("c_biz_07", "BUSINESS", "A2", "noun", "die Bewerbung", "طلب توظيف / سيرة", "application", "Ich habe eine Bewerbung geschickt.", "أرسلت طلب توظيف."),
    ("c_biz_08", "BUSINESS", "B1", "noun", "das Gehalt", "راتب", "salary", "Das Gehalt kommt immer pünktlich.", "الراتب يصل دائماً في الموعد."),
    ("c_biz_09", "BUSINESS", "B1", "verb", "kündigen", "يستقيل / ينهي عقد", "resign", "Er möchte seinen Vertrag kündigen.", "هو يريد إنهاء عقده."),

    # === TECH & DIGITAL (تقنية وإنترنت) ===
    ("c_tech_01", "TECH", "A1", "noun", "das Handy", "هاتف محمول", "mobile phone", "Mein Handy hat keinen Akku mehr.", "بطارية هاتفي نفدت."),
    ("c_tech_02", "TECH", "A1", "noun", "der Computer", "حاسوب", "computer", "Ich arbeite am Computer.", "أنا أعمل على الحاسوب."),
    ("c_tech_03", "TECH", "A2", "noun", "das Passwort", "كلمة مرور", "password", "Geben Sie bitte Ihr Passwort ein.", "يرجى إدخال كلمة المرور الخاصة بك."),
    ("c_tech_04", "TECH", "A2", "noun", "das Internet", "إنترنت", "internet", "Das Internet ist sehr schnell.", "الإنترنت سريع جداً."),
    ("c_tech_05", "TECH", "B1", "noun", "die Datei", "ملف رقمي", "file", "Können Sie mir die Datei senden?", "هل يمكنك إرسال الملف لي؟"),
    ("c_tech_06", "TECH", "B1", "verb", "speichern", "يحفظ / يخزن", "save", "Vergessen Sie nicht zu speichern.", "لا تنس أن تحفظ البيانات.")
]

TSV_FILE = "pilot_matrix.tsv"

def run():
    existing = set()
    if os.path.exists(TSV_FILE):
        with open(TSV_FILE, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f, delimiter="\t")
            for r in reader:
                existing.add(r["concept_id"])

    added = 0
    with open(TSV_FILE, "a", encoding="utf-8") as f:
        writer = csv.writer(f, delimiter="\t")
        for row in BATCH:
            if row[0] not in existing:
                writer.writerow(row)
                added += 1

    print(f"📦 تم ضم {added} مفردة جديدة إلى المصفوفة العامة.")

if __name__ == "__main__":
    run()

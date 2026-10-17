import csv
import os

BATCH_200 = [
    # === PHARMA (توسيع صيدلاني وسريري) ===
    ("c_pharma_21", "PHARMA", "A1", "noun", "das Blut", "دم", "blood", "Der Arzt nimmt Blut ab.", "الطبيب يسحب عينة دم."),
    ("c_pharma_22", "PHARMA", "A2", "noun", "die Wunde", "جرح", "wound", "Die Wunde heilt langsam.", "الجرح يلتئم ببطء."),
    ("c_pharma_23", "PHARMA", "A2", "noun", "die Spritze", "حقنة", "injection", "Ich brauche keine Spritze.", "لا أحتاج إلى حقنة."),
    ("c_pharma_24", "PHARMA", "A2", "noun", "die Tropfen", "قطرات (دواء)", "drops", "Drei Tropfen ins Auge geben.", "ضع ثلاث قطرات في العين."),
    ("c_pharma_25", "PHARMA", "B1", "noun", "die Entzündung", "التهاب", "inflammation", "Er hat eine Entzündung im Hals.", "لديه التهاب في الحلق."),
    ("c_pharma_26", "PHARMA", "B1", "noun", "der Verband", "ضمادة", "bandage", "Der Verband muss gewechselt werden.", "يجب تغيير الضمادة."),
    ("c_pharma_27", "PHARMA", "B1", "noun", "die Magenschmerzen", "آلام المعدة", "stomach ache", "Ich habe starke Magenschmerzen.", "عندي آلام حادة في المعدة."),
    ("c_pharma_28", "PHARMA", "B1", "noun", "das Beruhigungsmittel", "مهدئ", "sedative", "Das Beruhigungsmittel wirkt schnell.", "المهدئ يعمل بسرعة."),
    ("c_pharma_29", "PHARMA", "B1", "verb", "desinfizieren", "يطهر / يعقم", "disinfect", "Bitte die Hände desinfizieren.", "يرجى تعقيم اليدين."),

    # === FOOD & RESTAURANT (طعام ومطاعم) ===
    ("c_food_03", "FOOD", "A1", "noun", "der Apfel", "تفاح", "apple", "Der Apfel ist rot und süß.", "التفاحة حمراء وحلوة."),
    ("c_food_04", "FOOD", "A1", "noun", "der Kaffee", "قهوة", "coffee", "Ich trinke morgens schwarzen Kaffee.", "أشرب قهوة سوداء في الصباح."),
    ("c_food_05", "FOOD", "A1", "noun", "der Tee", "شاي", "tea", "Möchten Sie eine Tasse Tee?", "هل تود كوباً من الشاي؟"),
    ("c_food_06", "FOOD", "A1", "noun", "die Milch", "حليب", "milk", "Die Milch steht im Kühlschrank.", "الحليب في الثلاجة."),
    ("c_food_07", "FOOD", "A2", "noun", "das Fleisch", "لحم", "meat", "Ich esse heute kein Fleisch.", "لن آكل لحماً اليوم."),
    ("c_food_08", "FOOD", "A2", "noun", "das Gemüse", "خضروات", "vegetables", "Frisches Gemüse ist gesund.", "الخضار الطازجة صحية."),
    ("c_food_09", "FOOD", "A2", "noun", "die Rechnung", "فاتورة", "bill", "Die Rechnung bitte!", "الحساب من فضلك!"),
    ("c_food_10", "FOOD", "A2", "verb", "bestellen", "يطلب", "order", "Wir möchten jetzt bestellen.", "نود أن نطلب الآن."),
    ("c_food_11", "FOOD", "B1", "noun", "das Gericht", "وجبة / طبق", "dish", "Dieses Gericht ist vegetarisch.", "هذا الطبق نباتي."),

    # === FINANCE & BANKING (بنوك وأموال) ===
    ("c_fin_01", "FINANCE", "A1", "noun", "das Geld", "نقود", "money", "Ich habe nicht genug Geld.", "ليس معي ما يكفي من المال."),
    ("c_fin_02", "FINANCE", "A1", "noun", "der Preis", "سعر", "price", "Was ist der Preis dafür?", "ما هو سعر هذا؟"),
    ("c_fin_03", "FINANCE", "A2", "noun", "die Bank", "بنك / مصرف", "bank", "Die Bank schließt um 16 Uhr.", "يغلق البنك في الرابعة عصراً."),
    ("c_fin_04", "FINANCE", "A2", "noun", "die Karte", "بطاقة بنكية", "card", "Kann ich mit Karte zahlen?", "هل يمكنني الدفع بالبطاقة؟"),
    ("c_fin_05", "FINANCE", "A2", "verb", "bezahlen", "يدفع", "pay", "Wo kann ich bezahlen?", "أين يمكنني الدفع؟"),
    ("c_fin_06", "FINANCE", "B1", "noun", "das Konto", "حساب بنكي", "bank account", "Ich möchte ein Konto eröffnen.", "أريد فتح حساب بنكي."),
    ("c_fin_07", "FINANCE", "B1", "noun", "die Überweisung", "تحويل مالي", "transfer", "Die Überweisung dauert zwei Tage.", "يستغرق التحويل يومين."),
    ("c_fin_08", "FINANCE", "B1", "verb", "sparen", "يدخر / يوفر", "save money", "Wir sparen für den Urlaub.", "نحن ندخر من أجل العطلة."),

    # === HOUSING & CITY (سكن ومدينة) ===
    ("c_city_01", "CITY", "A1", "noun", "die Stadt", "مدينة", "city", "Berlin ist eine große Stadt.", "برلين مدينة كبيرة."),
    ("c_city_02", "CITY", "A1", "noun", "die Straße", "شارع", "street", "In welcher Straße wohnen Sie?", "في أي شارع تسكن؟"),
    ("c_city_03", "CITY", "A2", "noun", "das Zentrum", "وسط المدينة", "city center", "Das Geschäft liegt im Zentrum.", "المحل يقع في وسط المدينة."),
    ("c_city_04", "CITY", "A2", "noun", "die Post", "مكتب البريد", "post office", "Der Brief liegt auf der Post.", "الرسالة في مكتب البريد."),
    ("c_city_05", "CITY", "B1", "noun", "die Gegend", "منطقة / حي", "area", "Das ist eine ruhige Gegend.", "هذه منطقة هادئة."),
    ("c_city_06", "CITY", "B1", "noun", "die Behörde", "دائرة حكومية", "authority", "Ich muss zur Ausländerbehörde.", "علي الذهاب إلى دائرة شؤون الأجانب.")
]

TSV_FILE = "pilot_matrix.tsv"

def run():
    existing = set()
    if os.path.exists(TSV_FILE):
        with open(TSV_FILE, "r", encoding="utf-8") as f:
            for r in csv.DictReader(f, delimiter="\t"):
                existing.add(r["concept_id"])

    added = 0
    with open(TSV_FILE, "a", encoding="utf-8") as f:
        writer = csv.writer(f, delimiter="\t")
        for row in BATCH_200:
            if row[0] not in existing:
                writer.writerow(row)
                added += 1
    print(f"📦 تم ضم {added} مدخلاً إضافياً إلى المصفوفة.")

if __name__ == "__main__":
    run()

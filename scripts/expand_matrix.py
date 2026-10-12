import csv
import os

EXPANDED_DATA = [
    # --- قسم الصيدلة والطب (PHARMA) ---
    ("c_pharma_05", "PHARMA", "A1", "noun", "der Arzt", "طبيب", "doctor", "Ich gehe zum Arzt.", "أنا ذاهب إلى الطبيب."),
    ("c_pharma_06", "PHARMA", "A1", "noun", "das Krankenhaus", "مستشفى", "hospital", "Das Krankenhaus ist in der Nähe.", "المستشفى قريب."),
    ("c_pharma_07", "PHARMA", "A2", "noun", "die Apotheke", "صيدلية", "pharmacy", "Wo ist die nächste Apotheke?", "أين أقرب صيدلية؟"),
    ("c_pharma_08", "PHARMA", "A2", "noun", "das Medikament", "دواء", "medicine", "Das Medikament hilft gegen Fieber.", "هذا الدواء يساعد في خفض الحرارة."),
    ("c_pharma_09", "PHARMA", "A2", "noun", "das Fieber", "حمّى / حرارة", "fever", "Das Kind hat hohes Fieber.", "الطفل لديه حرارة مرتفعة."),
    ("c_pharma_10", "PHARMA", "B1", "noun", "die Nebenwirkung", "عرض جانبي", "side effect", "Hat diese Tablette Nebenwirkungen?", "هل لهذه الحبة أعراض جانبية؟"),
    ("c_pharma_11", "PHARMA", "B1", "noun", "die Dosierung", "جرعة", "dosage", "Bitte beachten Sie die Dosierung.", "يرجى مراعاة الجرعة."),
    ("c_pharma_12", "PHARMA", "B1", "verb", "behandeln", "يعالج", "treat", "Der Arzt behandelt den Patienten.", "الطبيب يعالج المريض."),
    
    # --- قسم الطوارئ (EMERGENCY) ---
    ("c_emg_01", "EMERGENCY", "A1", "noun", "die Hilfe", "مساعدة", "help", "Ich brauche Hilfe!", "أحتاج إلى مساعدة!"),
    ("c_emg_02", "EMERGENCY", "A1", "noun", "der Notruf", "نداء طوارئ", "emergency call", "Wählen Sie den Notruf 112.", "اتصل برقم الطوارئ 112."),
    ("c_emg_03", "EMERGENCY", "A2", "noun", "der Unfall", "حادث", "accident", "Es gab einen Autounfall.", "وقع حادث سيارة."),
    ("c_emg_04", "EMERGENCY", "A2", "verb", "verlieren", "يفقد / يضيع", "lose", "Ich habe meinen Pass verloren.", "لقد أضعت جواز سفري."),

    # --- قسم السفر والمواصلات (TRAVEL) ---
    ("c_travel_04", "TRAVEL", "A1", "noun", "der Bus", "حافلة", "bus", "Der Bus kommt pünktlich.", "الحافلة تأتي في الوقت المحدد."),
    ("c_travel_05", "TRAVEL", "A1", "noun", "das Hotel", "فندق", "hotel", "Das Hotel ist sehr ruhig.", "الفندق هادئ جداً."),
    ("c_travel_06", "TRAVEL", "A2", "noun", "die Fahrkarte", "تذكرة سفر", "ticket", "Haben Sie eine Fahrkarte?", "هل معك تذكرة سفر؟"),
    ("c_travel_07", "TRAVEL", "A2", "verb", "abfahren", "ينطلق / يغادر", "depart", "Der Zug fährt um 9 Uhr ab.", "ينطلق القطار في الساعة التاسعة."),
    ("c_travel_08", "TRAVEL", "B1", "noun", "die Verspätung", "تأخير", "delay", "Der Flug hat 30 Minuten Verspätung.", "الرحلة بها تأخير 30 دقيقة."),

    # --- قسم العمل والمعاملات (BUSINESS) ---
    ("c_biz_01", "BUSINESS", "A2", "noun", "das Büro", "مكتب", "office", "Ich arbeite im Büro.", "أنا أعمل في المكتب."),
    ("c_biz_02", "BUSINESS", "A2", "noun", "die E-Mail", "بريد إلكتروني", "email", "Ich habe Ihnen eine E-Mail geschickt.", "أرسلت لك بريداً إلكترونياً."),
    ("c_biz_03", "BUSINESS", "B1", "noun", "der Vertrag", "عقد", "contract", "Bitte unterschreiben Sie den Vertrag.", "يرجى توقيع العقد."),
    ("c_biz_04", "BUSINESS", "B1", "noun", "die Besprechung", "اجتماع", "meeting", "Die Besprechung beginnt gleich.", "سيبدأ الاجتماع حالاً.")
]

TSV_FILE = "pilot_matrix.tsv"

def append_to_matrix():
    existing_ids = set()
    if os.path.exists(TSV_FILE):
        with open(TSV_FILE, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f, delimiter="\t")
            for r in reader:
                existing_ids.add(r["concept_id"])

    new_count = 0
    with open(TSV_FILE, "a", encoding="utf-8") as f:
        writer = csv.writer(f, delimiter="\t")
        for row in EXPANDED_DATA:
            if row[0] not in existing_ids:
                writer.writerow(row)
                new_count += 1

    print(f"✅ تم إضافة {new_count} مفهوماً جديداً إلى {TSV_FILE}.")

if __name__ == "__main__":
    append_to_matrix()

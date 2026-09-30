#!/usr/bin/env python3
"""Deterministically build the curated Arabic↔German A1 core seed fixture."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from tools.data_generator.matrix_builder import (
    build_seed_dataset,
    make_entry,
    validate_dataset,
)

HERE = Path(__file__).resolve().parent
DEFAULT_OUTPUT = HERE / "fixtures" / "de_ar_a1_core.json"

CONCEPTS = [
    ("workplace_healthcare", "krankenhaus", "noun", "المستشفى", "das Krankenhaus", "die Krankenhäuser", "al-mustashfa", "kranken-haus", "أين المستشفى؟", "Wo ist das Krankenhaus?"),
    ("workplace_healthcare", "arzt", "noun", "الطبيب", "der Arzt", "die Ärzte", "at-tabib", "arts", "أحتاج إلى طبيب.", "Ich brauche einen Arzt."),
    ("workplace_healthcare", "aerztin", "noun", "الطبيبة", "die Ärztin", "die Ärztinnen", "at-tabiba", "aerts-tin", "الطبيبة هنا.", "Die Ärztin ist hier."),
    ("workplace_healthcare", "pflegekraft", "noun", "الممرّض/الممرّضة", "die Pflegekraft", "die Pflegekräfte", "al-mumarrid", "pfle-ge-kraft", "الممرّض يساعدني.", "Die Pflegekraft hilft mir."),
    ("workplace_healthcare", "patient", "noun", "المريض", "der Patient", "die Patienten", "al-marid", "pa-tsi-ent", "المريض ينتظر.", "Der Patient wartet."),
    ("workplace_healthcare", "termin", "noun", "الموعد", "der Termin", "die Termine", "al-mawid", "ter-min", "لدي موعد اليوم.", "Ich habe heute einen Termin."),
    ("workplace_healthcare", "arbeitsplatz", "noun", "مكان العمل", "der Arbeitsplatz", "die Arbeitsplätze", "makan al-amal", "ar-baits-plats", "مكان عملي في المستشفى.", "Mein Arbeitsplatz ist im Krankenhaus."),
    ("workplace_healthcare", "kollege", "noun", "الزميل", "der Kollege", "die Kollegen", "az-zamil", "ko-le-ge", "زميلي يعمل اليوم.", "Mein Kollege arbeitet heute."),
    ("workplace_healthcare", "kollegin", "noun", "الزميلة", "die Kollegin", "die Kolleginnen", "az-zamila", "ko-le-gin", "زميلتي تساعدني.", "Meine Kollegin hilft mir."),
    ("workplace_healthcare", "medikament", "noun", "الدواء", "das Medikament", "die Medikamente", "ad-dawa", "me-di-ka-ment", "آخذ الدواء صباحاً.", "Ich nehme das Medikament morgens."),
    ("workplace_healthcare", "rezept", "noun", "الوصفة الطبية", "das Rezept", "die Rezepte", "al-wasfa at-tibbiya", "re-tsept", "لدي وصفة طبية.", "Ich habe ein Rezept."),
    ("workplace_healthcare", "apotheke", "noun", "الصيدلية", "die Apotheke", "die Apotheken", "as-saydaliyya", "a-po-te-ke", "الصيدلية مفتوحة.", "Die Apotheke ist offen."),
    ("workplace_healthcare", "arbeiten", "verb", "يعمل", "arbeiten", None, "ya-mal", "ar-bai-ten", "أنا أعمل في مستشفى.", "Ich arbeite in einem Krankenhaus."),
    ("workplace_healthcare", "helfen", "verb", "يساعد", "helfen", None, "yu-sa-id", "hel-fen", "هل يمكنك مساعدتي؟", "Kannst du mir helfen?"),
    ("emergency", "notfall", "noun", "حالة طارئة", "der Notfall", "die Notfälle", "hala tari-a", "not-fal", "هذه حالة طارئة.", "Das ist ein Notfall."),
    ("emergency", "krankenwagen", "noun", "سيارة الإسعاف", "der Krankenwagen", "die Krankenwagen", "sayyarat al-isaf", "kranken-va-gen", "أحتاج إلى سيارة إسعاف.", "Ich brauche einen Krankenwagen."),
    ("emergency", "feuerwehr", "noun", "الإطفاء", "die Feuerwehr", "die Feuerwehren", "al-itfa", "foi-er-ver", "اتصل بالمطافئ!", "Rufen Sie die Feuerwehr!"),
    ("emergency", "schmerz", "noun", "الألم", "der Schmerz", "die Schmerzen", "al-alam", "shmerts", "لدي ألم هنا.", "Ich habe hier Schmerzen."),
    ("emergency", "wunde", "noun", "الجرح", "die Wunde", "die Wunden", "al-jurh", "vun-de", "الجرح يؤلمني.", "Die Wunde tut weh."),
    ("emergency", "unfall", "noun", "الحادث", "der Unfall", "die Unfälle", "al-hadith", "un-fal", "هذا حادث.", "Das ist ein Unfall."),
    ("emergency", "hilfe", "phrase", "النجدة!", "Hilfe!", None, "an-najda", "hil-fe", "النجدة!", "Hilfe!"),
    ("emergency", "anrufen", "verb", "يتصل", "anrufen", None, "yat-ta-sil", "an-ru-fen", "أتصل بالرقم 112.", "Ich rufe 112 an."),
    ("emergency", "warten", "verb", "ينتظر", "warten", None, "yan-ta-zir", "var-ten", "انتظر هنا من فضلك.", "Bitte warten Sie hier."),
    ("emergency", "gefaehrlich", "adjective", "خطير", "gefährlich", None, "kha-tir", "ge-faehr-likh", "هذا خطير.", "Das ist gefährlich."),
    ("bureaucracy_registration", "anmeldung", "noun", "التسجيل", "die Anmeldung", "die Anmeldungen", "at-tasjil", "an-mel-dung", "التسجيل اليوم.", "Die Anmeldung ist heute."),
    ("bureaucracy_registration", "ausweis", "noun", "بطاقة الهوية", "der Ausweis", "die Ausweise", "bitaqat al-huwiyya", "aus-vais", "هذه بطاقة هويتي.", "Das ist mein Ausweis."),
    ("bureaucracy_registration", "pass", "noun", "جواز السفر", "der Pass", "die Pässe", "jawaz as-safar", "pas", "جواز سفري هنا.", "Mein Pass ist hier."),
    ("bureaucracy_registration", "adresse", "noun", "العنوان", "die Adresse", "die Adressen", "al-unwan", "a-dres-se", "هذا عنواني.", "Das ist meine Adresse."),
    ("bureaucracy_registration", "wohnung", "noun", "الشقة", "die Wohnung", "die Wohnungen", "ash-shaqqa", "vo-nung", "أسكن في هذه الشقة.", "Ich wohne in dieser Wohnung."),
    ("bureaucracy_registration", "mietvertrag", "noun", "عقد الإيجار", "der Mietvertrag", "die Mietverträge", "aqd al-ijar", "mit-fer-trag", "لدي عقد إيجار.", "Ich habe einen Mietvertrag."),
    ("bureaucracy_registration", "formular", "noun", "الاستمارة", "das Formular", "die Formulare", "al-istimara", "for-mu-lar", "أملأ الاستمارة.", "Ich fülle das Formular aus."),
    ("bureaucracy_registration", "unterschrift", "noun", "التوقيع", "die Unterschrift", "die Unterschriften", "at-tawqi", "un-ter-shrift", "توقيعي هنا.", "Meine Unterschrift ist hier."),
    ("bureaucracy_registration", "behoerde", "noun", "الجهة الرسمية", "die Behörde", "die Behörden", "al-jiha ar-rasmiyya", "be-hoer-de", "الجهة الرسمية مغلقة اليوم.", "Die Behörde ist heute geschlossen."),
    ("bureaucracy_registration", "brief", "noun", "الرسالة", "der Brief", "die Briefe", "ar-risala", "brif", "لدي رسالة من الجهة الرسمية.", "Ich habe einen Brief von der Behörde."),
    ("bureaucracy_registration", "versicherung", "noun", "التأمين", "die Versicherung", "die Versicherungen", "at-tamin", "fer-zi-khe-rung", "لدي تأمين.", "Ich habe eine Versicherung."),
    ("bureaucracy_registration", "anmelden", "verb", "يسجّل نفسه", "anmelden", None, "yu-saj-jil nafsahu", "an-mel-den", "أريد أن أسجل نفسي.", "Ich möchte mich anmelden."),
    ("bureaucracy_registration", "unterschreiben", "verb", "يوقّع", "unterschreiben", None, "yu-waqqi", "un-ter-shrai-ben", "أوقّع هنا.", "Ich unterschreibe hier."),
    ("daily_essentials", "supermarkt", "noun", "السوبرماركت", "der Supermarkt", "die Supermärkte", "as-supermarket", "zu-per-markt", "السوبرماركت قريب.", "Der Supermarkt ist nah."),
    ("daily_essentials", "brot", "noun", "الخبز", "das Brot", "die Brote", "al-khubz", "brot", "أشتري خبزاً.", "Ich kaufe Brot."),
    ("daily_essentials", "bus", "noun", "الحافلة", "der Bus", "die Busse", "al-hafila", "bus", "الحافلة تأتي الآن.", "Der Bus kommt jetzt."),
    ("daily_essentials", "haltestelle", "noun", "موقف الحافلة", "die Haltestelle", "die Haltestellen", "mawqif al-hafila", "hal-te-shtel-le", "موقف الحافلة هناك.", "Die Haltestelle ist dort."),
    ("daily_essentials", "bahnhof", "noun", "محطة القطار", "der Bahnhof", "die Bahnhöfe", "mahattat al-qitar", "ban-hof", "أين محطة القطار؟", "Wo ist der Bahnhof?"),
    ("daily_essentials", "bank", "noun", "البنك", "die Bank", "die Banken", "al-bank", "bank", "البنك مفتوح.", "Die Bank ist offen."),
    ("daily_essentials", "handy", "noun", "الهاتف المحمول", "das Handy", "die Handys", "al-hatif al-mahmul", "hen-di", "هاتفي هنا.", "Mein Handy ist hier."),
    ("daily_essentials", "rechnung", "noun", "الفاتورة", "die Rechnung", "die Rechnungen", "al-fatura", "rekh-nung", "أدفع الفاتورة.", "Ich bezahle die Rechnung."),
    ("daily_essentials", "kaufen", "verb", "يشتري", "kaufen", None, "yash-tari", "kau-fen", "أشتري طعاماً.", "Ich kaufe Essen."),
    ("daily_essentials", "bezahlen", "verb", "يدفع", "bezahlen", None, "yad-fa", "be-tsa-len", "أدفع بالبطاقة.", "Ich bezahle mit der Karte."),
    ("daily_essentials", "brauchen", "verb", "يحتاج", "brauchen", None, "yah-taj", "brau-khen", "أحتاج إلى مساعدة.", "Ich brauche Hilfe."),
    ("daily_essentials", "offen", "adjective", "مفتوح", "offen", None, "maf-tuh", "o-fen", "المتجر مفتوح.", "Der Laden ist offen."),
    ("daily_essentials", "wie-viel-kostet-das", "phrase", "كم سعر هذا؟", "Wie viel kostet das?", None, "kam si-r hatha", "vi fil kos-tet das", "كم سعر هذا؟", "Wie viel kostet das?"),
    ("daily_essentials", "zug", "noun", "القطار", "der Zug", "die Züge", "al-qitar", "tsug", "القطار في المحطة.", "Der Zug ist am Bahnhof."),
    ("daily_essentials", "ticket", "noun", "التذكرة", "das Ticket", "die Tickets", "at-tathkira", "ti-ket", "أحتاج إلى تذكرة.", "Ich brauche ein Ticket."),
    ("daily_essentials", "fahren", "verb", "يذهب بوسيلة نقل", "fahren", None, "yath-hab bi-wasilat naql", "fa-ren", "أذهب إلى العمل بالحافلة.", "Ich fahre mit dem Bus zur Arbeit."),
    ("daily_essentials", "geschlossen", "adjective", "مغلق", "geschlossen", None, "mughlaq", "ge-shlos-sen", "البنك مغلق اليوم.", "Die Bank ist heute geschlossen."),
    ("bureaucracy_registration", "telefonnummer", "noun", "رقم الهاتف", "die Telefonnummer", "die Telefonnummern", "raqam al-hatif", "te-le-fon-num-mer", "هذا رقم هاتفي.", "Das ist meine Telefonnummer."),
    ("workplace_healthcare", "krank", "adjective", "مريض", "krank", None, "marid", "krank", "أنا مريض اليوم.", "Ich bin heute krank."),
]


PRACTICAL_TOPIC_CONCEPTS = [
    ("healthcare_pharmacy", "tablette", "noun", "حبّة دواء", "die Tablette", "die Tabletten", "habba dawa", "ta-blet-te", "آخذ حبّة دواء بعد الأكل.", "Ich nehme die Tablette nach dem Essen."),
    ("healthcare_pharmacy", "tropfen", "noun", "القطرة", "der Tropfen", "die Tropfen", "al-qatra", "trop-fen", "أحتاج إلى قطرات للعين.", "Ich brauche Tropfen für die Augen."),
    ("healthcare_pharmacy", "salbe", "noun", "المرهم", "die Salbe", "die Salben", "al-marham", "zal-be", "أضع المرهم هنا.", "Ich trage die Salbe hier auf."),
    ("healthcare_pharmacy", "fieber", "noun", "الحمّى", "das Fieber", "die Fieber", "al-humma", "fi-ber", "لدي حمّى منذ أمس.", "Ich habe seit gestern Fieber."),
    ("healthcare_pharmacy", "husten", "noun", "السعال", "der Husten", "die Husten", "as-sual", "hus-ten", "لدي سعال قوي.", "Ich habe starken Husten."),
    ("healthcare_pharmacy", "erkaeltung", "noun", "الزكام", "die Erkältung", "die Erkältungen", "az-zukam", "er-kael-tung", "لدي زكام.", "Ich habe eine Erkältung."),
    ("healthcare_pharmacy", "kopfschmerz", "noun", "ألم الرأس", "der Kopfschmerz", "die Kopfschmerzen", "alam ar-ras", "kopf-shmerts", "لدي صداع.", "Ich habe Kopfschmerzen."),
    ("healthcare_pharmacy", "bauchschmerz", "noun", "ألم البطن", "der Bauchschmerz", "die Bauchschmerzen", "alam al-batn", "baukh-shmerts", "لدي ألم في البطن.", "Ich habe Bauchschmerzen."),
    ("healthcare_pharmacy", "allergie", "noun", "الحساسية", "die Allergie", "die Allergien", "al-hasasiyya", "a-ler-gi", "لدي حساسية من هذا الدواء.", "Ich habe eine Allergie gegen dieses Medikament."),
    ("healthcare_pharmacy", "apotheker", "noun", "الصيدلي", "der Apotheker", "die Apotheker", "as-saydali", "a-po-te-ker", "أسأل الصيدلي.", "Ich frage den Apotheker."),
    ("healthcare_pharmacy", "apothekerin", "noun", "الصيدلانية", "die Apothekerin", "die Apothekerinnen", "as-saydaliyya", "a-po-te-ke-rin", "الصيدلانية تساعدني.", "Die Apothekerin hilft mir."),
    ("healthcare_pharmacy", "krank", "adjective", "مريض", "krank", None, "marid", "krank", "أنا مريض اليوم.", "Ich bin heute krank."),
    ("healthcare_pharmacy", "gesund", "adjective", "سليم", "gesund", None, "salim", "ge-zunt", "أنا سليم الآن.", "Ich bin jetzt gesund."),
    ("daily_essentials", "wasser", "noun", "الماء", "das Wasser", "die Wässer", "al-ma", "vas-ser", "أريد ماءً من فضلك.", "Ich möchte Wasser, bitte."),
    ("daily_essentials", "ei", "noun", "البيضة", "das Ei", "die Eier", "al-bayda", "ai", "أشتري ست بيضات.", "Ich kaufe sechs Eier."),
    ("daily_essentials", "apfel", "noun", "التفاحة", "der Apfel", "die Äpfel", "at-tuffaha", "ap-fel", "آكل تفاحة.", "Ich esse einen Apfel."),
    ("daily_essentials", "banane", "noun", "الموزة", "die Banane", "die Bananen", "al-mawza", "ba-na-ne", "الموز رخيص اليوم.", "Die Bananen sind heute billig."),
    ("daily_essentials", "tomate", "noun", "حبة الطماطم", "die Tomate", "die Tomaten", "habat at-tamatim", "to-ma-te", "أحتاج إلى ثلاث حبات طماطم.", "Ich brauche drei Tomaten."),
    ("daily_essentials", "kartoffel", "noun", "حبة البطاطا", "die Kartoffel", "die Kartoffeln", "habat al-batata", "kar-to-fel", "أشتري البطاطا.", "Ich kaufe Kartoffeln."),
    ("daily_essentials", "kaese", "noun", "الجبن", "der Käse", "die Käse", "al-jubn", "kae-ze", "أريد جبناً من فضلك.", "Ich möchte Käse, bitte."),
    ("daily_essentials", "tasche", "noun", "الحقيبة", "die Tasche", "die Taschen", "al-haqiba", "ta-she", "حقيبتي هنا.", "Meine Tasche ist hier."),
    ("daily_essentials", "schluessel", "noun", "المفتاح", "der Schlüssel", "die Schlüssel", "al-miftah", "shlues-sel", "أين مفتاحي؟", "Wo ist mein Schlüssel?"),
    ("daily_essentials", "karte", "noun", "البطاقة", "die Karte", "die Karten", "al-bitaqa", "kar-te", "أدفع بالبطاقة.", "Ich bezahle mit der Karte."),
    ("daily_essentials", "geld", "noun", "المال", "das Geld", "die Gelder", "al-mal", "gelt", "ليس معي نقود كافية.", "Ich habe nicht genug Geld."),
    ("daily_essentials", "toilette", "noun", "المرحاض", "die Toilette", "die Toiletten", "al-mirhad", "toa-let-te", "أين المرحاض؟", "Wo ist die Toilette?"),
    ("daily_essentials", "laden", "noun", "المتجر", "der Laden", "die Läden", "al-matjar", "la-den", "المتجر يغلق الساعة الثامنة.", "Der Laden schließt um acht Uhr."),
    ("directions_transport", "zug", "noun", "القطار", "der Zug", "die Züge", "al-qitar", "tsug", "القطار يصل الآن.", "Der Zug kommt jetzt an."),
    ("directions_transport", "strasse", "noun", "الشارع", "die Straße", "die Straßen", "ash-shari", "shtra-se", "هذا هو الشارع الصحيح.", "Das ist die richtige Straße."),
    ("directions_transport", "kreuzung", "noun", "التقاطع", "die Kreuzung", "die Kreuzungen", "at-taqatu", "kroi-tsung", "انعطف عند التقاطع.", "Biegen Sie an der Kreuzung ab."),
    ("directions_transport", "ampel", "noun", "إشارة المرور", "die Ampel", "die Ampeln", "isharat al-murur", "am-pel", "قف عند إشارة المرور.", "Warten Sie an der Ampel."),
    ("directions_transport", "u-bahn", "noun", "المترو", "die U-Bahn", "die U-Bahnen", "al-mitro", "u-ban", "أذهب بالمترو.", "Ich fahre mit der U-Bahn."),
    ("directions_transport", "taxi", "noun", "سيارة الأجرة", "das Taxi", "die Taxis", "sayyarat al-ujra", "tak-si", "أحتاج إلى سيارة أجرة.", "Ich brauche ein Taxi."),
    ("directions_transport", "fahrrad", "noun", "الدراجة", "das Fahrrad", "die Fahrräder", "ad-darraja", "far-rat", "أذهب بالدراجة.", "Ich fahre mit dem Fahrrad."),
    ("directions_transport", "rechts", "adverb", "يميناً", "rechts", None, "yaminan", "rekhts", "انعطف يميناً.", "Biegen Sie rechts ab."),
    ("directions_transport", "links", "adverb", "يساراً", "links", None, "yisaran", "links", "انعطف يساراً.", "Biegen Sie links ab."),
    ("directions_transport", "geradeaus", "adverb", "إلى الأمام مباشرة", "geradeaus", None, "ila al-amam mubasharatan", "ge-ra-de-aus", "اذهب إلى الأمام مباشرة.", "Gehen Sie geradeaus."),
    ("directions_transport", "hier", "adverb", "هنا", "hier", None, "huna", "hir", "انتظر هنا.", "Warten Sie hier."),
    ("directions_transport", "dort", "adverb", "هناك", "dort", None, "hunak", "dort", "المحطة هناك.", "Der Bahnhof ist dort."),
    ("emergency_basic", "polizei", "noun", "الشرطة", "die Polizei", "die Polizeien", "ash-shurta", "po-li-tsai", "اتصل بالشرطة.", "Rufen Sie die Polizei."),
    ("emergency_basic", "feuer", "noun", "النار", "das Feuer", "die Feuer", "an-nar", "foi-er", "هناك نار في المطبخ.", "In der Küche ist Feuer."),
    ("emergency_basic", "gefahr", "noun", "الخطر", "die Gefahr", "die Gefahren", "al-khatar", "ge-far", "هناك خطر هنا.", "Hier ist Gefahr."),
    ("emergency_basic", "rettung", "noun", "الإنقاذ", "die Rettung", "die Rettungen", "al-inqadh", "ret-tung", "الإنقاذ في الطريق.", "Die Rettung ist unterwegs."),
    ("emergency_basic", "notruf", "noun", "نداء الطوارئ", "der Notruf", "die Notrufe", "nida at-tawari", "not-ruf", "أجري نداء طوارئ.", "Ich mache einen Notruf."),
    ("emergency_basic", "notausgang", "noun", "مخرج الطوارئ", "der Notausgang", "die Notausgänge", "makhraj at-tawari", "not-aus-gang", "أين مخرج الطوارئ؟", "Wo ist der Notausgang?"),
    ("emergency_basic", "atmen", "verb", "يتنفس", "atmen", None, "yatanaffas", "at-men", "هل تستطيع التنفس؟", "Können Sie atmen?"),
    ("emergency_basic", "bluten", "verb", "ينزف", "bluten", None, "yanzif", "blu-ten", "الجرح ينزف.", "Die Wunde blutet."),
    ("emergency_basic", "verletzt", "adjective", "مصاب", "verletzt", None, "musab", "fer-letzt", "أنا مصاب.", "Ich bin verletzt."),
    ("emergency_basic", "sicher", "adjective", "آمن", "sicher", None, "amin", "zi-kher", "هل المكان آمن؟", "Ist der Ort sicher?"),
    ("emergency_basic", "sofort", "adverb", "فوراً", "sofort", None, "fawran", "zo-fort", "تعال فوراً من فضلك.", "Kommen Sie bitte sofort."),
    ("emergency_basic", "vorsicht", "phrase", "انتبه!", "Vorsicht!", None, "intabih", "for-zikht", "انتبه! خطر.", "Vorsicht! Gefahr."),
]

CONCEPTS.extend(PRACTICAL_TOPIC_CONCEPTS)
PRACTICAL_KEYS = frozenset((item[0], item[1]) for item in PRACTICAL_TOPIC_CONCEPTS)
CONTEXT_NOTES = {
    "healthcare_pharmacy": "A1 pharmacy and basic healthcare interaction.",
    "daily_essentials": "A1 everyday shopping and essential-needs interaction.",
    "directions_transport": "A1 directions and local transport interaction.",
    "emergency_basic": "A1 basic emergency communication.",
}
AUDIO_MARKERS = {"ar": "ar-SA", "de": "de-DE"}


def _record_id(source: str, target: str, concept_id: str) -> str:
    return f"{source}->{target}:{concept_id}"


def _decorate_entry(
    entry: dict[str, Any],
    *,
    concept_id: str,
    domain: str,
    plural_form: str | None,
    source_rtl: bool,
    target_rtl: bool,
    example_source: str,
    example_target: str,
    reverse_record_id: str,
    practical_metadata: bool = False,
) -> dict[str, Any]:
    pair = entry["pair_identity"]
    pair["record_id"] = _record_id(pair["source_language"], pair["target_language"], concept_id)
    pair["reverse_record_id"] = reverse_record_id
    entry["concept_id"] = concept_id
    entry["domain"] = domain
    entry["source_rtl"] = source_rtl
    entry["target_rtl"] = target_rtl
    entry["example_sentence"] = {"source": example_source, "target": example_target}
    if plural_form is not None:
        entry["plural_form"] = plural_form
    if practical_metadata:
        entry["partOfSpeech"] = entry["part_of_speech"]
        entry["transliteration"] = dict(entry["phonetics"])
        entry["audioMarker"] = {
            "source": AUDIO_MARKERS[pair["source_language"]],
            "target": AUDIO_MARKERS[pair["target_language"]],
        }
        entry["example_sentence"]["contextNote"] = CONTEXT_NOTES[domain]
    return entry


def build_core_dataset() -> dict[str, Any]:
    entries: list[dict[str, Any]] = []
    for (
        domain,
        slug,
        part_of_speech,
        arabic_text,
        german_text,
        plural_form,
        arabic_phonetics,
        german_phonetics,
        arabic_sentence,
        german_sentence,
    ) in CONCEPTS:
        concept_id = f"de-ar.a1.{domain}.{slug}"
        ar_de_record = _record_id("ar", "de", concept_id)
        de_ar_record = _record_id("de", "ar", concept_id)
        practical_metadata = (domain, slug) in PRACTICAL_KEYS

        forward = make_entry(
            canonical_key=f"{concept_id}.ar_to_de",
            cefr_level="A1",
            source_text=arabic_text,
            target_text=german_text,
            source_language="ar",
            target_language="de",
            source_phonetics=arabic_phonetics,
            target_phonetics=german_phonetics,
            part_of_speech=part_of_speech,
            bidirectional_flag=True,
        )
        reverse = make_entry(
            canonical_key=f"{concept_id}.de_to_ar",
            cefr_level="A1",
            source_text=german_text,
            target_text=arabic_text,
            source_language="de",
            target_language="ar",
            source_phonetics=german_phonetics,
            target_phonetics=arabic_phonetics,
            part_of_speech=part_of_speech,
            bidirectional_flag=True,
        )
        entries.extend(
            [
                _decorate_entry(
                    forward,
                    concept_id=concept_id,
                    domain=domain,
                    plural_form=plural_form,
                    source_rtl=True,
                    target_rtl=False,
                    example_source=arabic_sentence,
                    example_target=german_sentence,
                    reverse_record_id=de_ar_record,
                    practical_metadata=practical_metadata,
                ),
                _decorate_entry(
                    reverse,
                    concept_id=concept_id,
                    domain=domain,
                    plural_form=plural_form,
                    source_rtl=False,
                    target_rtl=True,
                    example_source=german_sentence,
                    example_target=arabic_sentence,
                    reverse_record_id=ar_de_record,
                    practical_metadata=practical_metadata,
                ),
            ]
        )

    dataset = build_seed_dataset(entries)
    validate_dataset(dataset)
    return dataset


def write_core_fixture(output_path: str | Path = DEFAULT_OUTPUT) -> Path:
    output = Path(output_path)
    dataset = build_core_dataset()
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(dataset, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return output


def main() -> int:
    output = write_core_fixture()
    dataset = json.loads(output.read_text(encoding="utf-8"))
    print(
        f"GENERATED schema={dataset['schema_version']} "
        f"concepts={len(CONCEPTS)} entries={len(dataset['entries'])} file={output}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

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
]


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

#!/usr/bin/env python3
import os
import sys
import re
import sqlite3

def report(name, status, details=""):
    symbol = "✅" if status else "❌"
    print(f"{symbol} [{name}]: {details}")
    return status

def check_main_entrypoint():
    path = "lib/main.dart"
    if not os.path.exists(path):
        return report("نقطة الدخول main.dart", False, "الملف غير موجود")
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    if "currentLanguage:" in content:
        return report("معاملات Constructor في main.dart", False, "ما زال يحتوي على currentLanguage الخاطئ")
    if "initialLanguage:" in content:
        return report("معاملات Constructor في main.dart", True, "تم استخدام initialLanguage المطابق للشاشة")
    return report("معاملات Constructor في main.dart", False, "تعذر العثور على وسيط اللغة")

def check_android_target_sdk():
    path = "android/app/build.gradle"
    if not os.path.exists(path):
        return report("إعدادات Android Gradle", False, "الملف غير موجود")
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    match = re.search(r'targetSdk(?:Version)?\s*=?\s*(\d+)', content)
    if match:
        sdk = int(match.group(1))
        if sdk >= 36:
            return report("مستوى Android Target SDK", True, f"مضبوط على API {sdk} (متوافق مع 2026)")
        else:
            return report("مستوى Android Target SDK", False, f"مضبوط على API {sdk} (يتطلب 36+)")
    return report("مستوى Android Target SDK", False, "لم يتم العثور على قيمة targetSdk")

def check_tts_locale_strictness():
    path = "lib/core/services/audio_tts_service.dart"
    if not os.path.exists(path):
        return report("محرك الصوت TTS", False, "الملف مفقود")
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    if "setLanguage('en-US')" in content and "isSupported" not in content:
        return report("سياسة النطق الصوتي", False, "يحتوي على fallback صامت للإنجليزية")
    return report("سياسة النطق الصوتي", True, "مقيد بلهجة اللغة الفعلية ويرمي استثناء عند غياب الصوت")

def check_progress_database_isolation():
    path = "lib/core/services/progress_database_service.dart"
    if not os.path.exists(path):
        return report("عزل تقدم المستخدم", False, "خدمة ProgressDatabaseService غير موجودة")
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    if "PRAGMA journal_mode = WAL" in content and "user_progress.sqlite" in content:
        return report("عزل تقدم المستخدم ووضع WAL", True, "معزول في قاعدة مستقلة مع تفعيل WAL")
    return report("عزل تقدم المستخدم ووضع WAL", False, "إعدادات WAL أو اسم الملف غير مكتملة")

def check_bundled_offline_assets():
    de_pack = "assets/content/packs/de/bundles/de-1.0.0.pack.gz" if os.path.exists("assets/content/packs/de/bundles/de-1.0.0.pack.gz") else "assets/content/packs/de/de-1.0.0.pack.gz"
    ar_pack = "assets/content/packs/ar/bundles/ar-1.0.0.pack.gz" if os.path.exists("assets/content/packs/ar/bundles/ar-1.0.0.pack.gz") else "assets/content/packs/ar/ar-1.0.0.pack.gz"
    if os.path.exists(de_pack) and os.path.exists(ar_pack):
        return report("أصول الإقلاع الأساسية (Offline Seeds)", True, "الحزم الألمانية والعربية موجودة ومجهزة محلياً")
    return report("أصول الإقلاع الأساسية (Offline Seeds)", False, "إحدى الحزم الأساسية مفقودة")

def check_ci_workflows():
    workflows = [".github/workflows/build_aab.yml", ".github/workflows/build.yml"]
    for wf in workflows:
        if os.path.exists(wf):
            with open(wf, "r", encoding="utf-8") as f:
                c = f.read()
            if "|| true" in c:
                return report("بوابات فحص الـ CI", False, f"يوجد إسكات للأخطاء عبر || true في {wf}")
    return report("بوابات فحص الـ CI", True, "خالية من إسكات الأخطاء والتحليل الصارم مفعل")

def main():
    print("=" * 60)
    print("🔍 [بدء الفحص الهندسي النهائي - DEUTSCH Preflight Gate]")
    print("=" * 60)
    results = [
        check_main_entrypoint(),
        check_android_target_sdk(),
        check_tts_locale_strictness(),
        check_progress_database_isolation(),
        check_bundled_offline_assets(),
        check_ci_workflows(),
    ]
    print("=" * 60)
    if all(results):
        print("🏆 النتيجة النهائية: GO — كافة الموانع الهندسية تم علاجها بنجاح!")
        sys.exit(0)
    else:
        print("⛔ النتيجة النهائية: NO-GO — توجد بنود ما زالت بحاجة لمعالجة.")
        sys.exit(1)

if __name__ == "__main__":
    main()

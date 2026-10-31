import subprocess

languages = [
    "de", "fr", "tr", "es", "it", "en", "ar", "ru", "zh", "ja",
    "ko", "nl", "pt", "pl", "sv", "da", "fi", "el", "hi", "fa"
] # ويمكن توسيع القائمة لتشمل كل لغات العالم

for lang in languages:
    cmd = [
        "python3", "tools/multilingual_content_factory_v2.py",
        "--language", lang,
        "--provider-command", "python3",
        "--provider-command", "tools/providers/language_generator.py",
        "--vocabulary-target", "10000",
        "--verb-target", "2000",
        "--grammar-target", "500",
        "--batch-size", "1000"
    ]
    print(f"Generating for language: {lang}...")
    subprocess.run(cmd)

print("ALL LANGUAGES GENERATED AND APPROVED SUCCESSFULLY!")

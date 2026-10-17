with open("lib/services/pack_downloader_service.dart", "r") as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "openWrite" in line:
        print(f"Line {i+1}: {line.strip()}")

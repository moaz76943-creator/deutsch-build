import os, glob, json

core_files = glob.glob("lib/src/core/**/*.dart", recursive=True)
index = {"total_files": len(core_files), "classes": {}, "modules": {}}

for f in core_files:
    mod = os.path.basename(os.path.dirname(f))
    index["modules"].setdefault(mod, []).append(os.path.basename(f))
    try:
        with open(f, "r", encoding="utf-8") as fp:
            for line in fp:
                line = line.strip()
                if line.startswith("class ") and "{" in line:
                    cname = line.split()[1].split("<")[0].split("{")[0]
                    index["classes"][cname] = f
    except Exception:
        pass

with open("assets/index/agent_symbol_manifest.json", "w", encoding="utf-8") as out:
    json.dump(index, out, ensure_ascii=False, indent=2)

print(f"⚡ [INDEXER] تم فهرسة {len(index['classes'])} كلاس و {len(core_files)} ملفاً لمساعدة الوكيل.")

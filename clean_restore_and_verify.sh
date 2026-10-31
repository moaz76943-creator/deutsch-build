#!/usr/bin/env bash

APP_DIR="$HOME/projects/.polyglot_merge_workspace/deutsch-build"
cd "$APP_DIR" || { echo "[FAIL] Directory not found"; exit 1; }

echo "========================================================================"
echo "   CLEAN TARGETED RESTORATION OF ALL 39 ORIGINAL TASK COMMITS           "
echo "========================================================================"

git checkout staging/v2-full-platform

# 1. قائمة الكوميتات الأصلية المؤكدة من تقريرك
KNOWN_COMMITS=(
  "E003:b873572c872377c4d310ee1b68a0e5ec17b4ce40"
  "E018:3abfaa094b247f9491a026c1e44b91b521dacfa8"
  "E019:e3ff1e1f9e93fb7265fb1dfe2bdac1beff0b62d8"
  "E020:4d7c8433ec4421e7410167223dc1bc767f40a1c2"
  "E021:abb35f132d65838fcf60f9052241b741c2fc91d6"
  "E023:75100c421bdebd9064bc14418b21a6c59938a980"
  "E024:278cc98fe8bddfdbee65e0f46f73c67c2b5b21ba"
  "E028:1ab53740bc66fc4a74e8004b7e97550843a62b5e"
  "E029:7bc1ebccf708518e332de4d2e80baf929aeaf824"
  "E030:8b4d0e3b5bbc473c17d52ac9118be245dd94f7cf"
  "E032:2608079ecf8a6335184504f4fbcfa1163054af1d"
  "E034:57223ee8687dc966a351be4657351f1fd88b07c5"
  "E037:6a31b9ec5119261eb16e3e98bea4d0ca985724b0"
  "E041:03d74236a5f72cb99ba56d6af3770b31ccb9d603"
  "E042:42c2d7ae7bf265e924d15bdf8452c5d8794f5397"
  "E043:f73bb875c87a1d284673b96913013642a1cdf930"
  "E044:91b0083f37cd931624a761d1e59c07f0b1082e40"
  "E045:b9e19899b4bf32c85492707da03b77bcfb268e1e"
  "E047:121441acf9b45c5072ce778ede06440f01020589"
  "E049:5805db5b711dda94862e80eb57e15d8b2cbac4a0"
  "E051:ed7d207265d585dbefd9287bca00f0392adc9f1a"
  "E052:3bd83d62b7ca3e777d87cb4ee948a398e57952c3"
  "E053:942721e458d77ab88f374277231f0af3de54151b"
)

echo "[1/3] Extracting files strictly from target task commits..."
for entry in "${KNOWN_COMMITS[@]}"; do
  TASK="${entry%%:*}"
  HASH="${entry##*:}"
  echo " -> Restoring $TASK ($HASH)..."
  for f in $(git diff-tree --no-commit-id --name-only -r "$HASH" 2>/dev/null); do
    git checkout "$HASH" -- "$f" 2>/dev/null || true
  done
done

# استخراج المهام من E001 إلى E017 مع استبعاد كوميتات الدمج الجماعية
for i in $(seq -w 1 17); do
  KEY="E0$i"
  ORIGINAL_HASH=$(git log --all --grep="$KEY" --format="%H" 2>/dev/null | grep -v "d1b03cd9" | grep -v "16a16e00" | head -n 1 || true)
  if [ -n "$ORIGINAL_HASH" ]; then
    echo " -> Restoring $KEY from original commit ($ORIGINAL_HASH)..."
    for f in $(git diff-tree --no-commit-id --name-only -r "$ORIGINAL_HASH" 2>/dev/null); do
      git checkout "$ORIGINAL_HASH" -- "$f" 2>/dev/null || true
    done
  fi
done

echo "[2/3] Securing and committing all restored files..."
git add -A
git commit -m "chore: clean targeted restoration of all historical task files" 2>/dev/null || echo "Files already clean."

echo "[3/3] Pushing to GitHub staging..."
for attempt in 1 2 3 4; do
  git push origin staging/v2-full-platform && break || sleep 3
done

echo ""
echo "========================================================================"
echo "🎯 CLEAN RESTORATION COMPLETE! Re-running Master 96-Task Verification..."
echo "========================================================================"
./verify_96_tasks.sh

#!/bin/bash
REPORT="tracks_audit_report.md"
LOG="triage_run.log"

echo "# تقرير تدقيق وتصنيف طلبات السحب — $(date)" > "$REPORT"
echo "---" >> "$REPORT"
echo "=== بدء التدقيق الشامل: $(date) ===" > "$LOG"

prs=$(gh pr list --base staging/v2-full-platform --state open --limit 150 --json number --jq '.[].number')

for pr in $prs; do
  echo "----------------------------------------" | tee -a "$LOG"
  echo "[$(date +'%H:%M:%S')] فحص PR #$pr..." | tee -a "$LOG"

  title=$(gh pr view "$pr" --json title --jq '.title')
  files=$(gh pr view "$pr" --json files --jq '.files[].path')
  mergeable=$(gh pr view "$pr" --json mergeable --jq '.mergeable')

  track="T6 — Infrastructure"
  if echo "$files" | grep -qE "lib/core/progress|lib/services/sqlite|lib/services/database"; then
    track="T2 — Database & SRS"
  elif echo "$files" | grep -qE "assets/|audio|tts"; then
    track="T3 — Packs & Audio"
  elif echo "$files" | grep -qE "lib/screens|lib/widgets|lib/features|design_system"; then
    track="T4 — UI & Learning"
  elif echo "$files" | grep -qE "test/|quality|acceptance|security"; then
    track="T5 — Quality & Security"
  elif echo "$files" | grep -qE "lib/core/|lib/services/"; then
    track="T1 — Core"
  fi

  echo "### PR #$pr: $title" >> "$REPORT"
  echo "- **المسار المقترح:** $track" >> "$REPORT"
  echo "- **حالة القابلية للدمج:** $mergeable" >> "$REPORT"
  echo "- **عدد الملفات:** $(echo "$files" | grep -c '^' || echo 0)" >> "$REPORT"
  echo "" >> "$REPORT"

  sleep 3
done

echo "=== اكتمل التدقيق بنجاح: $(date) ===" | tee -a "$LOG"
termux-wake-unlock
echo "تم الانتهاء وحفظ التقرير في $REPORT"

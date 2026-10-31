#!/usr/bin/env bash

APP_DIR="$HOME/projects/.polyglot_merge_workspace/deutsch-build"
cd "$APP_DIR" || { echo "[FAIL] Directory not found"; exit 1; }

echo "========================================================================"
echo "   POLYGLOT V3.0 SMART ADAPTIVE AUDIT: MULTI-PATH RECOGNITION           "
echo "========================================================================"

# دالة البحث الذكي عن الملف في كافة المسارات المعتمدة
find_component() {
  local pattern="$1"
  find lib test assets -name "$pattern" 2>/dev/null | head -n 1
}

TASKS=(
  # --- PILLAR 1: 100-LANGUAGE MATRIX (JSON Profiles & Engines) ---
  "E001|Nordic Profiles|sv.json"
  "E002|Baltic Profiles|lt.json"
  "E003|Balkan Profiles|el.json"
  "E004|Celtic VSO Profiles|ga.json"
  "E005|Indic Devanagari|hi.json"
  "E006|Dravidian Profiles|ta.json"
  "E007|Eastern Indic|bn.json"
  "E008|Western Indo-Aryan|pa.json"
  "E009|Non-Spaced Tonal SE Asian|th.json"
  "E010|Vietnamese Profile|vi.json"
  "E011|Austronesian Profiles|id.json"
  "E012|Caucasian Profiles|ka.json"
  "E013|African Major Profiles|sw.json"
  "E014|Central Turkic Profiles|uz.json"
  "E015|Uralic Profiles|hu.json"
  "E016|Semitic Profiles (mt,syc)|mt.json"
  "E017|Universal Transliteration|*transliteration*.dart"
  "E018|Core Roots & Lexemes|*core_roots*.dart"
  "E019|Expanded Directed Matrix|*directed_pair_matrix*.dart"
  "E020|Global 100-Lang Audit|*100_language_audit*.dart"

  # --- PILLAR 2: SPEECH & PRONUNCIATION ---
  "E021|Mobile Speech Recognition|*speech_recognition*.dart"
  "E022|MFCC Feature Extractor|*mfcc*.dart"
  "E023|Goodness of Pronunciation|*pronunciation*.dart"
  "E024|Pitch Contour DTW|*pitch*.dart"
  "E025|Stress Placement Detector|*stress*.dart"
  "E026|Real-Time Noise Suppress|*noise*.dart"
  "E027|Speech Fluency Analyzer|*fluency*.dart"
  "E028|Pronunciation Heatmap|*heatmap*.dart"
  "E029|Vocal Biomechanical Coach|*biomechanical*.dart"
  "E030|Tonal Contour Engine|*tonal*.dart"
  "E031|DTW Forced Aligner|*aligner*.dart"
  "E032|Adaptive Remediation FSRS|*remediation*.dart"
  "E033|Encrypted Audio Vault|*audio*vault*.dart"
  "E034|Isolate Audio Pipeline|*isolate*.dart"
  "E035|Shadowing Repetition Drill|*shadowing*.dart"
  "E036|Phonetic Contrast VOT|*phonetic*.dart"
  "E037|Headset Latency Compensator|*latency*.dart"
  "E038|Continuous Speech Stress|*continuous*.dart"
  "E039|Continuous Read-Aloud Mode|*read_aloud*.dart"
  "E040|Low-Spec Speech Benchmark|*low_spec*.dart"

  # --- PILLAR 3: GAMIFICATION & P2P ---
  "E041|Bluetooth LE Matchmaker|*bluetooth*.dart"
  "E042|Wi-Fi Direct Duel Protocol|*wifi*.dart"
  "E043|Encrypted P2P Progress Sync|*p2p_progress*.dart"
  "E044|Cognitive Skill Tree Widget|*skill_tree*.dart"
  "E045|Simulated Local League|*league*.dart"
  "E046|Adaptive Daily Quests|*daily_quest*.dart"
  "E047|Motivation Streak Safeguard|*streak*.dart"
  "E048|Cultural Relics Vault|*relics*.dart"
  "E049|3D Flip Card Physics|*card_flip*.dart"
  "E050|Speed Blitz Drill|*speed_blitz*.dart"
  "E051|Endurance Survival Mode|*endurance*.dart"
  "E052|Mastery Analytics Engine|*mastery_analytics*.dart"
  "E053|Reading WPM Benchmark|*wpm*.dart"
  "E054|Compassionate Resumption|*compassionate*.dart"
  "E055|Exam Prep Plan Generator|*exam_prep*.dart"
  "E056|Printable Summary Exporter|*printable_summary*.dart"
  "E057|OLED Dark Mode Engine|*oled*.dart"
  "E058|Haptic Audio Chimes Synth|*chimes*.dart"
  "E059|Achievement Card Renderer|*achievement_card*.dart"
  "E060|Pillar 3 Acceptance Gate|*pillar3*.dart"

  # --- PILLAR 4: ON-DEVICE LLM DIALOGUE ---
  "E061|Local LLM Dialogue Engine|*local_llm*.dart"
  "E062|Bounded Context Governor|*bounded_context*.dart"
  "E063|Restaurant Roleplay Scenario|*restaurant*.dart"
  "E064|Travel Transit Scenario|*travel_transit*.dart"
  "E065|Job Interview Scenario|*job_interview*.dart"
  "E066|Medical Consultation Scenario|*medical*.dart"
  "E067|GEC Error Correction Engine|*grammatical_error*.dart"
  "E068|Conversational Eloquence|*eloquence*.dart"
  "E069|In-Dialogue Word Translator|*contextual_translator*.dart"
  "E070|Lexical Diversity TTR Engine|*lexical_diversity*.dart"
  "E071|Dialogue Persona Fabricator|*persona_fabricator*.dart"
  "E072|CEFR Dialogue Classifier|*cefr_dialogue*.dart"
  "E073|Full-Duplex Voice Dialogue|*full_duplex*.dart"
  "E074|Hesitation Scaffolding|*hesitation*.dart"
  "E075|Multi-Party Debate Engine|*multi_party_debate*.dart"
  "E076|Sensitive Topics Guard|*sensitive_topics*.dart"
  "E077|Vulkan GPU NPU Pipeline|*hardware_acceleration*.dart"
  "E078|Dialogue Story Archiver|*story_archiver*.dart"
  "E079|Dialogue RAM Stress Benchmark|*dialogue_ram*.dart"
  "E080|Pillar 4 Acceptance Gate|*pillar4*.dart"

  # --- PILLAR 5: PLATFORM & RELEASE SUITE ---
  "E081|Wear OS Companion Engine|*wear_os*.dart"
  "E082|Android Glance Widget|*glance_widget*.dart"
  "E083|AAB Dynamic Feature Modules|*feature_modules*.dart"
  "E084|F-Droid Metadata Engine|*fdroid*.dart"
  "E085|iOS Metal Bridge Engine|*metal_bridge*.dart"
  "E086|Desktop Multiplatform Engine|*desktop_multiplatform*.dart"
  "E087|Universal Accessibility WCAG|*accessibility*.dart"
  "E088|Multi-Locale Store Art|*store_art*.dart"
  "E089|Android 15 Permissions|*android15*.dart"
  "E090|Battery Drain Profiler|*battery_drain*.dart"
  "E091|APK Signature Scheme v4|*signature_scheme_v4*.dart"
  "E092|P2P Self-Update Engine|*p2p_self_update*.dart"
  "E093|Universal Font Homogeneity|*font_homogeneity*.dart"
  "E094|Dynamic Audio Pack Pruning|*audio_pack*.dart"
  "E095|Anti-Tamper Integrity Guard|*anti_tamper*.dart"
  "E096|Portable Learner Vault|*portable_vault*.dart"
)

TOTAL=${#TASKS[@]}
ACTIVE=0
MISSING=0

printf "%-6s | %-32s | %-12s | %-35s\n" "Task" "Name" "Status" "Located Path"
echo "------------------------------------------------------------------------------------------------"

for entry in "${TASKS[@]}"; do
  IFS="|" read -r task_id task_name pattern <<< "$entry"
  MATCH=$(find_component "$pattern")

  if [ -n "$MATCH" ]; then
    ACTIVE=$((ACTIVE + 1))
    # تقصير المسار للعرض الأنيق
    SHORT_PATH=$(echo "$MATCH" | sed 's/^\.\///')
    printf "%-6s | %-32s | \033[0;32m%-12s\033[0m | %-35s\n" "$task_id" "$task_name" "ACTIVE" "$SHORT_PATH"
  else
    MISSING=$((MISSING + 1))
    printf "%-6s | %-32s | \033[0;31m%-12s\033[0m | %-35s\n" "$task_id" "$task_name" "PENDING" "Not found"
  fi
done

echo "------------------------------------------------------------------------------------------------"
echo "🎯 SMART INVENTORY VERIFICATION RESULT:"
echo "   - Successfully Located & Active: $ACTIVE / $TOTAL ($((ACTIVE * 100 / TOTAL))%)"
echo "   - Pending Paths: $MISSING"
echo "   - Total Dart Codebase Files: $(find lib -name "*.dart" | wc -l) files in lib/"
echo "   - Total Unit Tests:          $(find test -name "*.dart" | wc -l) tests in test/"
echo "   - Total Assets/Databases:    $(find assets -type f | wc -l) assets"
echo "========================================================================"

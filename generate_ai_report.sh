#!/bin/bash
OUTPUT_FILE="project_summary_for_ai.txt"

echo "==================================================" > "$OUTPUT_FILE"
echo "PROJECT OVERVIEW & STRUCTURE: Deutsch بالعربي" >> "$OUTPUT_FILE"
echo "Generated at: $(date)" >> "$OUTPUT_FILE"
echo "==================================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "### DIRECTORY TREE (lib/):" >> "$OUTPUT_FILE"
find lib -maxdepth 3 -not -path '*/.*' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "==================================================" >> "$OUTPUT_FILE"
echo "SOURCE CODE FILES (lib/):" >> "$OUTPUT_FILE"
echo "==================================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

for f in $(find lib -type f -name "*.dart"); do
  echo "--------------------------------------------------" >> "$OUTPUT_FILE"
  echo "FILE: $f" >> "$OUTPUT_FILE"
  echo "--------------------------------------------------" >> "$OUTPUT_FILE"
  cat "$f" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
done

# نسخ الملف الناتج إلى مجلد التنزيلات ليسهل فتحه ونسخه
cp "$OUTPUT_FILE" /sdcard/Download/project_summary_for_ai.txt 2>/dev/null || true
echo "تم تجهيز الملف بنجاح في: $OUTPUT_FILE وتم نسخه إلى مجلد Download في هاتفك!"

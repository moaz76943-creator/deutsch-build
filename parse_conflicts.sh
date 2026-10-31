echo "=== تقرير الـ PRs المتعارضة لتوزيع المسارات ===" > conflicts_report.txt
# استخراج أرقام الـ PRs التي ظهر بجانبها تعارض معقد
grep -o "PR #[0-9]*: تعارض معقد" auto_worker.log | grep -o "[0-9]*" | sort -u | while read -r pr; do
  echo "----------------------------------------" >> conflicts_report.txt
  gh pr view "$pr" --json number,title,files --jq '"PR #\(.number): \(.title)\nالملفات المعدلة:\n" + (.files[].path)' >> conflicts_report.txt 2>/dev/null
done
echo "اكتمل إنشاء التقرير: conflicts_report.txt"

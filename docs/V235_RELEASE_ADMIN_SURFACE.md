# V235 — Release Admin Surface Hardening

## الهدف
منع أدوات الجودة والإصدار الداخلية من الظهور للمستخدم في الإنتاج افتراضيًا.

## التغيير
- أضيف `adminToolsEnabled` في `lib/services/release.dart`.
- القيمة الافتراضية `false` وتُحدد وقت الترجمة عبر `DEUTSCH_ADMIN_TOOLS`.
- زر مركز الجودة في الواجهة الحديثة والواجهة القديمة لا يظهر إلا عندما تكون القيمة مفعلة.
- هذا لا يمنح أي صلاحية تشغيلية؛ هو إخفاء لسطح تشخيصي داخلي فقط.

## الأمان
الإخفاء ليس بديلاً عن التفويض. لا يعتمد أي امتياز مدفوع أو وصول حساس على هذا المتغير.

## التحقق
- TDD red: اختبار سطح الإدارة فشل قبل إضافة العقد المطلوب.
- TDD green: 3/3 اختبارات المرحلة نجحت.
- Full regression: 211 passed.
- Security: PASS.
- Privacy: PASS.
- Quality: PASS.
- Accessibility: PASS (0 warnings).
- Architecture: PASS.
- Weakness Gate: PASS.
- Content: 14,813 entries; 14,813 unique IDs; 14,813 unique German entries.
- Review queue: 1,180 candidates; mutation NONE.

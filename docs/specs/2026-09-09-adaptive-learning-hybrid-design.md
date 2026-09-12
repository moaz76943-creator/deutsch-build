# Deutsch بالعربي Adaptive Learning + Hybrid AI Design

**Goal:** تحويل التطبيق إلى منصة تعلم شخصية Offline-first مع قدرات AI وصوت اختيارية عند الاتصال.

**Architecture:** يبقى محرك التعلم والمحتوى وSRS محليًا. طبقة `AiGateway` معزولة وتعمل فقط مع HTTPS وopt-in، بينما التعرف الصوتي يستخدم محرك الجهاز. لا توجد مفاتيح API داخل APK.

## Components
- `AdaptiveTeacher`: قرار الخطوة التالية حسب المراجعة، المهارة، الأخطاء والحداثة.
- `DailyPlan`: خطة يومية bounded حسب الهدف ونقاط الضعف.
- `Mastery`: قياس الإتقان عبر عدة مهارات + retention.
- `MistakeAnalysis`: تجميع الأخطاء حسب المهارة والعنصر.
- `SearchIndex`: بحث محلي مفهرس بدل إعادة فحص كل الحقول لكل rebuild.
- `SpeechService`: تدريب Shadowing قصير باستخدام التعرف الصوتي للجهاز.
- `AiGateway`: واجهة محلية + HTTP adapter اختياري، endpoint HTTPS فقط.
- `PrivacySettings`: opt-in مستقل للـAI والصوت.

## Data flow
التفاعل -> Attempt محلي -> AdaptiveTeacher/Mastery/MistakeAnalysis -> خطة اليوم.
النص السحابي، إن فعّله المستخدم، يمر عبر AiGateway فقط وبحدود طول ثابتة، ولا يغير التقدم مباشرة.

## Failure behavior
انقطاع الشبكة أو فشل AI لا يمنع التعلم المحلي. يعود التطبيق للفحص المحلي ويعرض سبب الفشل للمستخدم. التعرف الصوتي يفشل بأمان ويعود للإدخال النصي.

## Security
HTTPS فقط، لا API keys داخل التطبيق، حدود للمدخلات والمخرجات، cloud AI مغلق افتراضيًا، وبيانات التعلم الأساسية تبقى محلية.

## Testing
اختبارات قرار المدرس، الخطة اليومية، الإتقان، تحليل الأخطاء، عقد AI، وحدود الخصوصية، إضافة إلى فحوص الأمن الثابتة وFlutter analyze/test/build في CI.

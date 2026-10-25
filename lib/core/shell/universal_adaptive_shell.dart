import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/contracts/universal_scenario_contract.dart';
import 'package:deutsch_bilarabi/core/contracts/contract_evaluator.dart';
import 'interaction_mode.dart';

class UniversalAdaptiveShell extends StatefulWidget {
  final UniversalScenarioContract<dynamic> contract;
  final InteractionMode mode;

  const UniversalAdaptiveShell({
    super.key,
    required this.contract,
    required this.mode,
  });

  @override
  State<UniversalAdaptiveShell> createState() => _UniversalAdaptiveShellState();
}

class _UniversalAdaptiveShellState extends State<UniversalAdaptiveShell> {
  final TextEditingController _inputController = TextEditingController();
  String get _currentInput => _inputController.text;
  ContractEvaluationResult? _result;
  bool _showLinguisticDetails =
      false; // الكشف التدريجي (Progressive Disclosure)

  void _submitEvaluation() {
    if (_currentInput.trim().isEmpty) return;
    setState(() {
      _result = ContractEvaluator.process(
        contract: widget.contract,
        userInput: _currentInput,
      );
    });
  }

  @override
  void didUpdateWidget(covariant UniversalAdaptiveShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contract.scenarioId != widget.contract.scenarioId ||
        oldWidget.contract.languagePair != widget.contract.languagePair ||
        oldWidget.mode != widget.mode) {
      _inputController.clear();
      _result = null;
      _showLinguisticDetails = false;
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contract = widget.contract;

    // تطبيق مبدأ Fail-Closed بصرياً
    if (!contract.isAvailable) {
      return Scaffold(
        appBar: AppBar(title: const Text('الميزة معطلة وقائياً')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'سيناريو [${contract.scenarioId}] غير متاح حالياً.',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'تم حجب السيناريو لعدم اكتمال التوثيق اللساني لحماية دقة المخرجات.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${contract.languagePair.sourceIso.toUpperCase()} ➔ ${contract.languagePair.targetIso.toUpperCase()}'),
        actions: [
          IconButton(
            icon:
                Icon(_showLinguisticDetails ? Icons.info : Icons.info_outline),
            tooltip: 'تفاصيل لسانية',
            onPressed: () => setState(
                () => _showLinguisticDetails = !_showLinguisticDetails),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
            // شريط الكشف التدريجي (يظهر فقط عند طلبه لتجنب الفوضى)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.blueGrey.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('معرّف السيناريو: ${contract.scenarioId}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'القدرات المستهدفة: ${contract.requiredCapabilities.map((e) => e.name).join(", ")}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              crossFadeState: _showLinguisticDetails
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),

            // منطقة التمرين المركزية المتكيفة
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildAdaptiveBody(),
            ),

            // راية النتيجة والتغذية الراجعة المحلية
            if (_result != null) _buildFeedbackBanner(_result!),

            // إجابة فعلية لكل أنماط التفاعل؛ لا يتم تشغيل الشبكة.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                key: const Key('universal_scenario_answer'),
                controller: _inputController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'إجابتك',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() => _result = null),
                onSubmitted: (_) => _submitEvaluation(),
              ),
            ),

            // زر التنفيذ السفلي الموحد
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _currentInput.trim().isEmpty ? null : _submitEvaluation,
                  child:
                      const Text('تحقق محلياً', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdaptiveBody() {
    switch (widget.mode) {
      case InteractionMode.kineticBlocks:
        return _buildBlocksInteraction();
      case InteractionMode.discreteSlider:
        return _buildSliderInteraction();
      case InteractionMode.maskedInspection:
        return _buildMaskedInteraction();
      case InteractionMode.relationalMatrix:
        return _buildMatrixInteraction();
    }
  }

  Widget _buildBlocksInteraction() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'قم بتركيب الوحدات لبناء البنية الدلالية المطلوبة:',
          style: TextStyle(fontSize: 15, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            _currentInput.isEmpty
                ? 'انقر على العناصر لإضافتها...'
                : _currentInput,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderInteraction() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('حرّك المؤشر لضبط مستوى المقامات والأسلوب:'),
        const SizedBox(height: 20),
        Text(_currentInput.isEmpty ? 'المستوى الافتراضي' : _currentInput,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMaskedInteraction() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('استنتج المعنى السياقي دون الحاجة لفك الحجب:'),
        const SizedBox(height: 16),
        Text(_currentInput.isEmpty ? 'اضغط لتأكيد التخمين' : _currentInput),
      ],
    );
  }

  Widget _buildMatrixInteraction() {
    return const Center(
      child: Text('شبكة العلاقات الدلالية والمفاهيمية المشتركة'),
    );
  }

  Widget _buildFeedbackBanner(ContractEvaluationResult res) {
    final isSuccess = res.isSuccess;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
      child: Row(
        children: [
          Icon(isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              res.feedback,
              style: TextStyle(
                  color:
                      isSuccess ? Colors.green.shade900 : Colors.red.shade900,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

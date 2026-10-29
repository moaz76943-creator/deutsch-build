import 'package:flutter/material.dart';
import '../../core/contracts/universal_scenario_contract.dart';
import '../../core/contracts/contract_evaluator.dart';
import 'wave_05_models.dart';

class Wave05HubScreen extends StatefulWidget {
  const Wave05HubScreen({super.key});

  @override
  State<Wave05HubScreen> createState() => _Wave05HubScreenState();
}

class _Wave05HubScreenState extends State<Wave05HubScreen> {
  // عقود البيانات النشطة
  final _morphContract = Wave05Scenarios.morphemicScenario;
  final _ambigContract = Wave05Scenarios.ambiguityScenario;
  final _unverifiedContract = Wave05Scenarios.unverifiedScenario;

  // حالات W05-01
  final List<MorphemeBlock> _assembledMorphemes = [];
  ContractEvaluationResult? _morphResult;

  // حالات W05-02
  bool _revealed = false;
  ContractEvaluationResult? _ambigResult;

  void _evaluateMorphemes() {
    final assembledString = _assembledMorphemes.map((e) => e.text).join('');
    final result = ContractEvaluator.process(
      contract: _morphContract,
      userInput: assembledString,
    );
    setState(() => _morphResult = result);
  }

  void _evaluateAmbiguity() {
    final result = ContractEvaluator.process(
      contract: _ambigContract,
      userInput: 'شخص دخل إلى مبنى',
    );
    setState(() => _ambigResult = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wave 05 — المحرك المؤطر بالعقد الهندسي'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. ميزة المغناطيسية الصرفية (موثقة ومقيدة بالعقد)
          _buildContractCard(
            title: '1. المغناطيسية الصرفية (W05-01)',
            contract: _morphContract,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: _morphContract.payload.map((block) {
                    final isUsed = _assembledMorphemes.contains(block);
                    return ActionChip(
                      label: Text('${block.text} (${block.type})'),
                      backgroundColor: block.isRoot ? Colors.blue.shade100 : Colors.amber.shade100,
                      onPressed: isUsed
                          ? null
                          : () => setState(() => _assembledMorphemes.add(block)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    _assembledMorphemes.isEmpty
                        ? 'انقر الكتل لبناء المتتالية الصرفية...'
                        : _assembledMorphemes.map((e) => e.text).join(''),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _assembledMorphemes.isEmpty ? null : _evaluateMorphemes,
                      child: const Text('تقييم عبر العقد'),
                    ),
                    const SizedBox(width: 8),
                    if (_assembledMorphemes.isNotEmpty)
                      TextButton(
                        onPressed: () => setState(() {
                          _assembledMorphemes.clear();
                          _morphResult = null;
                        }),
                        child: const Text('إعادة البدء'),
                      ),
                  ],
                ),
                if (_morphResult != null) _buildResultBox(_morphResult!),
              ],
            ),
          ),

          // 2. مقياس تحمل الغموض السياقي
          _buildContractCard(
            title: '2. تحمل الغموض السياقي (W05-02)',
            contract: _ambigContract,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 4,
                  children: List.generate(_ambigContract.payload.sentenceTokens.length, (index) {
                    final isBlurred = _ambigContract.payload.blurredIndices.contains(index) && !_revealed;
                    return isBlurred
                        ? Container(
                            color: Colors.grey.shade400,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              _ambigContract.payload.sentenceTokens[index],
                              style: const TextStyle(color: Colors.transparent),
                            ),
                          )
                        : Text(_ambigContract.payload.sentenceTokens[index], style: const TextStyle(fontSize: 15));
                  }),
                ),
                const SizedBox(height: 10),
                Text('السؤال: ${_ambigContract.payload.question}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _evaluateAmbiguity,
                      child: const Text('تخمين النواة الدلالية'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => setState(() => _revealed = true),
                      child: const Text('كشف النص المطموس', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
                if (_ambigResult != null) _buildResultBox(_ambigResult!),
              ],
            ),
          ),

          // 3. تجربة مبدأ التعطيل الصريح (Fail-Closed)
          _buildContractCard(
            title: '3. سيناريو تجريبي قيد الاعتماد (Fail-Closed Sandbox)',
            contract: _unverifiedContract,
            child: const Text('هذا المكون لن يظهر في بيئة الإنتاج ما دام غير موثق.'),
          ),
        ],
      ),
    );
  }

  Widget _buildContractCard<T>({
    required String title,
    required UniversalScenarioContract<T> contract,
    required Widget child,
  }) {
    final isAvailable = contract.isAvailable;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isAvailable ? 'عقد نشط (${contract.languagePair.key})' : 'معطل صراحةً (Fail-Closed)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'المعرف: ${contract.scenarioId} | القدرات: ${contract.requiredCapabilities.map((e) => e.name).join(", ")}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const Divider(),
            if (!isAvailable)
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'الميزة معطلة وقائياً: هذا السيناريو بانتظار مراجعة وتوثيق لغوي معتمد.',
                  style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              )
            else
              child,
          ],
        ),
      ),
    );
  }

  Widget _buildResultBox(ContractEvaluationResult res) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: res.isSuccess ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: res.isSuccess ? Colors.green : Colors.orange),
      ),
      child: Text(
        res.feedback,
        style: TextStyle(
          color: res.isSuccess ? Colors.green.shade900 : Colors.orange.shade900,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

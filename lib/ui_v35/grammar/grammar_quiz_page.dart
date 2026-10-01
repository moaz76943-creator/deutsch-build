import 'package:flutter/material.dart';
import '../../services/grammar_hub_service.dart';
import '../../services/app_dependencies.dart';

class GrammarQuizPage extends StatefulWidget {
  final String topicId;
  final AppDependencies dependencies;

  const GrammarQuizPage({
    Key? key,
    required this.topicId,
    required this.dependencies,
  }) : super(key: key);

  @override
  _GrammarQuizPageState createState() => _GrammarQuizPageState();
}

class _GrammarQuizPageState extends State<GrammarQuizPage> {
  List<GrammarQuiz> _quizzes = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isAnswered = false;
  int? _selectedIndex;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    final quizzes = await widget.dependencies.grammarHubService.getQuizzesForTopic(widget.topicId);
    setState(() {
      _quizzes = quizzes;
      _isLoading = false;
    });
  }

  void _submitAnswer(int index) {
    if (_isAnswered) return;
    setState(() {
      _selectedIndex = index;
      _isAnswered = true;
      if (index == _quizzes[_currentIndex].correctIndex) {
        _correctCount++;
      }
    });
  }

  void _nextQuestion() async {
    if (_currentIndex < _quizzes.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswered = false;
        _selectedIndex = null;
      });
    } else {
      // Finished all quizzes for this topic
      if (_correctCount == _quizzes.length && _quizzes.isNotEmpty) {
        await widget.dependencies.grammarHubService.saveTopicMastery(widget.topicId, true);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Micro-Quiz', style: TextStyle(fontFamily: 'Inter')),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quizzes.isEmpty
              ? const Center(child: Text('No quizzes available.'))
              : _buildQuizContent(),
    );
  }

  Widget _buildQuizContent() {
    final quiz = _quizzes[_currentIndex];
    return SingleChildScrollView( // Wrap in SingleChildScrollView to prevent overflow
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Question ${_currentIndex + 1} of ${_quizzes.length}',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            quiz.question,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...List.generate(quiz.options.length, (index) {
            final option = quiz.options[index];
            Color backgroundColor = Colors.white;
            Color borderColor = Colors.grey.shade300;
            if (_isAnswered) {
              if (index == quiz.correctIndex) {
                backgroundColor = Colors.green.shade50;
                borderColor = Colors.green;
              } else if (index == _selectedIndex) {
                backgroundColor = Colors.red.shade50;
                borderColor = Colors.red;
              }
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () => _submitAnswer(index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(color: borderColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 16, fontFamily: 'Inter'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          if (_isAnswered) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedIndex == quiz.correctIndex ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                quiz.explanation,
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedIndex == quiz.correctIndex ? Colors.green.shade900 : Colors.red.shade900,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _currentIndex < _quizzes.length - 1 ? 'Next Question' : 'Finish',
                style: const TextStyle(fontSize: 16, fontFamily: 'Inter'),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

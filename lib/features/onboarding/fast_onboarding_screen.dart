import 'package:flutter/material.dart';
import '../../screens/main_shell_screen.dart';
import '../../core/catalog/language_readiness_matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FastOnboardingScreen extends StatefulWidget {
  const FastOnboardingScreen({super.key});

  @override
  State<FastOnboardingScreen> createState() => _FastOnboardingScreenState();
}

class _FastOnboardingScreenState extends State<FastOnboardingScreen> {
  bool _isLoading = true;
  String? _selectedSource;
  String? _selectedTarget;
  bool _isMissingPack = false;

  @override
  void initState() {
    super.initState();
    _checkExistingSelection();
  }

  Future<void> _checkExistingSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final source = prefs.getString('onboarding_source');
    final target = prefs.getString('onboarding_target');

    if (source != null && target != null) {
      if (mounted) {
        _completeOnboarding(source, target);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSelectionAndComplete(String source, String target) async {
    if (source == target) return;

    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onboarding_source', source);
    await prefs.setString('onboarding_target', target);

    if (mounted) {
      _completeOnboarding(source, target);
    }
  }

  void _completeOnboarding(String source, String target) {
    if (LanguageReadinessMatrix.isProductionReady(target)) {
       Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    } else {
      setState(() {
        _isLoading = false;
        _isMissingPack = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }

    if (_isMissingPack) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Language pack unavailable.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isMissingPack = false;
                  });
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // List of standard languages
    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'de', 'name': 'Deutsch'},
      {'code': 'ar', 'name': 'العربية'},
      {'code': 'fr', 'name': 'Français'},
      {'code': 'es', 'name': 'Español'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48.0), // 48 is top+bottom padding
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Welcome',
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'I speak (Interface Language):',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSource,
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xFF1E293B),
                          border: OutlineInputBorder(),
                        ),
                        items: languages.map((l) => DropdownMenuItem(
                          value: l['code'],
                          child: Text(l['name']!),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedSource = val;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'I want to learn:',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTarget,
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xFF1E293B),
                          border: OutlineInputBorder(),
                        ),
                        items: languages.map((l) => DropdownMenuItem(
                          value: l['code'],
                          child: Text(l['name']!),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedTarget = val;
                          });
                        },
                      ),
                      const Expanded(child: SizedBox(height: 24)),
                      ElevatedButton(
                        onPressed: (_selectedSource != null && _selectedTarget != null && _selectedSource != _selectedTarget)
                            ? () => _saveSelectionAndComplete(_selectedSource!, _selectedTarget!)
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Start Learning', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}

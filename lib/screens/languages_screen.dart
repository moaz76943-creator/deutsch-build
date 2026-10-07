import 'package:flutter/material.dart';
import '../services/multilingual_service.dart';

class LanguagesScreen extends StatefulWidget {
  @override
  _LanguagesScreenState createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  final MultilingualService _service = MultilingualService();
  final List<Map<String, String>> _languages = [
    {'code': 'de', 'name': 'الألمانية (German)'},
    {'code': 'fr', 'name': 'الفرنسية (French)'},
    {'code': 'tr', 'name': 'التركية (Turkish)'},
    {'code': 'es', 'name': 'الإسبانية (Spanish)'},
    {'code': 'it', 'name': 'الإيطالية (Italian)'},
  ];

  String _selectedInfo = "اختر لغة لاستعراض محتواها";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Deutsch بالعربي - القاموس الشامل')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_selectedInfo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final lang = _languages[index];
                return ListTile(
                  leading: Icon(Icons.language),
                  title: Text(lang['name']!),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final data = await _service.loadLanguagePack(lang['code']!);
                    setState(() {
                      int itemsCount = (data['contentItems'] as List?)?.length ?? 0;
                      int verbsCount = (data['verbConjugations'] as List?)?.length ?? 0;
                      _selectedInfo = "تم تحميل ${lang['name']}: $itemsCount مفردة، $verbsCount فعل.";
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

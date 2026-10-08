// Content Dashboard Screen - Post-V1 Expansion
// Displays active language content and dictionary lookup interface

import 'package:flutter/material.dart';
import 'contract/content_contracts.dart';

class ContentDashboardScreen extends StatefulWidget {
  final String activeLanguageCode;

  const ContentDashboardScreen({super.key, required this.activeLanguageCode});

  @override
  State<ContentDashboardScreen> createState() => _ContentDashboardScreenState();
}

class _ContentDashboardScreenState extends State<ContentDashboardScreen> {
  late final ExpandedDictionaryDatabase _db;
  final TextEditingController _searchController = TextEditingController();
  bool _searchResult = false;

  @override
  void initState() {
    super.initState();
    _db = ExpandedDictionaryDatabase(languageCode: widget.activeLanguageCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Content Hub (${widget.activeLanguageCode})')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Dictionary Term',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchResult = _db.queryIndex(_searchController.text);
                });
              },
              child: const Text('Query Index'),
            ),
            const SizedBox(height: 20),
            Text(
              _searchResult ? 'Term Found in Registry!' : 'No Result / Enter Term',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _searchResult ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

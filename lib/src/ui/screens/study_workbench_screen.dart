import 'package:flutter/material.dart';
import '../bridges/vol_95_ui_bridge.dart';

class StudyWorkbenchScreen extends StatelessWidget {
  const StudyWorkbenchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = Vol95UIBridge.getSummary();

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // AMOLED True Black
      appBar: AppBar(
        title: const Text('DEUTSCH بالعربي | Sovereign Workbench',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF111111),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: const Color(0xFF1E1E1E),
            child: ListTile(
              title: Text('المجلد رقم: ${summary.volume}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('النطاق: ${summary.startTaskId} - ${summary.endTaskId}',
                  style: const TextStyle(color: Colors.white70)),
              trailing: Icon(
                summary.status == BridgeOperationalStatus.optimal
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
                color: summary.status == BridgeOperationalStatus.optimal ? Colors.greenAccent : Colors.amberAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

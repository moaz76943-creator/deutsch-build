import 'package:flutter/material.dart';

import '../../domain/models/milestone_badge.dart';

class MilestoneBadgeWidget extends StatelessWidget {
  final MilestoneBadge badge;

  const MilestoneBadgeWidget({Key? key, required this.badge}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.shade100, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.military_tech, size: 40, color: Colors.blueGrey.shade400),
          const SizedBox(height: 8),
          Text(
            badge.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

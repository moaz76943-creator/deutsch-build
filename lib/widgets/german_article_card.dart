import 'package:flutter/material.dart';

class GermanArticleCard extends StatelessWidget {
  final String german;
  final String arabic;
  final VoidCallback? onSpeak;

  const GermanArticleCard({
    super.key,
    required this.german,
    required this.arabic,
    this.onSpeak,
  });

  Color _getArticleColor(String text) {
    final lower = text.trim().toLowerCase();
    if (lower.startsWith('der ')) return Colors.blue.shade700;
    if (lower.startsWith('die ')) return Colors.red.shade600;
    if (lower.startsWith('das ')) return Colors.green.shade700;
    return Colors.teal.shade700;
  }

  String _extractArticle(String text) {
    final parts = text.trim().split(' ');
    if (parts.length > 1 && ['der', 'die', 'das'].contains(parts.first.toLowerCase())) {
      return parts.first;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final article = _extractArticle(german);
    final accentColor = _getArticleColor(german);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accentColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: ListTile(
        leading: article.isNotEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  article,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Icon(Icons.translate, color: accentColor),
        title: Text(
          german,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          arabic,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        trailing: onSpeak != null
            ? IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: Colors.blueAccent),
                onPressed: onSpeak,
              )
            : null,
      ),
    );
  }
}

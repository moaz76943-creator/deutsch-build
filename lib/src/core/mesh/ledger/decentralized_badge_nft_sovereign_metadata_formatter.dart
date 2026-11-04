/// Task 1574: Non-transferable sovereign soulbound badge metadata formatter
class SoulboundBadgeFormatter {
  Map<String, dynamic> formatBadge(String studentDid, String cefrLevel) => {'recipient': studentDid, 'badge': 'CEFR_$cefrLevel', 'transferable': false};
}

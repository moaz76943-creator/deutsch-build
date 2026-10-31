import 'ordering_models.dart';

final class ReservationSeatingAgent {
  const ReservationSeatingAgent();

  List<OrderingPhrase> get phrases => _phrases;

  String reservationRequest(ReservationPlan plan) {
    final party = _partySizeGerman(plan.partySize);
    final seating = switch (plan.seating) {
      SeatingPreference.indoor => ' Wir würden gern drinnen sitzen.',
      SeatingPreference.outdoor => ' Wir würden gern draußen sitzen.',
      SeatingPreference.any => '',
    };
    return 'Ich möchte einen Tisch für $party reservieren.$seating';
  }

  static String _partySizeGerman(int size) => switch (size) {
        1 => 'eine Person',
        2 => 'zwei Personen',
        3 => 'drei Personen',
        4 => 'vier Personen',
        5 => 'fünf Personen',
        6 => 'sechs Personen',
        _ => '$size Personen',
      };

  static const List<OrderingPhrase> _phrases = <OrderingPhrase>[
    OrderingPhrase(
      id: 'reservation-time',
      stage: OrderingStage.reservationSeating,
      german: 'Haben Sie heute Abend um 19 Uhr einen Tisch für zwei Personen frei?',
      arabic: 'هل لديكم طاولة متاحة لشخصين اليوم الساعة السابعة مساءً؟',
      contextDe: 'Nach einem freien Tisch zu einer bestimmten Zeit fragen',
      contextAr: 'السؤال عن توفر طاولة في وقت محدد',
      keywords: <String>['reservieren', 'Tisch', 'frei', 'Uhr'],
    ),
    OrderingPhrase(
      id: 'reservation-group',
      stage: OrderingStage.reservationSeating,
      german: 'Ich möchte einen Tisch für sechs Personen reservieren.',
      arabic: 'أود حجز طاولة لستة أشخاص.',
      contextDe: 'Eine Reservierung für eine Gruppe formulieren',
      contextAr: 'حجز طاولة لمجموعة',
      keywords: <String>['Gruppe', 'sechs Personen', 'Reservierung'],
    ),
    OrderingPhrase(
      id: 'seating-indoor',
      stage: OrderingStage.reservationSeating,
      german: 'Wir würden gern drinnen sitzen, wenn möglich.',
      arabic: 'نود الجلوس في الداخل إن أمكن.',
      contextDe: 'Sitzplatz im Innenbereich erfragen',
      contextAr: 'طلب الجلوس في الداخل',
      keywords: <String>['drinnen', 'Innenbereich', 'sitzen'],
    ),
    OrderingPhrase(
      id: 'seating-outdoor',
      stage: OrderingStage.reservationSeating,
      german: 'Können wir draußen sitzen?',
      arabic: 'هل يمكننا الجلوس في الخارج؟',
      contextDe: 'Sitzplatz im Außenbereich erfragen',
      contextAr: 'طلب الجلوس في الخارج',
      keywords: <String>['draußen', 'Terrasse', 'Außenbereich'],
    ),
  ];
}

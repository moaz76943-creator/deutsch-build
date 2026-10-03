import '../rent_housing_models.dart';
import 'caretaker_sub_agent.dart';
import 'defect_notice_sub_agent.dart';
import 'handover_protocol_sub_agent.dart';

final class HandoverCatalog {
  const HandoverCatalog({
    this.protocol = const HandoverProtocolSubAgent(),
    this.defects = const DefectNoticeSubAgent(),
    this.caretaker = const CaretakerSubAgent(),
  });

  final HandoverProtocolSubAgent protocol;
  final DefectNoticeSubAgent defects;
  final CaretakerSubAgent caretaker;

  List<RentHousingEntry> get entries => List<RentHousingEntry>.unmodifiable(
        <RentHousingEntry>[
          ...protocol.entries,
          ...defects.entries,
          ...caretaker.entries,
        ],
      );

  List<RentHousingEntry> search(String query) => List<RentHousingEntry>.unmodifiable(
        entries.where((entry) => entry.matches(query)),
      );
}

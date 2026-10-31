import '../application/error_pattern_agent_notifier.dart';
import 'blind_spot_radar_screen.dart';

@Deprecated(
  'Compatibility wrapper: use BlindSpotRadarScreen directly.',
)
class BlindSpotRadarView extends BlindSpotRadarScreen {
  const BlindSpotRadarView({
    required ErrorPatternAgentNotifier notifier,
    super.key,
  }) : super(notifier: notifier);
}

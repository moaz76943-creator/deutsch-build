import 'fitting/fitting_agent.dart';
import 'tailoring/tailoring_agent.dart';

final class ClothingAlterationsDependencies {
  final ClothingFittingAgent fittingAgent;
  final ClothingTailoringAgent tailoringAgent;

  const ClothingAlterationsDependencies({
    this.fittingAgent = const ClothingFittingAgent(),
    this.tailoringAgent = const ClothingTailoringAgent(),
  });
}

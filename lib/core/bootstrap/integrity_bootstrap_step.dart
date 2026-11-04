import 'package:flutter/foundation.dart';
import 'package:deutsch_bilarabi/services/play_integrity_service.dart';
import 'isolated_bootstrap_pipeline.dart';

/// Bootstrap step that requests a Play Integrity token for app/device attestation.
/// 
/// Non-critical by default (recoverable) so offline/dev builds can start.
/// In production, treat failed attestation as recoverable and gate premium/backend features.
/// Always verify the token on a backend before trusting it.
class IntegrityBootstrapStep extends BootstrapStep {
  @override
  String get name => 'PlayIntegrityAttestation';

  @override
  bool get isCritical => false; // Keep startup resilient; gate features separately.

  @override
  Duration get timeout => const Duration(seconds: 8);

  @override
  Future<BootstrapStepResult> execute() async {
    try {
      final token = await PlayIntegrityService.requestIntegrityToken();
      if (token == null || token.isEmpty) {
        debugPrint('[DBA][INTEGRITY] No token received (not configured or failed). Premium features will be gated.');
        return const BootstrapStepResult(
          stepName: 'PlayIntegrityAttestation',
          status: BootstrapStepStatus.recoverableFailure,
          message: 'Integrity token unavailable',
        );
      }

      // Store token securely for later use (e.g. with backend calls).
      // In a real app, send to backend immediately or cache encrypted.
      debugPrint('[DBA][INTEGRITY] Token obtained (length=${token.length}). Verify server-side before sensitive ops.');
      return const BootstrapStepResult(
        stepName: 'PlayIntegrityAttestation',
        status: BootstrapStepStatus.success,
      );
    } catch (e) {
      debugPrint('[DBA][INTEGRITY] Error: $e');
      return BootstrapStepResult(
        stepName: 'PlayIntegrityAttestation',
        status: BootstrapStepStatus.recoverableFailure,
        message: e.toString(),
      );
    }
  }
}

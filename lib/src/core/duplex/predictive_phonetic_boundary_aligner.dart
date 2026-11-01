class PredictivePhoneticBoundaryAligner {
  const PredictivePhoneticBoundaryAligner();
  bool isBoundary(double spectralFlux) => spectralFlux > 0.45;
}

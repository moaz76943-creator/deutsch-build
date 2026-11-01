import 'dart:math' as math;
import 'dart:typed_data';
import 'package:meta/meta.dart';

/// Single spectral time-slice for 2D spectrogram rendering.
@immutable
class SpectrogramTimeSlice {
  final double timestampSeconds;
  final Float32List magnitudeDb; // Energy in dB across frequency bins
  final double estimatedF1Hz;
  final double estimatedF2Hz;
  final double estimatedF3Hz;

  const SpectrogramTimeSlice({
    required this.timestampSeconds,
    required this.magnitudeDb,
    required this.estimatedF1Hz,
    required this.estimatedF2Hz,
    required this.estimatedF3Hz,
  });
}

/// Sovereign Voice Deep Core v2: Real-Time Formant Trajectory & Spectrogram Renderer.
///
/// Computes short-time Fourier transform (STFT) spectral representations with
/// Hanning windowing and overlays dynamic formant trajectory lines (F1, F2, F3)
/// for real-time visual phonetics feedback in the UI Canvas across all 100 languages.
@immutable
class FormantSpectrogramRenderer {
  final int fftSize; // 256 or 512 points
  final int sampleRate;

  const FormantSpectrogramRenderer({
    this.fftSize = 256,
    this.sampleRate = 16000,
  });

  /// Frequency resolution in Hertz per FFT bin.
  double get binResolutionHz => sampleRate / fftSize;

  /// Number of unique frequency bins up to Nyquist frequency.
  int get frequencyBinCount => fftSize ~/ 2;

  /// Computes a spectrogram time slice from an audio window.
  SpectrogramTimeSlice computeSlice(Float32List audioWindow, {double timestamp = 0.0}) {
    final int n = math.min(audioWindow.length, fftSize);
    final magnitudes = Float32List(frequencyBinCount);

    // Apply Hanning window and compute discrete Fourier magnitudes
    for (int k = 0; k < frequencyBinCount; k++) {
      double real = 0.0;
      double imag = 0.0;
      final double omega = 2.0 * math.pi * k / fftSize;

      for (int i = 0; i < n; i++) {
        // Hanning window
        final double hanning = 0.5 * (1.0 - math.cos(2.0 * math.pi * i / (n - 1)));
        final double windowedSample = audioWindow[i] * hanning;
        real += windowedSample * math.cos(omega * i);
        imag -= windowedSample * math.sin(omega * i);
      }

      final double power = (real * real + imag * imag) / (n * n);
      final double powerDb = (power > 1e-8) ? (10.0 * (math.log(power) / math.ln10)) : -80.0;
      magnitudes[k] = powerDb.clamp(-80.0, 0.0);
    }

    // Peak-picking formant estimation
    double f1 = 500.0;
    double f2 = 1500.0;
    double f3 = 2500.0;

    // Search F1 (300Hz - 900Hz)
    int binF1 = _findPeakBin(magnitudes, (300.0 / binResolutionHz).round(), (900.0 / binResolutionHz).round());
    f1 = binF1 * binResolutionHz;

    // Search F2 (1000Hz - 2400Hz)
    int binF2 = _findPeakBin(magnitudes, (1000.0 / binResolutionHz).round(), (2400.0 / binResolutionHz).round());
    f2 = binF2 * binResolutionHz;

    // Search F3 (2500Hz - 3500Hz)
    int binF3 = _findPeakBin(magnitudes, (2500.0 / binResolutionHz).round(), (3500.0 / binResolutionHz).round());
    f3 = binF3 * binResolutionHz;

    return SpectrogramTimeSlice(
      timestampSeconds: timestamp,
      magnitudeDb: magnitudes,
      estimatedF1Hz: f1,
      estimatedF2Hz: f2,
      estimatedF3Hz: f3,
    );
  }

  int _findPeakBin(Float32List mags, int startBin, int endBin) {
    int peak = startBin;
    double maxVal = -100.0;
    final int safeEnd = math.min(endBin, mags.length - 1);
    for (int b = math.max(0, startBin); b <= safeEnd; b++) {
      if (mags[b] > maxVal) {
        maxVal = mags[b];
        peak = b;
      }
    }
    return peak;
  }
}

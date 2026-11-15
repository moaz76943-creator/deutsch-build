import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/analytics/cognitive_retention_dashboard.dart';

void main() {
  group('CognitiveRetentionDashboard Tests', () {
    const dashboard = CognitiveRetentionDashboard();

    test('Projects high retention for well-established high-stability items', () {
      final highStabilities = [45.0, 60.0, 90.0, 120.0];
      final forecast = dashboard.calculateForecast(highStabilities);

      expect(forecast.day7Retention, greaterThan(85.0));
      expect(forecast.masteredItemsCount, equals(4));
    });

    test('Demonstrates natural exponential decay over 90 days', () {
      final mixedStabilities = [5.0, 15.0, 30.0];
      final forecast = dashboard.calculateForecast(mixedStabilities);

      expect(forecast.day7Retention, greaterThan(forecast.day30Retention));
      expect(forecast.day30Retention, greaterThan(forecast.day90Retention));
    });
  });
}

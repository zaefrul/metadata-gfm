import 'package:flutter_test/flutter_test.dart';
import 'package:GEMS/utils/location_helper.dart';

void main() {
  group('isValidCoordinatePair', () {
    test('accepts a real Malaysia coordinate', () {
      expect(isValidCoordinatePair('3.1390', '101.6869'), isTrue);
    });

    test('rejects null, empty, and non-numeric values', () {
      expect(isValidCoordinatePair(null, '101.6'), isFalse);
      expect(isValidCoordinatePair('3.1', null), isFalse);
      expect(isValidCoordinatePair('', '101.6'), isFalse);
      expect(isValidCoordinatePair('abc', '101.6'), isFalse);
    });

    test('rejects 0 / 0.0 pairs that look like a missing GPS fix', () {
      expect(isValidCoordinatePair('0.0', '0.0'), isFalse);
      expect(isValidCoordinatePair('0', '0'), isFalse);
      expect(isValidCoordinatePair('0.00', '0.00'), isFalse);
    });

    test('rejects out-of-range latitude or longitude', () {
      expect(isValidCoordinatePair('91', '101.6'), isFalse);
      expect(isValidCoordinatePair('3.1', '181'), isFalse);
    });

    test('does not treat a single zero as valid when the other is also zero', () {
      expect(isValidCoordinatePair('0.0', '101.6869'), isTrue);
      expect(isValidCoordinatePair('3.1390', '0.0'), isTrue);
    });
  });

  group('LocationFetchResult', () {
    test('hasValidCoordinates uses pair validation, not OR against 0.0', () {
      const invalid = LocationFetchResult(
        latitude: '0.0',
        longitude: '0.0',
        status: LocationStatus.success,
        fromCache: false,
      );
      expect(invalid.hasValidCoordinates, isFalse);
      expect(invalid.isFreshFix, isFalse);

      const cached = LocationFetchResult(
        latitude: '3.1390',
        longitude: '101.6869',
        status: LocationStatus.success,
        fromCache: true,
      );
      expect(cached.hasValidCoordinates, isTrue);
      expect(cached.isFreshFix, isFalse);
    });
  });
}

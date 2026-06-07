import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/core/utils/phone_input_formatter.dart';

void main() {
  group('formatPhoneDigits', () {
    test('formats mobile number', () {
      expect(formatPhoneDigits('45991082173'), '(45) 99108-2173');
    });

    test('formats landline number', () {
      expect(formatPhoneDigits('4532101234'), '(45) 3210-1234');
    });

    test('formats partial input while typing', () {
      expect(formatPhoneDigits('45'), '(45) ');
      expect(formatPhoneDigits('4599108'), '(45) 99108');
    });
  });

  group('formatPhoneDisplay', () {
    test('formats stored digits', () {
      expect(formatPhoneDisplay('45991082173'), '(45) 99108-2173');
    });
  });
}

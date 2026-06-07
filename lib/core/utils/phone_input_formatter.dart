import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited =
        digits.length > 11 ? digits.substring(0, 11) : digits;
    final formatted = formatPhoneDigits(limited);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String stripPhoneDigits(String phone) =>
    phone.replaceAll(RegExp(r'\D'), '');

String formatPhoneDisplay(String phone) {
  final digits = stripPhoneDigits(phone);
  if (digits.isEmpty) return phone;
  return formatPhoneDigits(digits);
}

String formatPhoneDigits(String digits) {
  if (digits.isEmpty) return '';

  if (digits.length <= 2) {
    return digits.length == 1 ? '($digits' : '($digits) ';
  }

  final ddd = digits.substring(0, 2);
  final local = digits.substring(2);
  final isMobile = local.startsWith('9') || digits.length > 10;

  if (isMobile) {
    if (local.length <= 5) {
      return '($ddd) $local';
    }
    return '($ddd) ${local.substring(0, 5)}-${local.substring(5)}';
  }

  if (local.length <= 4) {
    return '($ddd) $local';
  }
  return '($ddd) ${local.substring(0, 4)}-${local.substring(4)}';
}

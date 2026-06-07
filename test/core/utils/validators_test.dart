import 'package:flutter_test/flutter_test.dart';
import 'package:green_signal/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('returns required error for empty value', () {
      expect(Validators.email(''), 'E-mail é obrigatório');
    });

    test('returns invalid for malformed email', () {
      expect(Validators.email('not-an-email'), 'E-mail inválido');
    });

    test('returns null for valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('returns required error for empty value', () {
      expect(Validators.password(''), 'Senha é obrigatório');
    });

    test('returns error for short password', () {
      expect(Validators.password('12345'), 'Senha deve ter no mínimo 6 caracteres');
    });

    test('returns null for valid password', () {
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('returns mismatch error', () {
      expect(
        Validators.confirmPassword('654321', '123456'),
        'As senhas não coincidem',
      );
    });

    test('returns null when passwords match', () {
      expect(Validators.confirmPassword('123456', '123456'), isNull);
    });
  });

  group('Validators.cep', () {
    test('returns invalid for wrong length', () {
      expect(Validators.cep('1234567'), 'CEP inválido');
    });

    test('returns null for 8 digits', () {
      expect(Validators.cep('85862-350'), isNull);
    });
  });

  group('Validators.phone', () {
    test('returns invalid for too few digits', () {
      expect(Validators.phone('123456789'), 'Telefone inválido');
    });

    test('returns invalid for too many digits', () {
      expect(Validators.phone('(11) 98888-77778'), 'Telefone inválido');
    });

    test('returns null for mobile number', () {
      expect(Validators.phone('(11) 98888-7777'), isNull);
    });
  });
}

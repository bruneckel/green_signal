class Validators {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? required(String? value, {String fieldName = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, fieldName: 'E-mail');
    if (requiredError != null) return requiredError;
    if (!_emailRegex.hasMatch(value!.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = required(value, fieldName: 'Senha');
    if (requiredError != null) return requiredError;
    if (value!.length < 6) {
      return 'Senha deve ter no mínimo 6 caracteres';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final requiredError = required(value, fieldName: 'Confirmação de senha');
    if (requiredError != null) return requiredError;
    if (value != password) {
      return 'As senhas não coincidem';
    }
    return null;
  }
}

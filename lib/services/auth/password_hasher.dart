import 'dart:convert';

import 'package:crypto/crypto.dart';

String hashPassword(String password) {
  final bytes = utf8.encode(password);
  return sha256.convert(bytes).toString();
}

bool verifyPassword(String password, String passwordHash) {
  return hashPassword(password) == passwordHash;
}

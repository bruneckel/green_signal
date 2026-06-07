import 'package:flutter/material.dart';

import 'app.dart';
import 'services/auth/local_auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authRepository = LocalAuthRepository();
  await authRepository.initialize();

  runApp(GreenSignalApp(authRepository: authRepository));
}

import 'package:flutter/material.dart';

void unfocus(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();
}

void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

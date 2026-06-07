import 'package:flutter/material.dart';

class TabScreenScaffold extends StatelessWidget {
  const TabScreenScaffold({
    super.key,
    required this.backgroundColor,
    required this.child,
  });

  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: child,
      ),
    );
  }
}

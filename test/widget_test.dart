import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:green_signal/app.dart';
import 'package:green_signal/core/constants/app_strings.dart';
import 'package:green_signal/core/constants/home_strings.dart';

void main() {
  testWidgets('Splash screen shows branding', (WidgetTester tester) async {
    await tester.pumpWidget(GreenSignalApp());
    await tester.pump();

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.tagline), findsOneWidget);
  });

  testWidgets('Splash navigates to login after delay', (WidgetTester tester) async {
    await tester.pumpWidget(GreenSignalApp());
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.welcomeTitle), findsOneWidget);
  });

  testWidgets('Login navigates to register', (WidgetTester tester) async {
    await tester.pumpWidget(GreenSignalApp());
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.signUp));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.registerTitle), findsOneWidget);
  });

  testWidgets('Login navigates to home after valid submit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(GreenSignalApp());
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text(AppStrings.login));
    await tester.pumpAndSettle();

    expect(find.text('83'), findsOneWidget);
    expect(find.text(HomeStrings.activeAlerts), findsOneWidget);
  });

  testWidgets('Bottom nav switches to map placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(GreenSignalApp());
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text(AppStrings.login));
    await tester.pumpAndSettle();

    await tester.tap(find.text(HomeStrings.navMap));
    await tester.pumpAndSettle();

    expect(find.text(HomeStrings.navMap), findsWidgets);
    expect(find.text(HomeStrings.comingSoon), findsOneWidget);
  });
}

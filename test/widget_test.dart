import 'package:flutter_test/flutter_test.dart';

import 'package:green_signal/app.dart';
import 'package:green_signal/core/constants/app_strings.dart';

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
}

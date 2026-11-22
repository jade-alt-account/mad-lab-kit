// login_test.dart: widget tests for the login screen
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gomal_mad_labs/login_app.dart';

void main() {
  testWidgets('shows errors for invalid input', (tester) async {
    await tester.pumpWidget(const LoginApp());
    await tester.enterText(find.byKey(const Key('email')), 'ali.gmail');
    await tester.enterText(find.byKey(const Key('password')), '123');
    await tester.tap(find.byKey(const Key('login')));
    await tester.pump();
    expect(find.text('Enter a valid e-mail'), findsOneWidget);
    expect(find.text('At least 8 characters'), findsOneWidget);
    expect(find.text('Dashboard'), findsNothing);
  });

  testWidgets('valid input opens the dashboard', (tester) async {
    await tester.pumpWidget(const LoginApp());
    await tester.enterText(
        find.byKey(const Key('email')), 'ali@student.pk');
    await tester.enterText(
        find.byKey(const Key('password')), 'secret123');
    await tester.tap(find.byKey(const Key('login')));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, ali@student.pk'), findsOneWidget);
  });
}

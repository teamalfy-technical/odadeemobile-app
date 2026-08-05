import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odadee/Screens/Settings/change_password_screen.dart';

void main() {
  testWidgets('change password uses the backend-compatible fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ChangePasswordScreen()),
    );

    expect(find.text('Current Password'), findsOneWidget);
    expect(find.text('New Password'), findsOneWidget);
    expect(find.text('Confirm New Password'), findsOneWidget);
    expect(
      find.text('I logged in via magic link (no current password)'),
      findsNothing,
    );
  });
}

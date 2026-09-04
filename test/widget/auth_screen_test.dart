import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campushub/features/auth/presentation/screens/auth_screen.dart';

void main() {
  testWidgets('AuthScreen renders segmented Login and Sign Up tabs correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AuthScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Brand title
    expect(find.text('CampusHub'), findsOneWidget);

    // Verify segmented tabs
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);

    // Initial state is Login
    expect(find.text('Roll No or Handle'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);

    // Tap "Sign Up" tab
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Verify Sign Up fields appear (matching user screenshot)
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Roll No (ID)'), findsOneWidget);
    expect(find.text('Security Question (For Password Recovery) *'), findsOneWidget);
    expect(find.text('Create safe account'), findsOneWidget);
  });
}

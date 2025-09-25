import 'dart:convert';
import 'package:challenge_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient((request) async {
      if (request.url.toString() == 'https://jsonplaceholder.typicode.com/posts' &&
          request.method == 'POST') {
        return http.Response(
          json.encode({'id': 101}),
          201,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response('Not Found', 404);
    });
  });

  testWidgets('Profile form validates correctly and clears after submission', (WidgetTester tester) async {
    // Wrap ProfileScreen with a Scaffold to ensure proper layout
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileScreen(client: mockClient),
        ),
      ),
    );

    // Submit empty form - expect validation errors
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Required'), findsNWidgets(3)); // Name, Email, Category
    expect(find.text('Please confirm your password'), findsOneWidget);

    // Fill invalid data
    await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'John Doe');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'invalid');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), '1234');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Invalid email'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    expect(find.text('Passwords do not match'), findsOneWidget);

    // Fill valid data
    await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'John Doe');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'john@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');
    
    // Handle dropdown selection more robustly
    final dropdownFinder = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(dropdownFinder.first);
    await tester.pumpAndSettle();
    
    // Tap the dropdown button specifically
    await tester.tap(dropdownFinder.first);
    await tester.pumpAndSettle();
    
    // Wait for dropdown menu to appear and select 'nature'
    await tester.tap(find.text('nature').last);
    await tester.pumpAndSettle();
    
    // Submit the form
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify success message
    expect(find.text('Success! Returned ID: 101'), findsOneWidget);

    // Verify form fields are cleared
    expect(find.text('John Doe'), findsNothing);
    expect(find.text('john@example.com'), findsNothing);
    expect(find.text('password123'), findsNothing);
    
    // Check that dropdown is reset by trying to submit empty form again
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Required'), findsNWidgets(3)); // Name, Email, and Category all show "Required"
    expect(find.text('Please confirm your password'), findsOneWidget);

    // Clear the validation error by pumping
    await tester.pumpAndSettle();

    // Verify form is still functional after reset
    await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'Jane Doe');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'jane@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password456');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password456');
    
    // Select different category for second test
    final dropdownFinder2 = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(dropdownFinder2.first);
    await tester.pumpAndSettle();
    
    await tester.tap(dropdownFinder2.first);
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('animals').last);
    await tester.pumpAndSettle();
    
    // Submit second form
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    
    // Verify second submission
    expect(find.text('Success! Returned ID: 101'), findsOneWidget);
    expect(find.text('Jane Doe'), findsNothing);
    expect(find.text('jane@example.com'), findsNothing);
    expect(find.text('password456'), findsNothing);
    
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Required'), findsNWidgets(3)); 
    expect(find.text('Please confirm your password'), findsOneWidget);
  });
}
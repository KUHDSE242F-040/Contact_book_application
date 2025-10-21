// This is a basic Flutter widget test for the Contact Book App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:contact_book_app/main.dart'; // Import your main.dart

void main() {
  testWidgets('App launches and displays home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ContactBookApp()); // Use your app class name

    // Verify that the home screen title is displayed.
    expect(find.text('Contact Book'), findsOneWidget);

    // You can add more tests here, e.g., tapping the add button or checking for contacts.
    // For now, this ensures the app starts without errors.
  });
}
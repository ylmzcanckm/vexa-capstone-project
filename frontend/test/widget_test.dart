// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vexa/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Login screen renders expected content', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: VexaApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hoş Geldiniz'), findsOneWidget);
    expect(find.text('Google ile Devam Et'), findsOneWidget);
    expect(find.text('Apple ile Devam Et'), findsOneWidget);
  });
}

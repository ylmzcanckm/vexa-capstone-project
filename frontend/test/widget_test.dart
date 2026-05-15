import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vexa/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('Login screen renders email auth', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: VexaApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hoş Geldiniz'), findsOneWidget);
    expect(find.text('Google ile Devam Et'), findsOneWidget);
    expect(find.text('Apple ile Devam Et'), findsOneWidget);
  });
}

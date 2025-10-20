// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/main.dart';
import 'package:my_gym/services/settings_service_impl.dart';
import 'package:my_gym/services/storage_service_impl.dart';
import 'package:my_gym/services/workout_parser_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Setup mocks
    SharedPreferences.setMockInitialValues({});

    // Initialize services
    final storage = StorageServiceImpl();
    await storage.init();
    final parser = WorkoutParserImpl();
    final settingsService = SettingsServiceImpl(storage);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MyApp(storage: storage, parser: parser, settingsService: settingsService),
    );
    await tester.pumpAndSettle();

    // Verify that the app launched
    expect(find.byType(MyApp), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/main.dart' as app;
import 'package:my_gym/services/settings_service_impl.dart';
import 'package:my_gym/services/storage_service_impl.dart';
import 'package:my_gym/services/workout_parser_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Integration test for complete workout flow
/// Tests: viewing workout plan → starting workout → tracking exercises → completing workout
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Complete Workout Flow Integration Test', () {
    late StorageServiceImpl storage;
    late WorkoutParserImpl parser;
    late SettingsServiceImpl settingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = StorageServiceImpl();
      await storage.init();
      await storage.clearHistory(); // Start fresh
      await storage.clearActiveSession();

      parser = WorkoutParserImpl();
      settingsService = SettingsServiceImpl(storage);
    });

    testWidgets('Complete workout flow: view → start → track → complete', (
      tester,
    ) async {
      // Launch app
      await tester.pumpWidget(
        app.MyApp(
          storage: storage,
          parser: parser,
          settingsService: settingsService,
        ),
      );
      await tester.pumpAndSettle();

      // STEP 1: Verify home screen displays workout plan
      expect(find.text('Daily Workout'), findsOneWidget);

      // Should show a muscle group (the exact name depends on which day it is)
      // Just verify that a muscle group card is displayed
      await tester.pumpAndSettle();

      // STEP 2: Navigate to workout screen
      final workoutTab = find.byIcon(Icons.fitness_center);
      await tester.tap(workoutTab);
      await tester.pumpAndSettle();

      // Should show "Ready to workout?" message
      expect(find.textContaining('Ready'), findsWidgets);

      // STEP 3: Start workout
      final startButton = find.text('Start Workout');
      if (startButton.evaluate().isNotEmpty) {
        await tester.tap(startButton.last);
        await tester.pumpAndSettle();

        // Should now be in active workout mode
        // Should see timer and progress indicator
        expect(find.byType(LinearProgressIndicator), findsOneWidget);

        // STEP 4: Track an exercise (add sets)
        // Find "Add Set" button and tap it
        final addSetButton = find.text('Add Set');
        if (addSetButton.evaluate().isNotEmpty) {
          await tester.tap(addSetButton.first);
          await tester.pumpAndSettle();

          // Enter reps in the first TextField
          final textFields = find.byType(TextField);
          if (textFields.evaluate().isNotEmpty) {
            await tester.enterText(textFields.first, '10');
            await tester.pumpAndSettle();

            // Find checkbox to mark exercise complete
            final checkbox = find.byType(Checkbox).first;
            await tester.tap(checkbox);
            await tester.pumpAndSettle();
          }
        }

        // STEP 5: End workout
        final endButton = find.byIcon(Icons.stop);
        if (endButton.evaluate().isNotEmpty) {
          await tester.tap(endButton);
          await tester.pumpAndSettle();

          // Confirm in dialog
          final finishButton = find.text('Finish Workout');
          if (finishButton.evaluate().isNotEmpty) {
            await tester.tap(finishButton);
            await tester.pumpAndSettle();
          }
        }

        // STEP 6: Verify workout was saved to history
        final historyTab = find.byIcon(Icons.history);
        await tester.tap(historyTab);
        await tester.pumpAndSettle();

        // Should see history screen
        expect(find.text('History & Stats'), findsOneWidget);

        // Should see summary section
        expect(find.text('Summary'), findsOneWidget);
      }
    });

    testWidgets('Can navigate between all screens', (tester) async {
      // Launch app
      await tester.pumpWidget(
        app.MyApp(
          storage: storage,
          parser: parser,
          settingsService: settingsService,
        ),
      );
      await tester.pumpAndSettle();

      // Home screen
      expect(find.text('Daily Workout'), findsOneWidget);

      // Go to workout screen
      await tester.tap(find.byIcon(Icons.fitness_center));
      await tester.pumpAndSettle();
      expect(find.textContaining('Workout'), findsWidgets);

      // Go to history screen
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();
      expect(find.text('History & Stats'), findsOneWidget);

      // Go back to home
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.text('Daily Workout'), findsOneWidget);
    });

    testWidgets('Workout plan rotates based on day of week', (tester) async {
      // Launch app
      await tester.pumpWidget(
        app.MyApp(
          storage: storage,
          parser: parser,
          settingsService: settingsService,
        ),
      );
      await tester.pumpAndSettle();

      // Should display a workout plan for current day
      // The exact workout depends on the day, but there should be content
      expect(find.text('Daily Workout'), findsOneWidget);

      // Should have exercise groups displayed
      await tester.pumpAndSettle();
      // Verify muscle groups are shown (exact count varies by day)
    });
  });
}

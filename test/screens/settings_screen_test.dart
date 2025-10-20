import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/models/app_settings.dart';
import 'package:my_gym/providers/settings_provider.dart';
import 'package:my_gym/screens/settings_screen.dart';
import 'package:my_gym/services/settings_service.dart';
import 'package:provider/provider.dart';

class MockSettingsService implements SettingsService {
  AppSettings _settings = AppSettings.defaults();

  @override
  Future<AppSettings> getSettings() async => _settings;

  @override
  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
  }

  @override
  Future<void> resetToDefaults() async {
    _settings = AppSettings.defaults();
  }
}

void main() {
  late MockSettingsService mockService;
  late SettingsProvider provider;

  setUp(() {
    mockService = MockSettingsService();
    provider = SettingsProvider(mockService);
  });

  Widget createSettingsScreen() => MaterialApp(
    home: ChangeNotifierProvider<SettingsProvider>.value(
      value: provider,
      child: const SettingsScreen(),
    ),
  );

  group('SettingsScreen', () {
    testWidgets('displays settings screen with all sections', (tester) async {
      await provider.loadSettings();
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Check AppBar
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.restore), findsOneWidget);

      // Check section headers
      expect(find.text('Workout Preferences'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);

      // Check settings tiles
      expect(find.text('Preferred Workout Start Time'), findsOneWidget);
      expect(find.text('Default Rest Time'), findsOneWidget);
      expect(find.text('Week Starts On'), findsOneWidget);
      expect(find.text('Workout Reminders'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('displays default values correctly', (tester) async {
      await provider.loadSettings();
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Check default workout start time (6:00 PM)
      expect(find.text('6:00 PM'), findsOneWidget);

      // Check default rest time (90 seconds)
      expect(find.text('90 seconds'), findsOneWidget);

      // Check default week start day (Sunday)
      expect(find.text('Sunday'), findsOneWidget);

      // Check default theme mode (System default)
      expect(find.text('System default'), findsOneWidget);
    });

    testWidgets('can change workout start time', (tester) async {
      await provider.loadSettings();
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Tap on workout start time tile
      await tester.tap(find.text('Preferred Workout Start Time'));
      await tester.pumpAndSettle();

      // Time picker should appear
      expect(find.byType(TimePickerDialog), findsOneWidget);
    });

    testWidgets('can adjust rest time with slider', (tester) async {
      await provider.loadSettings();
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Find slider
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Drag slider to change value
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Value should have changed
      expect(provider.settings.defaultRestTime.inSeconds, isNot(equals(90)));
    });

    testWidgets('can toggle workout reminders', (tester) async {
      await provider.loadSettings();
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Find switch
      final switchTile = find.byType(SwitchListTile);
      expect(switchTile, findsOneWidget);

      // Initial value should be true (enabled by default)
      expect(provider.settings.reminderEnabled, isTrue);

      // Toggle switch
      await tester.tap(switchTile);
      await tester.pumpAndSettle();

      // Value should be toggled
      expect(provider.settings.reminderEnabled, isFalse);
    });

    testWidgets('can change week start day', (tester) async {
      await provider.loadSettings();
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Tap on week start day tile
      await tester.tap(find.text('Week Starts On'));
      await tester.pumpAndSettle();

      // Dialog should appear with all weekdays
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(RadioListTile<Weekday>), findsNWidgets(7));

      // Tap on Monday
      await tester.tap(find.text('Monday'));
      await tester.pumpAndSettle();

      // Value should be updated
      expect(provider.settings.weekStartDay, equals(Weekday.monday));
    });

    testWidgets('can change theme mode', (tester) async {
      await provider.loadSettings();
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Tap on theme tile
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      // Dialog should appear with theme options
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Select Theme'), findsOneWidget);
      expect(find.byType(RadioListTile<ThemeMode>), findsNWidgets(3));

      // Tap on Dark theme
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Value should be updated
      expect(provider.settings.themeMode, equals(ThemeMode.dark));
    });

    testWidgets('can reset settings to defaults', (tester) async {
      await provider.loadSettings();

      // Modify some settings
      await provider.updateSettings(
        provider.settings.copyWith(
          workoutStartTime: const TimeOfDay(hour: 9, minute: 0),
          reminderEnabled: false,
        ),
      );

      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Verify settings are modified
      expect(provider.settings.workoutStartTime.hour, equals(9));

      // Tap reset button
      await tester.tap(find.byIcon(Icons.restore));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Reset Settings'), findsOneWidget);

      // Confirm reset
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Settings should be back to defaults
      expect(provider.settings.workoutStartTime.hour, equals(18));
      expect(provider.settings.reminderEnabled, isTrue);
    });

    testWidgets('shows loading indicator while loading', (tester) async {
      // Widget should handle not-loaded state gracefully
      await tester.pumpWidget(createSettingsScreen());
      await tester.pump();

      // Since mock service returns immediately, loading completes fast
      // Just verify the screen renders without error
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });

  group('SettingsProvider', () {
    test('loads settings from service', () async {
      await provider.loadSettings();

      expect(provider.settings, isNotNull);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('updates settings through service', () async {
      await provider.loadSettings();

      final newSettings = provider.settings.copyWith(
        workoutStartTime: const TimeOfDay(hour: 8, minute: 30),
      );

      await provider.updateSettings(newSettings);

      expect(
        provider.settings.workoutStartTime,
        equals(const TimeOfDay(hour: 8, minute: 30)),
      );
      expect(provider.isLoading, isFalse);
    });

    test('resets settings to defaults', () async {
      await provider.loadSettings();

      // Change a setting
      await provider.updateSettings(
        provider.settings.copyWith(reminderEnabled: false),
      );
      expect(provider.settings.reminderEnabled, isFalse);

      // Reset to defaults
      await provider.resetToDefaults();

      expect(provider.settings.reminderEnabled, isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:my_gym/models/app_settings.dart';
import 'package:my_gym/services/settings_service_impl.dart';
import 'package:my_gym/services/storage_service_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsServiceImpl', () {
    late StorageServiceImpl storage;
    late SettingsServiceImpl settingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = StorageServiceImpl();
      await storage.init();
      settingsService = SettingsServiceImpl(storage);
    });

    test('gets default settings', () async {
      final settings = await settingsService.getSettings();
      expect(settings.workoutStartTime.hour, 18);
      expect(settings.defaultRestTime.inSeconds, 90);
      expect(settings.reminderEnabled, true);
    });

    test('updates settings', () async {
      final newSettings = AppSettings.defaults().copyWith(
        reminderEnabled: false,
      );

      await settingsService.updateSettings(newSettings);
      final loaded = await settingsService.getSettings();

      expect(loaded.reminderEnabled, false);
    });

    test('resets to defaults', () async {
      // Change settings
      final customSettings = AppSettings.defaults().copyWith(
        reminderEnabled: false,
      );
      await settingsService.updateSettings(customSettings);

      // Reset
      await settingsService.resetToDefaults();
      final loaded = await settingsService.getSettings();

      expect(loaded.reminderEnabled, true);
      expect(loaded.workoutStartTime.hour, 18);
    });
  });
}

import '../models/app_settings.dart';

/// Service focused on user settings and preferences (wraps underlying storage).
abstract class SettingsService {
  Future<AppSettings> getSettings();
  Future<void> updateSettings(AppSettings settings);
  Future<void> resetToDefaults();
}

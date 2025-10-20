import '../models/app_settings.dart';
import 'settings_service.dart';
import 'storage_service.dart';

/// Concrete implementation of settings service wrapping storage.
class SettingsServiceImpl implements SettingsService {
  SettingsServiceImpl(this._storage);
  final StorageService _storage;

  @override
  Future<AppSettings> getSettings() => _storage.loadSettings();

  @override
  Future<void> updateSettings(AppSettings settings) =>
      _storage.saveSettings(settings);

  @override
  Future<void> resetToDefaults() =>
      _storage.saveSettings(AppSettings.defaults());
}

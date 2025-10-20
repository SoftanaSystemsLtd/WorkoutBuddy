import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

/// Provides app/user settings (e.g., preferred start time) backed by local storage.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._service);

  final SettingsService _service;
  AppSettings _settings = AppSettings.defaults();
  bool _isLoading = false;
  String? _errorMessage;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _service.getSettings();
    } catch (e) {
      _errorMessage = 'Failed to load settings: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.updateSettings(newSettings);
      _settings = newSettings;
    } catch (e) {
      _errorMessage = 'Failed to update settings: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetToDefaults() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.resetToDefaults();
      _settings = AppSettings.defaults();
    } catch (e) {
      _errorMessage = 'Failed to reset settings: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

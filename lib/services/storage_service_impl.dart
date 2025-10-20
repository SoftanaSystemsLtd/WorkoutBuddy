import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/workout_plan.dart';
import '../models/workout_session.dart';
import 'storage_service.dart';

const String _keyActiveSession = 'active_workout_session';
const String _keyHistory = 'workout_history';
const String _keySettings = 'app_settings';
const String _keyCachedPlans = 'cached_workout_plans';
const String _keyCacheTimestamp = 'cache_timestamp';
const String _keyManualPlanIndex = 'manual_plan_index';

/// Concrete implementation using shared_preferences for persistence.
class StorageServiceImpl implements StorageService {
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw StorageException(
        'StorageService not initialized. Call init() first.',
      );
    }
    return _prefs!;
  }

  @override
  Future<WorkoutSession?> loadActiveSession() async {
    final json = _preferences.getString(_keyActiveSession);
    if (json == null) {
      return null;
    }

    try {
      return WorkoutSession.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (e) {
      throw StorageException('Failed to decode active session: $e');
    }
  }

  @override
  Future<void> saveActiveSession(WorkoutSession session) async {
    session.validate();
    final json = jsonEncode(session.toJson());
    await _preferences.setString(_keyActiveSession, json);
  }

  @override
  Future<void> clearActiveSession() async {
    await _preferences.remove(_keyActiveSession);
  }

  @override
  Future<List<WorkoutSession>> loadHistory({int? limit}) async {
    final json = _preferences.getString(_keyHistory);
    if (json == null) {
      return [];
    }

    try {
      final list = jsonDecode(json) as List<dynamic>;
      var sessions = list
          .map((e) => WorkoutSession.fromJson(e as Map<String, dynamic>))
          .toList();

      // Sort by startTime descending (most recent first)
      sessions.sort((a, b) => b.startTime.compareTo(a.startTime));

      if (limit != null && sessions.length > limit) {
        sessions = sessions.take(limit).toList();
      }

      return sessions;
    } catch (e) {
      throw StorageException('Failed to load history: $e');
    }
  }

  @override
  Future<void> appendToHistory(WorkoutSession session) async {
    if (session.status == SessionStatus.inProgress) {
      throw StorageException('Cannot append in-progress session to history');
    }

    session.validate();

    final history = await loadHistory();
    history.add(session);
    await overwriteHistory(history);
  }

  @override
  Future<void> overwriteHistory(List<WorkoutSession> sessions) async {
    final json = jsonEncode(sessions.map((e) => e.toJson()).toList());
    await _preferences.setString(_keyHistory, json);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    final history = await loadHistory();
    final updated = history.where((s) => s.id != sessionId).toList();
    await overwriteHistory(updated);
  }

  @override
  Future<void> clearHistory() async {
    await _preferences.remove(_keyHistory);
  }

  @override
  Future<AppSettings> loadSettings() async {
    final json = _preferences.getString(_keySettings);
    if (json == null) {
      return AppSettings.defaults();
    }

    try {
      return AppSettings.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (e) {
      // Return defaults if parsing fails
      return AppSettings.defaults();
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final json = jsonEncode(settings.toJson());
    await _preferences.setString(_keySettings, json);
  }

  @override
  Future<String> exportData() async {
    final history = await loadHistory();
    final settings = await loadSettings();

    final data = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'history': history.map((e) => e.toJson()).toList(),
      'settings': settings.toJson(),
    };

    return jsonEncode(data);
  }

  @override
  Future<void> importData(String jsonPayload) async {
    try {
      final data = jsonDecode(jsonPayload) as Map<String, dynamic>;

      // Import history
      if (data.containsKey('history')) {
        final historyList = (data['history'] as List<dynamic>)
            .map((e) => WorkoutSession.fromJson(e as Map<String, dynamic>))
            .toList();
        await overwriteHistory(historyList);
      }

      // Import settings
      if (data.containsKey('settings')) {
        final settings = AppSettings.fromJson(
          data['settings'] as Map<String, dynamic>,
        );
        await saveSettings(settings);
      }
    } catch (e) {
      throw StorageException('Failed to import data: $e');
    }
  }

  /// Cache workout plans with timestamp
  @override
  Future<void> saveCachedWorkoutPlans(
    List<WorkoutPlan> plans,
    DateTime timestamp,
  ) async {
    final json = jsonEncode(plans.map((e) => e.toJson()).toList());
    await _preferences.setString(_keyCachedPlans, json);
    await _preferences.setString(
      _keyCacheTimestamp,
      timestamp.toIso8601String(),
    );
  }

  /// Load cached workout plans
  @override
  Future<List<WorkoutPlan>?> loadCachedWorkoutPlans() async {
    final json = _preferences.getString(_keyCachedPlans);
    if (json == null) {
      return null;
    }

    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => WorkoutPlan.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Get cache timestamp
  @override
  Future<DateTime?> getCacheTimestamp() async {
    final timestamp = _preferences.getString(_keyCacheTimestamp);
    if (timestamp == null) {
      return null;
    }

    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      return null;
    }
  }

  /// Clear all cached workout plans
  @override
  Future<void> clearWorkoutCache() async {
    await _preferences.remove(_keyCachedPlans);
    await _preferences.remove(_keyCacheTimestamp);
  }

  // Manual selection persistence helpers
  @override
  Future<void> saveManualPlanIndex(int? index) async {
    if (index == null) {
      await _preferences.remove(_keyManualPlanIndex);
    } else {
      await _preferences.setInt(_keyManualPlanIndex, index);
    }
  }

  @override
  Future<int?> loadManualPlanIndex() async =>
      _preferences.getInt(_keyManualPlanIndex);
}

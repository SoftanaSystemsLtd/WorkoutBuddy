import '../models/app_settings.dart';
import '../models/workout_plan.dart';
import '../models/workout_session.dart';

/// Generic storage exception.
class StorageException implements Exception {
  StorageException(this.message);
  final String message;
  @override
  String toString() => 'StorageException: $message';
}

/// Abstraction over persistence for sessions, history, and settings.
abstract class StorageService {
  Future<void> init();

  // Session cache (active or recent sessions not yet in history)
  Future<WorkoutSession?> loadActiveSession();
  Future<void> saveActiveSession(WorkoutSession session);
  Future<void> clearActiveSession();

  // History
  Future<List<WorkoutSession>> loadHistory({int? limit});
  Future<void> appendToHistory(
    WorkoutSession session,
  ); // session must be completed
  Future<void> overwriteHistory(List<WorkoutSession> sessions);
  Future<void> deleteSession(String sessionId);
  Future<void> clearHistory();

  // Settings
  Future<AppSettings> loadSettings();
  Future<void> saveSettings(AppSettings settings);

  // Export / Import (JSON string form)
  Future<String> exportData();
  Future<void> importData(String jsonPayload);

  // Workout plan cache operations
  Future<void> saveCachedWorkoutPlans(
    List<WorkoutPlan> plans,
    DateTime timestamp,
  );
  Future<List<WorkoutPlan>?> loadCachedWorkoutPlans();
  Future<DateTime?> getCacheTimestamp();
  Future<void> clearWorkoutCache();
}

import 'package:flutter/foundation.dart';

import '../models/workout_plan.dart';
import '../models/workout_session.dart';
import '../services/storage_service.dart';
import '../services/workout_parser_impl.dart';

/// Provides workout plan and active session state.
class WorkoutProvider extends ChangeNotifier {
  WorkoutProvider(this._parser, this._storage);

  final WorkoutParserImpl _parser;
  final StorageService _storage;

  List<WorkoutPlan>? _workoutPlans;
  WorkoutPlan? _currentDayPlan;
  WorkoutSession? _activeSession;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<WorkoutPlan>? get workoutPlans => _workoutPlans;
  WorkoutPlan? get currentDayPlan => _currentDayPlan;
  WorkoutSession? get activeSession => _activeSession;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Initialize: load cached plans or parse from asset
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      // Try loading from cache first
      final cachedPlans = await _storage.loadCachedWorkoutPlans();
      if (cachedPlans != null && cachedPlans.isNotEmpty) {
        _workoutPlans = cachedPlans;
        _updateCurrentDayPlan();
        _setLoading(false);
        return;
      }

      // Parse from asset if no cache
      await _parseAndCacheWorkouts();
    } catch (e) {
      _setError('Failed to load workout plans: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Parse workouts from asset and cache
  Future<void> _parseAndCacheWorkouts() async {
    try {
      final parsed = await _parser.parseAsset('assets/workouts/workouts.md');
      final plans = await _parser.parseWorkoutPlans(parsed);

      if (plans.length != 4) {
        throw Exception('Expected 4 workout plans, got ${plans.length}');
      }

      _workoutPlans = plans;
      await _storage.saveCachedWorkoutPlans(plans, DateTime.now());
      _updateCurrentDayPlan();
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh workout plans from asset (clears cache)
  Future<void> refreshWorkoutPlans() async {
    _setLoading(true);
    _clearError();

    try {
      _parser.clearCache();
      await _storage.clearWorkoutCache();
      await _parseAndCacheWorkouts();
    } catch (e) {
      _setError('Failed to refresh workout plans: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Determine current day's workout plan based on week cycle
  /// Days cycle 1-4 starting from Sunday
  void _updateCurrentDayPlan() {
    if (_workoutPlans == null || _workoutPlans!.isEmpty) {
      _currentDayPlan = null;
      return;
    }

    final dayIndex = getCurrentWorkoutDayIndex();
    _currentDayPlan = _workoutPlans![dayIndex];
    notifyListeners();
  }

  /// Get current workout day index (0-3) based on weekday
  /// Sunday=Day1, Monday=Day2, Tuesday=Day3, Wednesday=Day4, Thursday=Day1...
  int getCurrentWorkoutDayIndex() {
    final now = DateTime.now();
    final weekday = now.weekday; // 1=Monday, 7=Sunday

    // Convert to 0-based Sunday start: Sunday=0, Monday=1, etc.
    final sundayBased = weekday == 7 ? 0 : weekday;

    // Map to 4-day cycle (0-3)
    return sundayBased % 4;
  }

  /// Pure deterministic helper for testing day index logic.
  static int computeWorkoutDayIndex(DateTime date) {
    final weekday = date.weekday; // 1=Monday, 7=Sunday
    final sundayBased = weekday == 7 ? 0 : weekday;
    return sundayBased % 4; // 0..3
  }

  /// Get workout plan for specific day number (1-4)
  WorkoutPlan? getWorkoutPlanByDay(int dayNumber) {
    if (_workoutPlans == null || dayNumber < 1 || dayNumber > 4) {
      return null;
    }
    return _workoutPlans!.firstWhere((p) => p.dayNumber == dayNumber);
  }

  // Session management (for User Story 2)
  Future<void> startSession(String workoutPlanId) async {
    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workoutPlanId: workoutPlanId,
      startTime: DateTime.now(),
      status: SessionStatus.inProgress,
      completedExercises: const [],
    );

    _activeSession = session;
    await _storage.saveActiveSession(session);
    notifyListeners();
  }

  /// Load active session on initialization
  Future<void> loadActiveSession() async {
    _activeSession = await _storage.loadActiveSession();
    notifyListeners();
  }

  /// Record exercise completion with sets
  Future<void> recordExercise(String exerciseName, List<SetData> sets) async {
    if (_activeSession == null) {
      return;
    }

    final exerciseSet = ExerciseSet(
      exerciseName: exerciseName,
      sets: sets,
      completedAt: DateTime.now(),
    );

    final updatedExercises = List<ExerciseSet>.from(
      _activeSession!.completedExercises,
    )..add(exerciseSet);

    _activeSession = _activeSession!.copyWith(
      completedExercises: updatedExercises,
    );

    await _storage.saveActiveSession(_activeSession!);
    notifyListeners();
  }

  /// Check if exercise is completed in current session
  bool isExerciseCompleted(String exerciseName) {
    if (_activeSession == null) {
      return false;
    }
    return _activeSession!.completedExercises.any(
      (e) => e.exerciseName == exerciseName,
    );
  }

  /// Get completed sets for an exercise
  List<SetData>? getCompletedSets(String exerciseName) {
    if (_activeSession == null) {
      return null;
    }
    final exercise = _activeSession!.completedExercises
        .where((e) => e.exerciseName == exerciseName)
        .firstOrNull;
    return exercise?.sets;
  }

  Future<void> endSession() async {
    if (_activeSession == null) {
      return;
    }

    final completedSession = _activeSession!.copyWith(
      status: SessionStatus.completed,
      endTime: DateTime.now(),
    );

    await _storage.appendToHistory(completedSession);
    await _storage.clearActiveSession();
    _activeSession = null;
    notifyListeners();
  }

  /// Abandon current session without saving to history
  Future<void> abandonSession() async {
    if (_activeSession == null) {
      return;
    }

    final abandonedSession = _activeSession!.copyWith(
      status: SessionStatus.abandoned,
      endTime: DateTime.now(),
    );

    await _storage.clearActiveSession();
    _activeSession = abandonedSession; // Keep in memory briefly for summary
    notifyListeners();
  }

  // Private helpers
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}

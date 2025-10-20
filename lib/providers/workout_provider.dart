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
  int? _manualPlanIndex; // 0-based override when user manually selects a plan
  WorkoutSession? _activeSession;
  bool _isLoading = false;
  String? _errorMessage;
  // Draft (in-progress, not yet marked complete) sets per exercise during a session
  final Map<String, List<SetData>> _draftSets = {};

  // Getters
  List<WorkoutPlan>? get workoutPlans => _workoutPlans;

  /// Currently active plan for display/use. If user manually selected
  /// a plan this returns that; otherwise it returns the recommended
  /// plan based on the rotating weekday logic.
  WorkoutPlan? get currentDayPlan => _currentDayPlan;
  bool get isManualSelection => _manualPlanIndex != null;
  int? get manualPlanIndex => _manualPlanIndex;
  int get recommendedPlanIndex => getCurrentWorkoutDayIndex();
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
        // Attempt to load manual selection if storage impl supports it.
        await _restoreManualSelection();
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
      await _restoreManualSelection();
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

    // If user manually selected a plan, retain that selection unless out of range
    if (_manualPlanIndex != null) {
      if (_manualPlanIndex! < 0 || _manualPlanIndex! >= _workoutPlans!.length) {
        _manualPlanIndex = null; // reset invalid manual selection
      } else {
        _currentDayPlan = _workoutPlans![_manualPlanIndex!];
        notifyListeners();
        return;
      }
    }

    final dayIndex = getCurrentWorkoutDayIndex();
    _currentDayPlan = _workoutPlans![dayIndex];
    notifyListeners();
  }

  /// Manually select a workout plan by its day number (1-4). This overrides
  /// the automatic weekday mapping until [clearManualPlanSelection] is called
  /// or plans are refreshed and the index becomes invalid.
  void selectPlanByDayNumber(int dayNumber) {
    if (_workoutPlans == null) {
      return;
    }
    // Using block form for clarity over long line; ignore style lint.
    // ignore: prefer_expression_function_bodies
    final plan = _workoutPlans!.firstWhere(
      (p) => p.dayNumber == dayNumber,
      orElse: () => _workoutPlans!.first,
    );
    _manualPlanIndex = _workoutPlans!.indexOf(plan);
    _updateCurrentDayPlan();
  }

  /// Manually select a workout plan by zero-based index.
  void selectPlanByIndex(int index) {
    if (_workoutPlans == null || index < 0 || index >= _workoutPlans!.length) {
      return;
    }
    _manualPlanIndex = index;
    _persistManualSelection();
    _updateCurrentDayPlan();
  }

  /// Revert to automatic (weekday-driven) plan selection.
  void clearManualPlanSelection() {
    if (_manualPlanIndex != null) {
      _manualPlanIndex = null;
      _persistManualSelection();
      _updateCurrentDayPlan();
    }
  }

  Future<void> _persistManualSelection() async {
    try {
      await _storage.saveManualPlanIndex(_manualPlanIndex);
    } catch (_) {
      // Ignore persistence failures for manual selection
    }
  }

  Future<void> _restoreManualSelection() async {
    try {
      final loaded = await _storage.loadManualPlanIndex();
      if (loaded != null) {
        _manualPlanIndex = loaded;
      }
    } catch (_) {
      // Ignore load failures
    }
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

  /// Explicitly mark an exercise as completed (idempotent). Replaces existing entry if present.
  Future<void> completeExercise(String exerciseName, List<SetData> sets) async {
    if (_activeSession == null) {
      return;
    }
    // Ensure there is at least one valid set (reps > 0) to satisfy invariants.
    final sanitized = sets.where((s) => s.reps > 0).toList();
    if (sanitized.isEmpty) {
      sanitized.add(const SetData(reps: 1));
    }
    // Remove any prior draft/completion of same exercise
    final updated = List<ExerciseSet>.from(_activeSession!.completedExercises)
      ..removeWhere((e) => e.exerciseName == exerciseName)
      ..add(
        ExerciseSet(
          exerciseName: exerciseName,
          sets: sanitized,
          completedAt: DateTime.now(),
        ),
      );
    _activeSession = _activeSession!.copyWith(completedExercises: updated);
    // Clear draft once completed
    _draftSets.remove(exerciseName);
    await _storage.saveActiveSession(_activeSession!);
    notifyListeners();
  }

  /// Unmark a previously completed exercise; retains draft sets only in UI state.
  Future<void> uncompleteExercise(String exerciseName) async {
    if (_activeSession == null) {
      return;
    }
    // Find existing completed sets to move back to draft
    final existing = _activeSession!.completedExercises.firstWhere(
      (e) => e.exerciseName == exerciseName,
      orElse: () => ExerciseSet(
        exerciseName: '',
        sets: const [],
        completedAt: DateTime.now(),
      ),
    );
    if (existing.exerciseName.isNotEmpty && existing.sets.isNotEmpty) {
      _draftSets[exerciseName] = existing.sets;
    }
    final updated = List<ExerciseSet>.from(_activeSession!.completedExercises)
      ..removeWhere((e) => e.exerciseName == exerciseName);
    _activeSession = _activeSession!.copyWith(completedExercises: updated);
    await _storage.saveActiveSession(_activeSession!);
    notifyListeners();
  }

  /// Update draft sets for an exercise (not marking completion yet).
  void updateDraftSets(String exerciseName, List<SetData> sets) {
    if (_activeSession == null) {
      return;
    }
    if (sets.isEmpty) {
      _draftSets.remove(exerciseName); // Remove empty drafts
    } else {
      _draftSets[exerciseName] = sets;
    }
    notifyListeners();
  }

  /// Retrieve draft (uncompleted) sets for an exercise.
  List<SetData>? getDraftSets(String exerciseName) => _draftSets[exerciseName];

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

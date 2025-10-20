import 'package:flutter/foundation.dart';
import '../models/workout_session.dart';
import '../services/storage_service.dart';
import '../utils/history_stats_utils.dart';

/// Simple value object for aggregate statistics.
@immutable
class HistoryStats {
  const HistoryStats({
    required this.totalWorkouts,
    required this.totalSets,
    required this.totalVolume,
    required this.averageDuration,
    required this.volumePerExercise,
    required this.setsPerExercise,
  });

  static const empty = HistoryStats(
    totalWorkouts: 0,
    totalSets: 0,
    totalVolume: 0,
    averageDuration: Duration.zero,
    volumePerExercise: {},
    setsPerExercise: {},
  );

  final int totalWorkouts;
  final int totalSets; // number of sets across all exercises
  final double totalVolume; // sum(weight * reps) where weight provided
  final Duration averageDuration; // average session duration
  final Map<String, double> volumePerExercise; // exerciseName -> volume
  final Map<String, int> setsPerExercise; // exerciseName -> set count
}

/// Filtering criteria container.
class HistoryFilter {
  const HistoryFilter({this.from, this.to, this.exerciseNameQuery});

  final DateTime? from;
  final DateTime? to;
  final String? exerciseNameQuery; // substring match

  HistoryFilter copyWith({
    DateTime? from,
    DateTime? to,
    String? exerciseNameQuery,
  }) => HistoryFilter(
    from: from ?? this.from,
    to: to ?? this.to,
    exerciseNameQuery: exerciseNameQuery ?? this.exerciseNameQuery,
  );

  bool matches(WorkoutSession session) {
    if (from != null && session.startTime.isBefore(from!)) {
      return false;
    }
    if (to != null && session.startTime.isAfter(to!)) {
      return false;
    }
    if (exerciseNameQuery != null && exerciseNameQuery!.isNotEmpty) {
      final q = exerciseNameQuery!.toLowerCase();
      final anyMatch = session.completedExercises.any(
        (e) => e.exerciseName.toLowerCase().contains(q),
      );
      if (!anyMatch) {
        return false;
      }
    }
    return true;
  }
}

class HistoryProvider extends ChangeNotifier {
  HistoryProvider(this._storage);

  final StorageService _storage;

  List<WorkoutSession> _allSessions = [];
  List<WorkoutSession> _filtered = [];
  HistoryFilter _filter = const HistoryFilter();
  HistoryStats _stats = HistoryStats.empty;
  bool _isLoading = false;
  String? _error;

  // Public getters
  List<WorkoutSession> get sessions => _filtered;
  HistoryStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _error;
  bool get hasError => _error != null;
  HistoryFilter get currentFilter => _filter;

  Future<void> loadHistory() async {
    _setLoading(true);
    _clearError();
    try {
      _allSessions = await _storage.loadHistory();
      _applyFilterInternal();
    } catch (e) {
      _setError('Failed to load history: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshHistory() async => loadHistory();

  void applyFilter(HistoryFilter filter) {
    _filter = filter;
    _applyFilterInternal();
    notifyListeners();
  }

  void clearFilter() {
    _filter = const HistoryFilter();
    _applyFilterInternal();
    notifyListeners();
  }

  /// Export all workout history as JSON string
  Future<String> exportHistory() async {
    try {
      return await _storage.exportData();
    } catch (e) {
      _setError('Failed to export history: $e');
      rethrow;
    }
  }

  /// Clear all workout history
  Future<void> clearAllHistory() async {
    _setLoading(true);
    _clearError();
    try {
      await _storage.clearHistory();
      _allSessions = [];
      _filtered = [];
      _stats = HistoryStats.empty;
    } catch (e) {
      _setError('Failed to clear history: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _applyFilterInternal() {
    _filtered = _allSessions.where(_filter.matches).toList();
    _computeStats();
  }

  void _computeStats() {
    _stats = computeHistoryStats(_filtered);
  }

  // Error & loading helpers
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}

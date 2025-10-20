# Storage Service Contract

## Interface: IStorageService

**Responsibility**: Handle all local data persistence operations for workout sessions, settings, and cached data

### Workout History Operations

#### saveWorkoutSession()
```dart
Future<void> saveWorkoutSession(WorkoutSession session)
```

**Description**: Persist a completed or in-progress workout session

**Parameters**:
- `session`: WorkoutSession - Session data to save

**Throws**:
- `StorageException` - When save operation fails
- `ValidationException` - When session data is invalid

#### getWorkoutHistory()
```dart
Future<List<WorkoutSession>> getWorkoutHistory({
  DateTime? startDate,
  DateTime? endDate, 
  int? limit
})
```

**Description**: Retrieve workout history with optional filtering

**Parameters**:
- `startDate`: DateTime? - Filter sessions after this date (optional)
- `endDate`: DateTime? - Filter sessions before this date (optional)  
- `limit`: int? - Maximum number of sessions to return (optional)

**Returns**:
- `Future<List<WorkoutSession>>` - List of workout sessions ordered by startTime (most recent first)

#### getActiveWorkoutSession()
```dart
Future<WorkoutSession?> getActiveWorkoutSession()
```

**Description**: Get current in-progress workout session if any exists

**Returns**:
- `Future<WorkoutSession?>` - Active session or null if none in progress

#### deleteWorkoutSession()
```dart
Future<void> deleteWorkoutSession(String sessionId)
```

**Description**: Remove a specific workout session from history

**Parameters**:
- `sessionId`: String - UUID of session to delete

### Settings Operations

#### saveSettings()
```dart
Future<void> saveSettings(AppSettings settings)
```

**Description**: Persist user application settings

**Parameters**:
- `settings`: AppSettings - Complete settings object to save

#### getSettings()
```dart
Future<AppSettings> getSettings()
```

**Description**: Load user settings with defaults for missing values

**Returns**:
- `Future<AppSettings>` - User settings with defaults applied

#### updateSetting<T>()
```dart
Future<void> updateSetting<T>(String key, T value)
```

**Description**: Update a single setting value

**Parameters**:
- `key`: String - Setting key (e.g., 'workoutStartTime', 'defaultRestTime')
- `value`: T - New value for the setting

### Cache Operations

#### saveCachedWorkoutPlans()
```dart
Future<void> saveCachedWorkoutPlans(List<WorkoutPlan> plans, DateTime timestamp)
```

**Description**: Cache parsed workout plan data with timestamp

**Parameters**:
- `plans`: List<WorkoutPlan> - Parsed workout plans to cache
- `timestamp`: DateTime - When the cache was created

#### getCachedWorkoutPlans()
```dart
Future<CachedWorkoutData?> getCachedWorkoutPlans()
```

**Description**: Load cached workout plans if available

**Returns**:
- `Future<CachedWorkoutData?>` - Cached data with timestamp, or null if no cache

#### clearCache()
```dart
Future<void> clearCache()
```

**Description**: Remove all cached workout plan data

### Data Management

#### exportData()
```dart
Future<String> exportData()
```

**Description**: Export all user data as JSON string for backup

**Returns**:
- `Future<String>` - JSON string containing all workout history and settings

#### importData()
```dart
Future<void> importData(String jsonData)
```

**Description**: Import workout history and settings from JSON backup

**Parameters**:
- `jsonData`: String - JSON data to import

**Throws**:
- `ImportException` - When import data is malformed or incompatible

#### getStorageSize()
```dart
Future<int> getStorageSize()
```

**Description**: Get total storage space used by the app in bytes

**Returns**:
- `Future<int>` - Storage size in bytes

## Data Models

### CachedWorkoutData
```dart
class CachedWorkoutData {
  final List<WorkoutPlan> plans;
  final DateTime timestamp;
  final String sourceFileHash;
  
  const CachedWorkoutData({
    required this.plans,
    required this.timestamp, 
    required this.sourceFileHash,
  });
}
```

## Error Handling

### StorageException
```dart
class StorageException implements Exception {
  final String operation;
  final String message;
  final Exception? cause;
  
  const StorageException(this.operation, this.message, [this.cause]);
}
```

### ImportException
```dart
class ImportException implements Exception {
  final String reason;
  final String? expectedFormat;
  
  const ImportException(this.reason, [this.expectedFormat]);
}
```

## File Structure

```
/app_documents/
├── workout_history.json      # All workout sessions
├── app_settings.json         # User preferences  
├── workout_cache.json        # Cached parsed workout plans
└── backups/                  # Optional backup files
    └── backup_YYYYMMDD.json
```

## Performance Requirements

- **Save operations**: Complete within 500ms
- **Load operations**: Complete within 1 second  
- **History queries**: Support 1000+ workout sessions efficiently
- **Memory usage**: Lazy loading for large datasets

## Testing Contract

### Unit Tests Required
- Save and retrieve workout sessions correctly
- Handle file corruption gracefully
- Settings persistence with proper defaults
- Cache invalidation works as expected
- Import/export maintains data integrity
- Performance requirements met

### Mock Data
```dart
final mockWorkoutSession = WorkoutSession(
  id: 'test-session-id',
  workoutPlanId: 'day_1',
  startTime: DateTime.now(),
  status: SessionStatus.completed,
  completedExercises: [],
);
```

## Integration Points

- **Provider State**: Load/save state changes automatically
- **WorkoutScreen**: Real-time session persistence
- **SettingsScreen**: Immediate settings persistence
- **HomeScreen**: Load cached workout plans for display
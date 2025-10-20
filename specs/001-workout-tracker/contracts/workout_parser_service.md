# Workout Parser Service Contract

## Interface: IWorkoutParserService

**Responsibility**: Parse workouts.md file into structured WorkoutPlan entities

### Methods

#### parseWorkoutsFile()
```dart
Future<List<WorkoutPlan>> parseWorkoutsFile(String filePath)
```

**Description**: Parse the workouts.md file and return structured workout plan data

**Parameters**:
- `filePath`: String - Absolute path to workouts.md file

**Returns**: 
- `Future<List<WorkoutPlan>>` - List of 4 workout plans (Day 1-4)

**Throws**:
- `FileNotFoundException` - When workouts.md file doesn't exist
- `ParseException` - When file format is invalid or corrupted
- `ValidationException` - When parsed data doesn't match expected structure

**Expected Behavior**:
- Parse markdown headers to identify workout days
- Extract muscle group sections and exercise lists
- Validate that all 4 days are present
- Return WorkoutPlan objects with proper nesting structure

#### validateWorkoutStructure()
```dart
Future<bool> validateWorkoutStructure(String filePath)
```

**Description**: Validate workouts.md file format without full parsing

**Parameters**:
- `filePath`: String - Path to workouts.md file

**Returns**:
- `Future<bool>` - true if file format is valid, false otherwise

**Use Cases**:
- Quick validation before full parsing
- Pre-flight check during app startup
- File integrity verification

#### getCacheTimestamp()
```dart
Future<DateTime?> getCacheTimestamp()
```

**Description**: Get the last modification time of cached workout data

**Returns**:
- `Future<DateTime?>` - Last cache update time, null if no cache exists

#### shouldRefreshCache()
```dart
Future<bool> shouldRefreshCache(String workoutFilePath)
```

**Description**: Determine if workout cache needs refreshing based on source file changes

**Parameters**:
- `workoutFilePath`: String - Path to source workouts.md file

**Returns**:
- `Future<bool>` - true if cache should be refreshed

**Logic**:
- Compare workouts.md modification time with cache timestamp
- Return true if source file is newer or cache doesn't exist

## Error Handling

### FileNotFoundException
```dart
class FileNotFoundException implements Exception {
  final String filePath;
  final String message;
  
  const FileNotFoundException(this.filePath, this.message);
}
```

### ParseException
```dart
class ParseException implements Exception {
  final String content;
  final String reason;
  final int? lineNumber;
  
  const ParseException(this.content, this.reason, [this.lineNumber]);
}
```

### ValidationException
```dart
class ValidationException implements Exception {
  final String field;
  final String expectedFormat;
  final String actualValue;
  
  const ValidationException(this.field, this.expectedFormat, this.actualValue);
}
```

## Implementation Requirements

1. **Regex Patterns**: Use consistent regex patterns for parsing day headers and exercise lists
2. **Caching Strategy**: Implement intelligent caching to avoid re-parsing unchanged files
3. **Error Recovery**: Provide detailed error messages with line numbers when parsing fails
4. **Performance**: Parse and cache operation should complete within 2 seconds
5. **Memory Efficiency**: Stream parsing for large files (future-proofing)

## Testing Contract

### Unit Tests Required
- Parse valid workouts.md file successfully
- Handle missing file gracefully with proper exception
- Detect malformed markdown structure
- Validate all 4 workout days are present
- Cache invalidation logic works correctly
- Performance requirements met (parsing time < 2s)

### Mock Data Format
```dart
const String mockWorkoutContent = '''
Day 1: (Back and Biceps)
Upper Back
1. High Row
2. Seated row

Mid Back
1. T-bar row
2. Barbel or dumbel row
''';
```

## Integration Points

- **StorageService**: Save/load cached workout plan data
- **HomeScreen**: Display today's workout plan
- **WorkoutScreen**: Access exercise lists for active session tracking
- **Provider State**: Update workout plan state when cache refreshes
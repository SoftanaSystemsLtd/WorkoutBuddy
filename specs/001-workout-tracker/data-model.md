# Data Model: Personal Workout Tracker App

**Feature**: Personal Workout Tracker App  
**Created**: 2025-10-20  
**Status**: Complete

## Core Entities

### WorkoutPlan
Represents a complete daily workout plan (Day 1-4) with organized muscle groups and exercises.

**Fields**:
- `id`: String (e.g., "day_1", "day_2", "day_3", "day_4")
- `name`: String (e.g., "Back and Biceps", "Chest and Triceps")
- `muscleGroups`: List<MuscleGroup>
- `dayNumber`: int (1-4)

**Validation Rules**:
- id must match pattern "day_[1-4]"
- name must be non-empty string
- muscleGroups list must contain at least one muscle group
- dayNumber must be between 1 and 4

**Relationships**:
- Contains multiple MuscleGroup entities
- Referenced by WorkoutSession entities

### MuscleGroup
Represents a specific muscle group section within a workout plan (e.g., "Upper Back", "Bicep: Outer head").

**Fields**:
- `name`: String (muscle group identifier)
- `exercises`: List<Exercise>
- `category`: String (broader category if applicable)

**Validation Rules**:
- name must be non-empty and unique within workout plan
- exercises list must contain at least one exercise

**Relationships**:
- Belongs to one WorkoutPlan
- Contains multiple Exercise entities

### Exercise
Represents an individual exercise within a muscle group (e.g., "High Row", "Seated row").

**Fields**:
- `name`: String (exercise name)
- `order`: int (position within muscle group)
- `muscleGroup`: String (parent muscle group name)

**Validation Rules**:
- name must be non-empty string
- order must be positive integer
- muscleGroup must reference valid parent

**Relationships**:
- Belongs to one MuscleGroup
- Can have multiple ExerciseSet instances in workout sessions

### WorkoutSession
Represents a completed or in-progress workout session instance.

**Fields**:
- `id`: String (UUID)
- `workoutPlanId`: String (references WorkoutPlan)
- `startTime`: DateTime
- `endTime`: DateTime? (null if in progress)
- `completedExercises`: List<ExerciseSet>
- `status`: SessionStatus (inProgress, completed, abandoned)

**Validation Rules**:
- workoutPlanId must reference existing WorkoutPlan
- startTime cannot be in the future
- endTime must be after startTime (if set)
- completedExercises can be empty (for new sessions)

**State Transitions**:
- `inProgress` → `completed` (when user ends workout)
- `inProgress` → `abandoned` (if session times out or explicitly abandoned)
- `completed`/`abandoned` states are final

**Relationships**:
- References one WorkoutPlan
- Contains multiple ExerciseSet entities

### ExerciseSet
Represents completion data for a specific exercise within a workout session, including sets, reps, and weights.

**Fields**:
- `exerciseName`: String (references Exercise.name)
- `sets`: List<SetData>
- `completedAt`: DateTime
- `notes`: String? (optional user notes)

**Validation Rules**:
- exerciseName must reference valid exercise
- sets list can be empty (for exercises marked as done without detailed tracking)
- completedAt cannot be in the future

**Relationships**:
- Belongs to one WorkoutSession
- References one Exercise (by name)

### SetData
Represents individual set data (reps, weight) for an exercise.

**Fields**:
- `reps`: int (number of repetitions)
- `weight`: double? (weight used, optional for bodyweight exercises)
- `restTime`: Duration? (rest time after this set)

**Validation Rules**:
- reps must be positive integer
- weight must be non-negative if specified
- restTime must be positive duration if specified

### AppSettings
Represents user configuration and preferences.

**Fields**:
- `workoutStartTime`: TimeOfDay (configurable daily workout time)
- `defaultRestTime`: Duration (default rest between sets)
- `weekStartDay`: Weekday (for workout cycle alignment)
- `reminderEnabled`: bool (workout reminder notifications)
- `themeMode`: ThemeMode (light/dark/system)

**Validation Rules**:
- workoutStartTime must be valid TimeOfDay (00:00-23:59)
- defaultRestTime must be positive (15 seconds - 10 minutes range)
- weekStartDay must be valid Weekday enum value

**Default Values**:
- workoutStartTime: 18:00 (6 PM)
- defaultRestTime: 90 seconds
- weekStartDay: Weekday.sunday
- reminderEnabled: true
- themeMode: ThemeMode.system

## Data Relationships

```
WorkoutPlan (1) ──→ (many) MuscleGroup ──→ (many) Exercise
     ↑
     │ (references)
     │
WorkoutSession (1) ──→ (many) ExerciseSet ──→ (references) Exercise
```

## Data Flow Patterns

### Workout Plan Loading
1. Parse workouts.md file on app startup
2. Create WorkoutPlan entities with nested MuscleGroup and Exercise structures
3. Cache parsed data as JSON for subsequent app launches
4. Validate cache against workouts.md timestamp to detect changes

### Active Workout Session
1. Create WorkoutSession with inProgress status
2. User marks exercises complete → create ExerciseSet entities
3. User enters sets/reps/weights → populate SetData within ExerciseSet
4. Session timing tracked via startTime and real-time duration calculation
5. End workout → set endTime and change status to completed

### Workout History
1. Query completed WorkoutSession entities ordered by startTime
2. Aggregate data for statistics (frequency, completion rates, personal records)
3. Support filtering by date range, workout type, or muscle groups

## Storage Implementation

### File Structure
```json
// workout_history.json
{
  "sessions": [
    {
      "id": "uuid-string",
      "workoutPlanId": "day_1", 
      "startTime": "2025-10-20T18:00:00.000Z",
      "endTime": "2025-10-20T19:15:00.000Z",
      "status": "completed",
      "completedExercises": [
        {
          "exerciseName": "High Row",
          "sets": [
            {"reps": 10, "weight": 50.0, "restTime": "PT90S"},
            {"reps": 8, "weight": 55.0, "restTime": "PT90S"}
          ],
          "completedAt": "2025-10-20T18:15:00.000Z",
          "notes": "Felt strong today"
        }
      ]
    }
  ]
}
```

### Cached Workout Plans
```json
// workout_cache.json
{
  "lastUpdated": "2025-10-20T12:00:00.000Z",
  "sourceFileHash": "sha256-hash",
  "plans": {
    "day_1": {
      "id": "day_1",
      "name": "Back and Biceps", 
      "dayNumber": 1,
      "muscleGroups": [
        {
          "name": "Upper Back",
          "exercises": [
            {"name": "High Row", "order": 1},
            {"name": "Seated row", "order": 2}
          ]
        }
      ]
    }
  }
}
```

This data model supports all feature requirements while maintaining clean relationships, validation rules, and efficient storage patterns for local-first operation.
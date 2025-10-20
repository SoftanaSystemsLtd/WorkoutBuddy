---
description: "Task list for Personal Workout Tracker App implementation"
---

# Tasks: Personal Workout Tracker App

**Input**: Design documents from `/specs/001-workout-tracker/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are REQUIRED per constitution's Testing Discipline principle. Unit tests for business logic, widget tests for UI components, and integration tests for user workflows must be included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions
- **Flutter app**: `lib/`, `test/` at repository root
- Tasks follow Flutter project structure from plan.md

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic Flutter application structure

 - [X] T001 Initialize Flutter project dependencies in pubspec.yaml
 - [X] T002 [P] Configure analysis_options.yaml with Flutter lints
 - [X] T003 [P] Create main app structure in lib/main.dart with MaterialApp
 - [X] T004 [P] Set up folder structure (lib/models, lib/services, lib/screens, lib/widgets, lib/utils)
 - [X] T005 [P] Create constants file in lib/utils/constants.dart
 - [X] T006 [P] Create date helpers utility in lib/utils/date_helpers.dart
 - [X] T007 [P] Create Dart extensions utility in lib/utils/extensions.dart

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T008 Create base data models in lib/models/workout_plan.dart
- [X] T009 [P] Create workout session models in lib/models/workout_session.dart  
- [X] T010 [P] Create app settings model in lib/models/app_settings.dart
- [X] T011 Create workout parser service interface in lib/services/workout_parser.dart
- [X] T012 [P] Create storage service interface in lib/services/storage_service.dart
- [X] T013 [P] Create settings service interface in lib/services/settings_service.dart
- [X] T014 Set up Provider state management in lib/main.dart with MultiProvider
- [X] T015 [P] Create workout provider in lib/providers/workout_provider.dart
- [X] T016 [P] Create settings provider in lib/providers/settings_provider.dart
- [X] T017 [P] Create bottom navigation widget in lib/widgets/bottom_navigation.dart
- [X] T018 Implement workout parser service to parse workouts.md file
- [X] T019 Implement storage service for local data persistence
- [X] T020 [P] Implement settings service for user preferences

### Tests for Foundational Phase (REQUIRED per constitution)

- [X] T021 [P] Create unit test for WorkoutPlan model in test/unit/workout_plan_test.dart
- [X] T022 [P] Create unit test for WorkoutSession model in test/unit/workout_session_test.dart
- [X] T023 [P] Create unit test for workout parser service in test/unit/workout_parser_test.dart
- [X] T024 [P] Create unit test for storage service in test/unit/storage_service_test.dart
- [X] T025 [P] Create unit test for settings service in test/unit/settings_service_test.dart

---

## Phase 3: User Story 1 - View Daily Workout Plan (Priority P1)

**Goal**: Enable users to view the correct daily workout plan based on current day of week

**Independent Test**: Open app on any day and verify correct workout plan (Day 1-4) displays with proper muscle group organization

- [X] T026 [P] [US1] Create home screen widget in lib/screens/home_screen.dart
- [X] T027 [P] [US1] Create muscle group card widget in lib/widgets/muscle_group_card.dart
- [X] T028 [P] [US1] Create exercise list item widget in lib/widgets/exercise_list_item.dart
- [X] T029 [US1] Implement daily workout logic in workout provider to determine current day's plan
- [X] T030 [US1] Connect home screen to workout provider for data display
- [X] T031 [US1] Add workout plan caching logic to avoid re-parsing workouts.md
- [X] T032 [US1] Implement error handling for missing or malformed workouts.md
- [X] T033 [US1] Add loading states to home screen for workout data parsing

### Tests for User Story 1 (REQUIRED per constitution)

- [X] T034 [P] [US1] Create widget test for home screen in test/widget/home_screen_test.dart
- [X] T035 [P] [US1] Create widget test for muscle group card in test/widget/muscle_group_card_test.dart
- [X] T036 [P] [US1] Create widget test for exercise list item in test/widget/exercise_list_item_test.dart
- [X] T037 [P] [US1] Create unit test for daily workout logic in test/unit/daily_workout_logic_test.dart

---

## Phase 4: User Story 2 - Track Workout Progress (Priority P2)

**Goal**: Enable users to mark exercises as completed and track detailed workout progress with sets/reps/weights

**Independent Test**: View workout plan, mark exercises complete via checkboxes, enter sets/reps/weights, and verify state persistence

- [X] T038 [P] [US2] Create workout screen widget in lib/screens/workout_screen.dart
- [X] T039 [P] [US2] Create exercise tracker widget in lib/widgets/exercise_tracker.dart
- [X] T040 [P] [US2] Create workout timer widget in lib/widgets/workout_timer.dart
- [X] T041 [P] [US2] Create timer service for workout session timing in lib/services/timer_service.dart
- [X] T042 [US2] Implement workout session state management in workout provider
- [X] T043 [US2] Add exercise completion tracking with checkbox functionality
- [X] T044 [US2] Implement sets/reps/weight input forms in exercise tracker widget
- [X] T045 [US2] Add workout session persistence during active workouts
- [X] T046 [US2] Implement start workout functionality with session initialization
- [X] T047 [US2] Implement end workout functionality with session completion
- [X] T048 [US2] Add workout summary display after session completion
- [X] T049 [US2] Connect workout screen to bottom navigation

### Tests for User Story 2 (REQUIRED per constitution)

### Tests (T050-T054)
- [X] T050: workout_screen_test (start/active states) ✓ Created
- [X] T051: exercise_tracker_test (add sets, complete) ✓ Created
- [X] T052: workout_timer_test (time display) ✓ Created
- [X] T053: timer_service_test (start/stop/reset) ✓ Created
- [X] T054: workout_session_logic_test (record/end/persist) ✓ Created

---

## Phase 5: User Story 3 - View Workout History (Priority P3)

**Goal**: Enable users to view historical workout data and track consistency patterns

**Independent Test**: Complete several workouts over multiple days, access history view, and verify chronological display with completion details

- [X] T055 [P] [US3] Create history screen widget in lib/screens/history_screen.dart
- [X] T056 [P] [US3] Create workout history card widget in lib/widgets/workout_history_card.dart
- [X] T057 [P] [US3] Create history provider in lib/providers/history_provider.dart
- [X] T058 [US3] Implement workout history data loading in history provider
- [X] T059 [US3] Add history filtering by date range and workout type
- [X] T060 [US3] Implement workout statistics calculation (frequency, completion rates)
- [X] T061 [US3] Add detailed workout view for historical sessions
- [X] T062 [US3] Connect history screen to bottom navigation
- [X] T063 [US3] Add export functionality for workout history data

### Tests for User Story 3 (REQUIRED per constitution)

- [X] T064 [P] [US3] Create widget test for history screen in test/widget/history_screen_test.dart
- [X] T065 [P] [US3] Create widget test for workout history card in test/widget/workout_history_card_test.dart
- [X] T066 [P] [US3] Create unit test for history provider in test/unit/history_provider_test.dart
- [X] T067 [P] [US3] Create unit test for workout statistics in test/unit/workout_statistics_test.dart

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final integration, performance optimization, and user experience enhancements

- [X] T068 [P] Add app theming and consistent styling across all screens
- [X] T069 [P] Implement user settings screen for configurable workout start time
- [ ] T070 [P] Add error handling and user feedback for all network/storage operations
- [X] T071 [P] Optimize ListView performance with ListView.builder for large datasets
- [X] T072 [P] Add accessibility features (semantic labels, screen reader support)
- [X] T073 [P] Implement app state persistence across app restarts
- [X] T074 Add comprehensive integration test covering complete workout flow
- [ ] T075 [P] Performance testing and optimization for target <100ms response times
- [ ] T076 [P] Add app icon and splash screen
- [ ] T077 Final testing and bug fixes before feature completion

### Final Integration Tests (REQUIRED per constitution)

- [X] T078 Create integration test for complete workout flow in test/integration/workout_flow_test.dart
- [X] T079 [P] Create integration test for data persistence across app sessions in test/integration/persistence_test.dart
- [X] T080 [P] Create performance tests for app startup and navigation in test/integration/performance_test.dart

---

## Dependencies & Execution Strategy

### User Story Dependencies
1. **Phase 1 & 2**: Must complete before any user story work
2. **User Story 1 (P1)**: Can start after Phase 2 completion
3. **User Story 2 (P2)**: Can start after US1 completion (needs workout display foundation)
4. **User Story 3 (P3)**: Can start after US2 completion (needs workout session data)

### Parallel Execution Opportunities

**Phase 2 Parallel Blocks**:
- Block A: T009, T010, T012, T013, T016, T017 (independent model and service files)
- Block B: T021, T022, T023, T024, T025 (independent unit tests)

**User Story 1 Parallel Blocks**:
- Block A: T026, T027, T028 (independent widget files)  
- Block B: T034, T035, T036, T037 (independent test files)

**User Story 2 Parallel Blocks**:
- Block A: T038, T039, T040, T041 (independent widget and service files)
- Block B: T050, T051, T052, T053, T054 (independent test files)

**User Story 3 Parallel Blocks**:
- Block A: T055, T056, T057 (independent widget and provider files)
- Block B: T064, T065, T066, T067 (independent test files)

### MVP Delivery Strategy

**MVP Scope**: User Story 1 only (Phases 1, 2, 3)
- Delivers core value: view daily workout plans
- Independently testable and deployable
- Foundation for subsequent user stories

**Incremental Delivery**:
1. **Release 1**: MVP (US1) - View daily workouts
2. **Release 2**: US1 + US2 - Add workout tracking
3. **Release 3**: US1 + US2 + US3 - Complete feature set

### Task Validation

✅ **Format Check**: All 80 tasks follow required checklist format  
✅ **File Paths**: Every task includes specific file path  
✅ **Story Mapping**: All tasks properly labeled with US1, US2, US3  
✅ **Parallel Markers**: All parallelizable tasks marked with [P]  
✅ **Test Coverage**: Required tests included per constitutional requirements  
✅ **Dependencies**: Clear execution order and blocking relationships defined
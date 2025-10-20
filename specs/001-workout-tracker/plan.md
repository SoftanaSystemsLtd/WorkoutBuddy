# Implementation Plan: Personal Workout Tracker App

**Branch**: `001-workout-tracker` | **Date**: 2025-10-20 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-workout-tracker/spec.md`

**Note**: This plan incorporates enhanced requirements: home page, configurable workout start time, detailed workout tracking with sets/reps/weights, timed sessions, workout summary, and bottom tab navigation.

## Summary

Build a Flutter mobile app for personal gym workout tracking with two main screens: a home dashboard and an active workout tracker. The app will parse existing workout data from workouts.md, display daily workout plans on a configurable schedule, enable detailed exercise tracking (sets, reps, weights, timing), and maintain comprehensive workout history. Core user journey: view today's workout → start timed session → track detailed exercise completion → view workout summary → access historical data.

## Technical Context

**Language/Version**: Dart 3.2+ / Flutter 3.16+  
**Primary Dependencies**: Flutter SDK, Provider/Bloc for state management, shared_preferences for local storage, intl for date formatting  
**Storage**: Local device storage (shared_preferences for settings, local JSON files for workout history)  
**Testing**: Flutter test framework (flutter_test), widget tests, integration tests  
**Target Platform**: Android 6.0+ (API 23+), iOS 12.0+ - mobile-first design  
**Project Type**: Mobile Flutter application with bottom navigation architecture  
**Performance Goals**: <100ms UI response time, smooth 60fps animations, <2s app startup time  
**Constraints**: Offline-first operation, <50MB app size, battery-efficient for gym sessions  
**Scale/Scope**: Personal use app, 4 workout types, ~40 exercises, unlimited history storage

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**✅ I. Widget-Centric Architecture**
- Home page, workout tracker, and history screens will be separate, reusable widgets
- Exercise list items, workout cards, and progress indicators as composable widgets
- Clear separation: UI widgets, business logic services, data models

**✅ II. State Management Clarity (NON-NEGOTIABLE)**
- Provider pattern for app-level state (current workout, settings, history)
- Local state for UI interactions (form inputs, animations, timers)
- Predictable state flow: user action → state update → UI rebuild

**✅ III. Performance-First Design**
- ListView.builder for exercise lists and workout history
- Efficient workout parsing and caching from workouts.md
- Timer optimization for workout sessions without UI blocking

**✅ IV. Testing Discipline**
- Widget tests for home page, workout tracker, navigation components
- Unit tests for workout parsing, timer logic, data persistence
- Integration tests for complete workout flow (start → track → finish)
- Target: >80% test coverage for core business logic

**✅ V. User Experience Excellence**
- Loading states for workout data parsing and history loading
- Clear feedback for exercise completion, timer updates, data saving
- Offline-first design with local storage for all workout data
- Accessible widgets with semantic labels and proper contrast

**Platform Compliance**: Flutter 3.16+ supports iOS 12.0+ and Android API 23+ requirements
**Performance Goals**: <100ms response aligns with mobile UX standards
**Testing Strategy**: Widget, unit, and integration tests meet testing discipline requirements

## Project Structure

### Documentation (this feature)

```
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```
lib/
├── main.dart                    # App entry point with MaterialApp setup
├── models/                      # Data models and entities
│   ├── workout_plan.dart       # WorkoutPlan, Exercise, MuscleGroup models
│   ├── workout_session.dart    # WorkoutSession, ExerciseSet models
│   └── app_settings.dart       # User settings and preferences
├── services/                    # Business logic and data services  
│   ├── workout_parser.dart     # Parse workouts.md file
│   ├── storage_service.dart    # Local storage operations
│   ├── timer_service.dart      # Workout session timing
│   └── settings_service.dart   # App configuration management
├── screens/                     # Main application screens
│   ├── home_screen.dart        # Dashboard with today's workout preview
│   ├── workout_screen.dart     # Active workout tracking screen
│   └── history_screen.dart     # Workout history and statistics
├── widgets/                     # Reusable UI components
│   ├── exercise_list_item.dart # Individual exercise display widget
│   ├── muscle_group_card.dart  # Muscle group section widget
│   ├── workout_timer.dart      # Timer display and controls
│   ├── exercise_tracker.dart   # Sets/reps/weight input widget
│   └── bottom_navigation.dart  # App navigation component
└── utils/                       # Helper utilities and constants
    ├── constants.dart          # App-wide constants and themes
    ├── date_helpers.dart       # Date calculation utilities
    └── extensions.dart         # Dart extensions

test/
├── widget/                      # Widget tests
│   ├── home_screen_test.dart
│   ├── workout_screen_test.dart
│   └── exercise_tracker_test.dart
├── unit/                        # Unit tests
│   ├── workout_parser_test.dart
│   ├── timer_service_test.dart
│   └── storage_service_test.dart
└── integration/                 # Integration tests
    └── workout_flow_test.dart   # Full workout completion flow
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
```

**Structure Decision**: Flutter mobile application with clear separation of concerns:
- `lib/` contains all Dart source code organized by feature and responsibility
- `models/` for data structures, `services/` for business logic, `screens/` for main UI
- `widgets/` for reusable components following Flutter's widget-centric architecture  
- `test/` mirrors `lib/` structure with comprehensive test coverage
- Follows Flutter conventions and constitutional requirements for maintainability

## Phase 0: Research & Technical Decisions

**Status**: ✅ COMPLETE

All technical context items are resolved - no NEEDS CLARIFICATION markers remain:
- **Language/Framework**: Flutter 3.16+ with Dart 3.2+ (established Flutter project)
- **State Management**: Provider pattern (aligns with constitution state management clarity)
- **Storage Strategy**: Local-first with shared_preferences and JSON files (offline-capable)
- **Testing Approach**: Flutter test framework with widget/unit/integration tests (>80% coverage target)
- **Navigation**: Bottom tab navigation (meets 2-screen requirement with extensibility)

## Phase 1: Design Artifacts

**Status**: ✅ COMPLETE

### Data Model
Core entities designed with relationships and validation rules:
- WorkoutPlan, MuscleGroup, Exercise hierarchy
- WorkoutSession with ExerciseSet tracking (sets, reps, weights, timing)
- AppSettings for user configuration
- Clear data flow patterns and storage implementation

### API Contracts  
Internal service interfaces for workout parsing, storage operations, and timer management:
- IWorkoutParserService: Parse workouts.md with caching strategy
- IStorageService: Local persistence for sessions, settings, and cache
- Error handling contracts and performance requirements
- Integration points with Provider state management

### Development Guide
Quickstart documentation for Flutter development setup and project onboarding:
- Prerequisites and setup steps (Flutter 3.16+, Dart 3.2+)
- Project structure and development workflow
- Testing strategy and performance guidelines
- Configuration details and common development tasks

### Agent Context Update
✅ Updated GitHub Copilot instructions with current technology stack:
- Dart 3.2+ / Flutter 3.16+ with Provider state management
- Local storage strategy (shared_preferences + JSON files)  
- Mobile-first architecture with bottom navigation

## Post-Design Constitution Check

**Status**: ✅ ALL PRINCIPLES MAINTAINED

**I. Widget-Centric Architecture**: ✅ Confirmed
- Screen/widget separation clearly defined in project structure
- Reusable components planned (ExerciseListItem, WorkoutTimer, etc.)
- Service layer abstraction maintains clean separation

**II. State Management Clarity**: ✅ Confirmed  
- Provider pattern selected with clear state boundaries
- WorkoutProvider, SettingsProvider, HistoryProvider separation
- State mutation patterns documented in contracts

**III. Performance-First Design**: ✅ Confirmed
- ListView.builder specified for efficient rendering
- Caching strategy for workout data parsing
- Performance requirements documented (<100ms response time)

**IV. Testing Discipline**: ✅ Confirmed
- Comprehensive testing strategy: widget + unit + integration
- Test structure mirrors source code organization  
- Service contracts include testing requirements

**V. User Experience Excellence**: ✅ Confirmed
- Bottom navigation for intuitive mobile experience
- Offline-first design with local storage
- Enhanced requirements support detailed workout tracking with timing

## Planning Complete

All design artifacts generated and constitutional requirements validated. Ready for implementation phase via `/speckit.tasks`.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |


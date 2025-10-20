# Quickstart Guide: Personal Workout Tracker App

**Project**: Personal Workout Tracker App  
**Created**: 2025-10-20  
**Target Audience**: Developers setting up the Flutter workout tracker project

## Prerequisites

- **Flutter SDK**: Version 3.16+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart**: Version 3.2+ (included with Flutter)
- **IDE**: VS Code with Flutter extension or Android Studio
- **Platform Tools**: 
  - Android: Android Studio with SDK 23+ (Android 6.0+)
  - iOS: Xcode 12+ (for iOS 12.0+ deployment)

## Quick Setup (5 minutes)

### 1. Clone and Setup
```bash
# Already in project directory
cd /home/nazrul/WorkSpace/Personal/my_gym

# Verify Flutter installation
flutter doctor

# Get dependencies  
flutter pub get

# Verify everything works
flutter analyze
flutter test
```

### 2. Verify Workout Data
Ensure your `workouts.md` file is present and follows the expected format:

```markdown
Day 1: (Back and Biceps)
Upper Back
1. High Row
2. Seated row

Mid Back  
1. T-bar row
2. Barbel or dumbel row
# ... etc
```

### 3. Run the App
```bash
# For Android device/emulator
flutter run

# For iOS device/simulator (macOS only)
flutter run -d ios

# For Chrome (web testing)
flutter run -d chrome
```

## Project Structure Overview

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data structures
├── services/                    # Business logic
├── screens/                     # Main UI screens  
├── widgets/                     # Reusable components
└── utils/                       # Helpers and constants

test/
├── widget/                      # UI component tests
├── unit/                        # Business logic tests  
└── integration/                 # Full feature tests
```

## Development Workflow

### 1. State Management Setup
The app uses Provider pattern for state management:

```dart
// providers will be registered in main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => WorkoutProvider()),
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
    ChangeNotifierProvider(create: (_) => HistoryProvider()),
  ],
  child: MyApp(),
)
```

### 2. Adding New Features

**Step 1: Create Data Model** (if needed)
```dart
// lib/models/new_model.dart
class NewModel {
  final String id;
  final String name;
  
  NewModel({required this.id, required this.name});
}
```

**Step 2: Add Service Interface**
```dart  
// lib/services/new_service.dart
abstract class INewService {
  Future<NewModel> getData();
}

class NewService implements INewService {
  // Implementation
}
```

**Step 3: Create UI Components**
```dart
// lib/widgets/new_widget.dart
class NewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SomeProvider>(
      builder: (context, provider, child) {
        // Widget implementation
      },
    );
  }
}
```

**Step 4: Add Tests**
```dart
// test/unit/new_service_test.dart  
// test/widget/new_widget_test.dart
```

### 3. Testing Strategy

**Run All Tests**:
```bash
flutter test
```

**Run Specific Test Types**:
```bash  
# Widget tests only
flutter test test/widget/

# Unit tests only  
flutter test test/unit/

# With coverage
flutter test --coverage
```

**Integration Tests**:
```bash
flutter drive --target=test_driver/app.dart
```

## Configuration

### App Settings
Default settings are defined in `lib/models/app_settings.dart`:
- Workout start time: 6:00 PM
- Default rest time: 90 seconds  
- Week start: Sunday
- Theme: System default

### Workout Schedule
The app follows this weekly schedule:
- **Sunday**: Day 1 (Back and Biceps)
- **Monday**: Day 2 (Chest and Triceps)  
- **Tuesday**: Day 3 (Shoulder and Abs)
- **Wednesday**: Day 4 (Legs)
- **Thursday**: Day 1 (cycle repeats)

## Common Development Tasks

### Adding a New Screen
1. Create screen file in `lib/screens/`
2. Add navigation route in main app
3. Update bottom navigation if needed
4. Add corresponding tests

### Modifying Workout Data Structure
1. Update models in `lib/models/`
2. Modify parser service logic
3. Update storage service for new format
4. Migrate existing user data if needed
5. Update corresponding tests

### Adding New Exercise Tracking Features
1. Extend `ExerciseSet` or `SetData` models
2. Update workout tracking UI
3. Modify storage format
4. Add validation rules
5. Test with existing workout data

## Performance Guidelines

- **ListView.builder**: Use for any list with >10 items
- **const constructors**: Use wherever possible for static widgets
- **Provider.of(listen: false)**: Use for actions, not in build methods
- **Keys**: Add to widgets in lists that can change order

## Debugging Tips

### Common Issues

**Build Errors**:
```bash
flutter clean
flutter pub get
flutter run
```

**State Not Updating**:
- Check Provider.of() vs Consumer usage
- Verify notifyListeners() is called
- Use Flutter Inspector to check widget tree

**Storage Issues**:
- Check app permissions for file access
- Verify JSON format with online validator  
- Test with small data sets first

### Useful Commands
```bash
# Debug build with verbose logging
flutter run --debug --verbose

# Profile performance  
flutter run --profile

# Analyze code quality
flutter analyze

# Check for outdated dependencies
flutter pub outdated
```

## Next Steps

1. **Run the app** and verify basic navigation works
2. **Test workout parsing** by checking if your workouts.md loads correctly
3. **Implement core features** following the project structure
4. **Add comprehensive tests** for each new component
5. **Review constitution compliance** before each feature completion

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package Guide](https://pub.dev/packages/provider)  
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Project Constitution](../../../.specify/memory/constitution.md)

## Need Help?

- Check the [specification document](spec.md) for feature requirements
- Review [contracts](contracts/) for service interface details  
- Refer to [data model](data-model.md) for entity relationships
- See [implementation plan](plan.md) for architecture decisions
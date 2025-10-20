# my_gym

Personal workout tracking app built with Flutter.

## Features

* 4-day rotating workout plan parsed from Markdown (`assets/workouts/workouts.md`).
* Automatic recommended day selection based on weekday (Sunday maps to Day 1; cycle repeats every 4 days).
* Manual workout day override with persistence.
* Session tracking with exercise set logging and history & stats view.
* Local persistence via SharedPreferences (settings, active session, cached plans, manual selection).

## Manual Workout Day Selection (Override)

You can manually choose any workout day regardless of the current calendar day.

### How it Works

The app normally computes a recommended plan index using a simple 4-day cycle keyed off the weekday.
When you manually choose a plan, an override index is stored and used until you explicitly clear it.

### Persistence

The manual selection is persisted in SharedPreferences using `StorageService.saveManualPlanIndex`.
On app launch or provider initialization, `WorkoutProvider` restores the saved index (if valid) before computing the recommended plan.

### UI Usage

1. Open the Home screen.
2. Tap the calendar icon (in the AppBar) to open the Workout Day Picker.
3. Choose a day to set it as the active override (it will display as "Selected").
4. The plan that would have been picked automatically is still marked as "Recommended" for reference.
5. To go back to automatic rotation, open the picker and tap "Revert to automatic selection".

### Visual Indicators

* Selected plan: Badge labeled "Selected".
* Recommended plan: Badge labeled "Recommended" (shown when different from selected).

### Code References

* Provider logic: `lib/providers/workout_provider.dart`
	* Fields: `_manualPlanIndex`, `manualPlanIndex`, `isManualSelection`.
	* Methods: `selectPlanByIndex`, `selectPlanByDayNumber`, `clearManualPlanSelection`.
	* Persistence helpers: `_persistManualSelection`, `_restoreManualSelection`.
* Storage layer: `lib/services/storage_service_impl.dart` implements `saveManualPlanIndex` / `loadManualPlanIndex`.
* UI component: `lib/widgets/workout_day_picker.dart` (modal bottom sheet; launched from Home screen AppBar).

### Testing

The persistence behavior is covered by `test/unit/workout_provider_manual_selection_test.dart` which verifies:
* Selection persists across provider re-instantiation.
* Clearing selection removes the persisted index.

## Development

Run analyzer & tests:
```bash
flutter analyze
flutter test
```

Build an APK (debug):
```bash
flutter build apk
```

## Roadmap Ideas

* Add UI chip on Home screen indicating manual override is active with a one-tap revert.
* Export/import workout history as JSON (export already scaffolded via `StorageService.exportData`).
* Additional statistics (PR tracking, volume graphs).

## License

Currently unpublished / private; add a license file if planning distribution.

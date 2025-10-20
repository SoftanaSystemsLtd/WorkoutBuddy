import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Settings'),
      actions: [
        IconButton(
          icon: const Icon(Icons.restore),
          onPressed: () => _showResetDialog(context),
          tooltip: 'Reset to defaults',
        ),
      ],
    ),
    body: Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => provider.loadSettings(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final settings = provider.settings;

        return ListView(
          children: [
            _buildSectionHeader(context, 'Workout Preferences'),
            _buildWorkoutStartTimeTile(context, settings, provider),
            _buildRestTimeTile(context, settings, provider),
            _buildWeekStartDayTile(context, settings, provider),

            const Divider(),

            _buildSectionHeader(context, 'Notifications'),
            _buildReminderTile(context, settings, provider),

            const Divider(),

            _buildSectionHeader(context, 'Appearance'),
            _buildThemeModeTile(context, settings, provider),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Settings are automatically saved',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    ),
  );

  Widget _buildSectionHeader(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildWorkoutStartTimeTile(
    BuildContext context,
    AppSettings settings,
    SettingsProvider provider,
  ) => ListTile(
    leading: const Icon(Icons.schedule),
    title: const Text('Preferred Workout Start Time'),
    subtitle: Text(_formatTime(settings.workoutStartTime)),
    onTap: () async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: settings.workoutStartTime,
        helpText: 'Select preferred workout start time',
      );

      if (picked != null && picked != settings.workoutStartTime) {
        await provider.updateSettings(
          settings.copyWith(workoutStartTime: picked),
        );
      }
    },
  );

  Widget _buildRestTimeTile(
    BuildContext context,
    AppSettings settings,
    SettingsProvider provider,
  ) => ListTile(
    leading: const Icon(Icons.timer),
    title: const Text('Default Rest Time'),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${settings.defaultRestTime.inSeconds} seconds'),
        Slider(
          value: settings.defaultRestTime.inSeconds.toDouble(),
          min: 30,
          max: 300,
          divisions: 27,
          label: '${settings.defaultRestTime.inSeconds} seconds',
          onChanged: (value) {
            provider.updateSettings(
              settings.copyWith(
                defaultRestTime: Duration(seconds: value.toInt()),
              ),
            );
          },
        ),
      ],
    ),
  );

  Widget _buildWeekStartDayTile(
    BuildContext context,
    AppSettings settings,
    SettingsProvider provider,
  ) => ListTile(
    leading: const Icon(Icons.calendar_today),
    title: const Text('Week Starts On'),
    subtitle: Text(_weekdayToString(settings.weekStartDay)),
    onTap: () {
      showDialog(
        context: context,
        builder: (context) => _WeekStartDayDialog(
          currentDay: settings.weekStartDay,
          onSelected: (day) {
            provider.updateSettings(settings.copyWith(weekStartDay: day));
          },
        ),
      );
    },
  );

  Widget _buildReminderTile(
    BuildContext context,
    AppSettings settings,
    SettingsProvider provider,
  ) => SwitchListTile(
    secondary: const Icon(Icons.notifications_active),
    title: const Text('Workout Reminders'),
    subtitle: const Text('Get notified about scheduled workouts'),
    value: settings.reminderEnabled,
    onChanged: (value) {
      provider.updateSettings(settings.copyWith(reminderEnabled: value));
    },
  );

  Widget _buildThemeModeTile(
    BuildContext context,
    AppSettings settings,
    SettingsProvider provider,
  ) => ListTile(
    leading: const Icon(Icons.brightness_6),
    title: const Text('Theme'),
    subtitle: Text(_themeModeToString(settings.themeMode)),
    onTap: () {
      showDialog(
        context: context,
        builder: (context) => _ThemeModeDialog(
          currentMode: settings.themeMode,
          onSelected: (mode) {
            provider.updateSettings(settings.copyWith(themeMode: mode));
          },
        ),
      );
    },
  );

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _weekdayToString(Weekday day) =>
      day.name[0].toUpperCase() + day.name.substring(1);

  String _themeModeToString(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
    ThemeMode.system => 'System default',
  };

  void _showResetDialog(BuildContext context) {
    final provider = context.read<SettingsProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await provider.resetToDefaults();
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings reset to defaults')),
                  );
                }
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _WeekStartDayDialog extends StatelessWidget {
  const _WeekStartDayDialog({
    required this.currentDay,
    required this.onSelected,
  });

  final Weekday currentDay;
  final ValueChanged<Weekday> onSelected;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Week Starts On'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: Weekday.values
          .map(
            (day) => ListTile(
              title: Text(day.name[0].toUpperCase() + day.name.substring(1)),
              trailing: day == currentDay
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                onSelected(day);
                Navigator.of(context).pop();
              },
            ),
          )
          .toList(),
    ),
  );
}

class _ThemeModeDialog extends StatelessWidget {
  const _ThemeModeDialog({required this.currentMode, required this.onSelected});

  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onSelected;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Select Theme'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _themeOption(
          context,
          ThemeMode.light,
          'Light',
          'Always use light theme',
        ),
        _themeOption(context, ThemeMode.dark, 'Dark', 'Always use dark theme'),
        _themeOption(
          context,
          ThemeMode.system,
          'System Default',
          'Follow system theme settings',
        ),
      ],
    ),
  );

  Widget _themeOption(
    BuildContext context,
    ThemeMode mode,
    String title,
    String subtitle,
  ) => ListTile(
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: mode == currentMode
        ? const Icon(Icons.check, color: Colors.green)
        : null,
    onTap: () {
      onSelected(mode);
      Navigator.of(context).pop();
    },
  );
}

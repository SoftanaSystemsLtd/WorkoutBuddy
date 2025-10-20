import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/history_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/workout_screen.dart';
import 'services/settings_service_impl.dart';
import 'services/storage_service_impl.dart';
import 'services/timer_service.dart';
import 'services/workout_parser_impl.dart';
import 'utils/app_theme.dart';
import 'widgets/bottom_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final storage = StorageServiceImpl();
  await storage.init();

  final parser = WorkoutParserImpl();
  final settingsService = SettingsServiceImpl(storage);

  runApp(
    MyApp(storage: storage, parser: parser, settingsService: settingsService),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.storage,
    required this.parser,
    required this.settingsService,
    super.key,
  });

  final StorageServiceImpl storage;
  final WorkoutParserImpl parser;
  final SettingsServiceImpl settingsService;

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => WorkoutProvider(parser, storage)..initialize(),
      ),
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(settingsService)..loadSettings(),
      ),
      ChangeNotifierProvider(create: (_) => TimerService()),
      ChangeNotifierProvider(create: (_) => HistoryProvider(storage)),
      // HistoryProvider will be added in later phase
    ],
    child: MaterialApp(
      title: 'My Gym',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const RootScaffold(),
    ),
  );
}

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    WorkoutScreen(),
    HistoryScreen(), // Placeholder until implemented fully
  ];

  void _onTabSelected(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _screens[_currentIndex],
    bottomNavigationBar: BottomNavigation(
      currentIndex: _currentIndex,
      onSelected: _onTabSelected,
    ),
  );
}

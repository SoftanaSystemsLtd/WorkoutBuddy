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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Do NOT perform heavy async work here; allow first frame ASAP so native splash disappears quickly.
  runApp(const AppBootstrap());
}

/// Bootstraps async initialization inside widget tree so splash screen duration is minimized.
class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  Future<_Services> _initServices() async {
    final storage = StorageServiceImpl();
    await storage.init(); // SharedPreferences init
    final parser = WorkoutParserImpl();
    final settingsService = SettingsServiceImpl(storage);
    return _Services(storage, parser, settingsService);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_Services>(
    future: _initServices(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        // Lightweight placeholder while services init (native splash is already gone).
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      }
      final s = snapshot.data!;
      return MyApp(
        storage: s.storage,
        parser: s.parser,
        settingsService: s.settingsService,
      );
    },
  );
}

class _Services {
  _Services(this.storage, this.parser, this.settingsService);
  final StorageServiceImpl storage;
  final WorkoutParserImpl parser;
  final SettingsServiceImpl settingsService;
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
      title: 'MyGym',
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

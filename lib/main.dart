import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sivastopus/app_state.dart';
import 'package:sivastopus/smart_stops_screen.dart';
import 'package:sivastopus/map_screen.dart';
import 'package:sivastopus/settings_screen.dart';
import 'package:sivastopus/dashboard_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sivastopus/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isOnboardingCompleted = prefs.getBool('isOnboardingCompleted') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MyApp(isOnboardingCompleted: isOnboardingCompleted),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isOnboardingCompleted;
  const MyApp({super.key, required this.isOnboardingCompleted});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return MaterialApp(
      title: 'Daha İyi Sivas Akıllı Duraklar',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: appState.accentColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: appState.accentColor,
          foregroundColor: Colors.white,
        ),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: appState.accentColor),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: appState.accentColor,
          foregroundColor: Colors.white,
        ),
      ),
      home: isOnboardingCompleted
          ? const MainScreen()
          : const OnboardingScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onNavigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // List of screens needs to be built here to access _onNavigateToTab
    final List<Widget> screens = [
      DashboardScreen(onNavigateToTab: _onNavigateToTab),
      const SmartStopsScreen(),
      const MapScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigateToTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Ana Ekran'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Duraklar'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Harita'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
      ),
    );
  }
}

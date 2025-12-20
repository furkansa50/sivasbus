import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sivastopus/app_state.dart';
import 'package:sivastopus/smart_stops_screen.dart';
import 'package:sivastopus/map_screen.dart';
import 'package:sivastopus/settings_screen.dart';
import 'package:sivastopus/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(create: (_) => AppState(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return MaterialApp(
      title: 'Sivas Smart Stops',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: appState.accentColor),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: const MainScreen(),
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

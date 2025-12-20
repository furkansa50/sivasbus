import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sivastopus/app_state.dart';
import 'package:sivastopus/main.dart'; // Import MainScreen from main.dart
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sivastopus/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLocationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      setState(() {
        _isLocationPermissionGranted = true;
      });
    }
  }

  Future<void> _requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      setState(() {
        _isLocationPermissionGranted = true;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboardingCompleted', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildPermissionPage(),
                  _buildPersonalizationPage(appState),
                ],
              ),
            ),
            _buildBottomControls(appState),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SvgPicture.asset(
              'assets/app_logo.svg',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => Icon(
                Icons.directions_bus,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 32),
          Text(
            'Hoşgeldiniz',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Daha İyi Sivas Akıllı Duraklar',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Otobüs duraklarını görüntüleyin, tahmini varış sürelerini öğrenin ve yolculuğunuzu planlayın.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, size: 100, color: Colors.orange),
          const SizedBox(height: 32),
          Text(
            'Konum İzni',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Size en yakın durakları gösterebilmemiz için konum iznine ihtiyacımız var.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _isLocationPermissionGranted ? null : _requestPermission,
            icon: Icon(
              _isLocationPermissionGranted ? Icons.check : Icons.my_location,
            ),
            label: Text(
              _isLocationPermissionGranted ? 'İzin Verildi' : 'Konuma İzin Ver',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizationPage(AppState appState) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.palette, size: 100, color: appState.accentColor),
          const SizedBox(height: 32),
          Text(
            'Kişiselleştirme',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          Text(
            'Görünüm Modunu Seçin',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text('Sistem'),
                icon: Icon(Icons.brightness_auto),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text('Aydınlık'),
                icon: Icon(Icons.wb_sunny),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text('Karanlık'),
                icon: Icon(Icons.nightlight_round),
              ),
            ],
            selected: {appState.themeMode},
            onSelectionChanged: (Set<ThemeMode> newSelection) {
              appState.setThemeMode(newSelection.first);
            },
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Uygulama Temasını Seçin',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: appColors.map((colorItem) {
              final Color color = colorItem['color'];
              final String name = colorItem['name'];
              final bool isSelected = appState.accentColor.value == color.value;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      appState.setAccentColor(color);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: color.computeLuminance() > 0.5
                                    ? Colors.black
                                    : Colors.white,
                                width: 3,
                              )
                            : Border.all(color: Colors.grey.shade300, width: 1),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: color.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? appState.accentColor : Colors.grey,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(AppState appState) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
              child: const Text('Geri'),
            )
          else
            const SizedBox(width: 64), // Balance spacing

          Row(
            children: List.generate(3, (index) => _buildDot(index, appState)),
          ),

          if (_currentPage < 2)
            TextButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
              child: const Text('İleri'),
            )
          else
            ElevatedButton(
              onPressed: _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: appState.accentColor,
                foregroundColor: appState.accentColor.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              ),
              child: const Text('Başla'),
            ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, AppState appState) {
    final bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? appState.accentColor : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: appState.accentColor.withOpacity(0.4),
              blurRadius: 4,
              spreadRadius: 1,
            ),
        ],
      ),
    );
  }
}

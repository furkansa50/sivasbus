import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  Color _accentColor = Colors.red;
  int _refreshRate = 60; // Standard 60 seconds

  Color get accentColor => _accentColor;
  int get refreshRate => _refreshRate;

  AppState() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('accentColor');
    if (colorValue != null) {
      _accentColor = Color(colorValue);
    }
    _refreshRate = prefs.getInt('refreshRate') ?? 60;
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColor', color.value);
  }

  Future<void> setRefreshRate(int seconds) async {
    _refreshRate = seconds;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('refreshRate', seconds);
  }
}

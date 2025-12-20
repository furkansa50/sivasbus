import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sivastopus/app_state.dart';

import 'package:sivastopus/constants.dart';
import 'dart:async';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _darkTapCount = 0;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Görünüm'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SegmentedButton<ThemeMode>(
                  segments: [
                    const ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text('Sistem'),
                      icon: Icon(Icons.brightness_auto),
                    ),
                    const ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text('Aydınlık'),
                      icon: Icon(Icons.wb_sunny),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: GestureDetector(
                        onTap: () {
                          if (appState.themeMode == ThemeMode.dark) {
                            setState(() {
                              _darkTapCount++;
                            });
                          } else {
                            appState.setThemeMode(ThemeMode.dark);
                          }
                        },
                        child: const Text('Karanlık'),
                      ),
                      icon: const Icon(Icons.nightlight_round),
                    ),
                  ],
                  selected: {appState.themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    appState.setThemeMode(newSelection.first);
                    // Reset tap count on mode change
                    if (newSelection.first != ThemeMode.dark) {
                      setState(() {
                        _darkTapCount = 0;
                      });
                    }
                  },
                ),
                if ((appState.isAmoledMode || _darkTapCount >= 3) &&
                    appState.themeMode == ThemeMode.dark) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('AMOLED Karanlığı'),
                    subtitle: const Text('Tam siyah tema'),
                    value: appState.isAmoledMode,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.grey,
                    onChanged: (val) => appState.setAmoledMode(val),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Tema Rengi'),
          // Inline color picker - 1x6 grid (simplified from 2x6)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: appColors.length,
              itemBuilder: (context, index) {
                final colorItem = appColors[index];
                final color = colorItem['color'] as Color;
                final name = colorItem['name'] as String;
                final isSelected = appState.accentColor.value == color.value;

                return GestureDetector(
                  onTap: () => appState.setAccentColor(color),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : Border.all(
                                  color: Colors.grey.shade700,
                                  width: 1,
                                ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 32),
          _buildSectionHeader(context, 'Hakkında'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sivas Akıllı Durak'),
            subtitle: const Text('furkansa50 tarafından geliştirildi'),
            onTap: () => _handleAboutTap(context),
          ),
        ],
      ),
    );
  }

  int _aboutTapCount = 0;
  Timer? _aboutTapTimer;

  void _handleAboutTap(BuildContext context) {
    _aboutTapCount++;
    if (_aboutTapTimer != null) {
      _aboutTapTimer!.cancel();
    }
    _aboutTapTimer = Timer(const Duration(milliseconds: 500), () {
      _aboutTapCount = 0;
    });

    if (_aboutTapCount >= 3) {
      _aboutTapCount = 0;
      if (_aboutTapTimer != null) {
        _aboutTapTimer!.cancel();
      }
      showLicensePage(
        context: context,
        applicationName: 'Sivas Akıllı Durak',
        applicationVersion: '1.0.0',
      );
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

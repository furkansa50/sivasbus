import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sivastopus/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<Color> _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Görünüm'),
          ListTile(
            title: const Text('Tema Rengi'),
            subtitle: const Text('Uygulama genelinde kullanılan ana renk'),
            trailing: CircleAvatar(
              backgroundColor: appState.accentColor,
              radius: 12,
            ),
            onTap: () {
              _showColorPicker(context, appState);
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'Veri'),
          ListTile(
            title: const Text('Otomatik Yenileme Sıklığı'),
            subtitle: Text('${appState.refreshRate} saniye'),
            trailing: DropdownButton<int>(
              value: appState.refreshRate,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 30, child: Text('30 sn')),
                DropdownMenuItem(value: 60, child: Text('1 dk')),
                DropdownMenuItem(value: 120, child: Text('2 dk')),
                DropdownMenuItem(value: 300, child: Text('5 dk')),
              ],
              onChanged: (value) {
                if (value != null) {
                  appState.setRefreshRate(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Renk Seçin',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _availableColors.length,
                  itemBuilder: (context, index) {
                    final color = _availableColors[index];
                    return GestureDetector(
                      onTap: () {
                        appState.setAccentColor(color);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: appState.accentColor == color
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

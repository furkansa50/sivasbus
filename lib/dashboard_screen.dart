import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'package:sivastopus/sivas_bus_service.dart';
import 'package:provider/provider.dart';
import 'package:sivastopus/app_state.dart';

import 'package:sivastopus/stop_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const DashboardScreen({super.key, required this.onNavigateToTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  LatLng? _userLocation;
  static const LatLng _centerSivas = LatLng(39.75, 37.015);

  @override
  void initState() {
    super.initState();
    _determinePosition();
    // Load stops if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AppState>().stops.isEmpty) {
        context.read<AppState>().loadStops();
      }
    });
  }

  Future<void> _determinePosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final stops = appState.stops;
    final nearbyStops = _getNearbyStops(stops, 3);
    final allStopsPreview = stops.take(3).toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            // SliverAppBar with logo that expands on pull
            SliverAppBar(
              expandedHeight: 80,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: Color.lerp(
                Theme.of(context).colorScheme.primary,
                Colors.black,
                0.8,
              ), // Much darker
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 16),
                title: const Text(
                  'Sivas Akıllı Duraklar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  color: Color.lerp(
                    Theme.of(context).colorScheme.primary,
                    Colors.black,
                    0.8,
                  ),
                ),
              ),
            ),
            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),

                  // Empty State / Loading Handling
                  if (stops.isEmpty)
                    if (appState.isLoadingStops)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Duraklar yüklenemedi.',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _refreshData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tekrar Dene'),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      )
                  else ...[
                    // Map Preview Section
                    _buildMapPreview(context, stops),

                    const SizedBox(height: 16),

                    // Nearby Stops Section
                    _buildSectionHeader(
                      context,
                      'Yakındaki Duraklar',
                      () => widget.onNavigateToTab(1),
                    ),
                    if (nearbyStops.isNotEmpty)
                      ...nearbyStops.map(
                        (stop) => _buildStopCard(context, stop, true),
                      ),

                    const SizedBox(height: 16),

                    // All Stops Section
                    _buildSectionHeader(
                      context,
                      'Tüm Duraklar',
                      () => widget.onNavigateToTab(1),
                    ),
                    if (allStopsPreview.isNotEmpty)
                      ...allStopsPreview.map(
                        (stop) => _buildStopCard(context, stop, false),
                      ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await context.read<AppState>().loadStops(forceRefresh: true);
  }

  Widget _buildMapPreview(BuildContext context, List<SmartStop> stops) {
    // Get stops with valid coordinates for preview
    final validStops = stops
        .where((s) => s.lat != 0 && s.lng != 0)
        .take(20)
        .toList();

    return GestureDetector(
      onTap: () => widget.onNavigateToTab(2), // Navigate to Map Tab (Tab 2)
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            IgnorePointer(
              child: FlutterMap(
                key: ValueKey('map_${validStops.length}'),
                options: MapOptions(
                  initialCenter: _userLocation ?? _centerSivas,
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: Theme.of(context).brightness == Brightness.dark
                        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.sivastopus',
                  ),
                  MarkerLayer(
                    markers: [
                      // User location marker
                      if (_userLocation != null)
                        Marker(
                          point: _userLocation!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                          ),
                        ),
                      // Stop markers
                      ...validStops.map(
                        (stop) => Marker(
                          point: LatLng(stop.lat, stop.lng),
                          width: 20,
                          height: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]
                                  : Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[600]!
                                    : Colors.white,
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.directions_bus,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.transparent, // Capture taps
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.map,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Haritayı Aç',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(icon: const Icon(Icons.arrow_forward), onPressed: onTap),
        ],
      ),
    );
  }

  Widget _buildStopCard(
    BuildContext context,
    SmartStop stop,
    bool showDistance,
  ) {
    String? distanceText;
    if (showDistance && _userLocation != null && stop.lat != 0) {
      final distMeters = Geolocator.distanceBetween(
        _userLocation!.latitude,
        _userLocation!.longitude,
        stop.lat,
        stop.lng,
      );
      if (distMeters < 1000) {
        distanceText = '${distMeters.toStringAsFixed(0)} m';
      } else {
        distanceText = '${(distMeters / 1000).toStringAsFixed(1)} km';
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF333333)
          : Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.bus_alert,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(stop.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: distanceText != null
            ? Row(
                children: [
                  const Icon(
                    Icons.directions_walk,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(distanceText, style: const TextStyle(fontSize: 12)),
                ],
              )
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StopDetailScreen(stop: stop),
            ),
          );
        },
      ),
    );
  }

  List<SmartStop> _getNearbyStops(List<SmartStop> stops, int count) {
    if (_userLocation == null) return [];

    // Create a copy to sort
    final sortedStops = List<SmartStop>.from(stops);
    sortedStops.sort((a, b) {
      if (a.lat == 0) return 1;
      if (b.lat == 0) return -1;
      final distA = Geolocator.distanceBetween(
        _userLocation!.latitude,
        _userLocation!.longitude,
        a.lat,
        a.lng,
      );
      final distB = Geolocator.distanceBetween(
        _userLocation!.latitude,
        _userLocation!.longitude,
        b.lat,
        b.lng,
      );
      return distA.compareTo(distB);
    });

    return sortedStops.take(count).toList();
  }
}

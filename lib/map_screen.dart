import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sivastopus/sivas_bus_service.dart';
import 'package:sivastopus/stop_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final SivasBusService _service = SivasBusService();
  late Future<List<SmartStop>> _stopsFuture;
  LatLng? _userLocation;
  final MapController _mapController = MapController();
  static const LatLng _centerSivas = LatLng(
    39.75,
    37.015,
  ); // Approximate Sivas Center

  @override
  void initState() {
    super.initState();
    _stopsFuture = _service.fetchSmartStops();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });

    // Animate map to user location if found
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<SmartStop>>(
        future: _stopsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final stops = snapshot.data ?? [];

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation ?? _centerSivas,
              initialZoom: 14.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
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
                  // User Location Marker
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 60,
                      height: 60,
                      child: Icon(
                        Icons.my_location,
                        color: Theme.of(context).colorScheme.tertiary,
                        size: 30,
                      ),
                    ),
                  // Stop Markers
                  ...stops.where((s) => s.lat != 0 && s.lng != 0).map((stop) {
                    return Marker(
                      point: LatLng(stop.lat, stop.lng),
                      width: 24,
                      height: 24,
                      child: GestureDetector(
                        onTap: () {
                          _showStopDetails(context, stop);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[700]
                                : Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]!
                                  : Colors.white,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.directions_bus,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              // RichAttributionWidget(
              //   attributions: [
              //     TextSourceAttribution(
              //       'OpenStreetMap contributors',
              //       onTap: () {},
              //     ),
              //   ],
              // ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'map_fab',
        onPressed: () {
          if (_userLocation != null) {
            _mapController.move(_userLocation!, 15);
          } else {
            _determinePosition();
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  void _showStopDetails(BuildContext context, SmartStop stop) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stop.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.map),
                      label: const Text('Haritada Konum'),
                      onPressed: () {
                        // Already on map, maybe center?
                        Navigator.pop(context);
                        _mapController.move(LatLng(stop.lat, stop.lng), 16);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.schedule),
                      label: const Text('Saatler'),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StopDetailScreen(stop: stop),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

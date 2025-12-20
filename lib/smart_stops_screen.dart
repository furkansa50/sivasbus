import 'package:flutter/material.dart';
import 'package:sivastopus/sivas_bus_service.dart';
import 'package:sivastopus/stop_detail_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sivastopus/app_state.dart';

class SmartStopsScreen extends StatefulWidget {
  const SmartStopsScreen({super.key});

  @override
  State<SmartStopsScreen> createState() => _SmartStopsScreenState();
}

class _SmartStopsScreenState extends State<SmartStopsScreen> {
  // final SivasBusService _service = SivasBusService(); // Removed
  // late Future<List<SmartStop>> _stopsFuture; // Removed
  List<SmartStop>? _allStops;
  List<SmartStop>? _filteredStops;
  final TextEditingController _searchController = TextEditingController();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterStops);
    _checkLocation();

    // Load stops if we don't have them yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AppState>().stops.isEmpty) {
        context.read<AppState>().loadStops();
      }
    });
  }

  Future<void> _checkLocation() async {
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

    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          if (_allStops != null) {
            _sortStopsByDistance();
            _filterStops();
          }
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _sortStopsByDistance() {
    if (_allStops != null && _currentPosition != null) {
      _allStops!.sort((a, b) {
        // If lat/lng is 0, put at end
        if (a.lat == 0) return 1;
        if (b.lat == 0) return -1;

        final distA = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          a.lat,
          a.lng,
        );
        final distB = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          b.lat,
          b.lng,
        );
        return distA.compareTo(distB);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStops() {
    final query = _searchController.text.toLowerCase();
    if (_allStops != null) {
      setState(() {
        _filteredStops = _allStops!.where((stop) {
          return stop.name.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allStops = appState.stops;

    // Initialize sorted list if needed or update if list changed
    if (_allStops != allStops) {
      _allStops = allStops;
      if (_currentPosition != null) {
        _sortStopsByDistance();
      }
      _filterStops(); // Re-apply filter
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sivas Akıllı Duraklar'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Durak ara...',
              leading: const Icon(Icons.search, color: Colors.grey),
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(const Color(0xFF333333)),
              shape: WidgetStateProperty.all(const StadiumBorder()),
              side: WidgetStateProperty.all(BorderSide.none),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              textStyle: WidgetStateProperty.all(
                const TextStyle(color: Colors.white),
              ),
              hintStyle: WidgetStateProperty.all(
                const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (appState.isLoadingStops && allStops.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (allStops.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Durak bulunamadı.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      context.read<AppState>().loadStops(forceRefresh: true);
                    },
                    child: const Text('Yenile'),
                  ),
                ],
              ),
            );
          }

          // Use the locally filtered list if search is active, otherwise all stops (sorted)
          // Wait, logic above updates _allStops reference.
          // _filterStops updates _filteredStops.
          // If _filteredStops is null, it means no filter applied yet, show all.

          final stopsToShow = _filteredStops ?? _allStops ?? [];

          if (stopsToShow.isEmpty) {
            return const Center(child: Text('Eşleşen durak bulunamadı.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<AppState>().loadStops();
            },
            child: ListView.builder(
              itemCount: stopsToShow.length,
              itemBuilder: (context, index) {
                final stop = stopsToShow[index];

                String? distanceText;
                if (_currentPosition != null && stop.lat != 0) {
                  final distMeters = Geolocator.distanceBetween(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                    stop.lat,
                    stop.lng,
                  );
                  if (distMeters < 1000) {
                    distanceText = '${distMeters.toStringAsFixed(0)} m';
                  } else {
                    distanceText =
                        '${(distMeters / 1000).toStringAsFixed(1)} km';
                  }
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  elevation: 0,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF333333)
                      : Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.bus_alert,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      stop.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: distanceText != null
                        ? Row(
                            children: [
                              const Icon(
                                Icons.directions_walk,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                distanceText,
                                style: const TextStyle(fontSize: 12),
                              ),
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
              },
            ),
          );
        },
      ),
    );
  }
}

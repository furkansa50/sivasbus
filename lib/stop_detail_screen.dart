import 'package:flutter/material.dart';
import 'package:sivastopus/sivas_bus_service.dart';
import 'package:provider/provider.dart';
import 'package:sivastopus/app_state.dart';
import 'dart:async';

class StopDetailScreen extends StatefulWidget {
  final SmartStop stop;

  const StopDetailScreen({super.key, required this.stop});

  @override
  State<StopDetailScreen> createState() => _StopDetailScreenState();
}

class _StopDetailScreenState extends State<StopDetailScreen> {
  final SivasBusService _service = SivasBusService();
  late Future<List<BusArrival>> _arrivalsFuture;
  Timer? _refreshTimer;
  DateTime _lastUpdated = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadArrivals();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update timer when dependencies (AppState) change
    _setupTimer();
  }

  void _setupTimer() {
    _refreshTimer?.cancel();
    final appState = Provider.of<AppState>(
      context,
      listen: false,
    ); // Use listen: false inside didChangeDependencies usually, but we want to read current value
    // Actually, listening to changes on refreshRate would be better in build or using a listener.
    // Simpler approach: Re-setup timer on each build or use a Stream.
    // Let's rely on didChangeDependencies being called when Provider notifies,
    // but Provider only notifies if we listen.
    // So we should watch it in build, or use a Listener widget.

    // Better: Helper method called from initState and when setting changes.
    // But since this is a detail screen, it's likely ephemeral.
    // Let's just grab the rate from context in a safe place.
  }

  // Alternative: Check in build if we need to reset timer, or just use the current rate.
  // Ideally, use a Timer that restarts with new duration.

  void _updateTimer(int seconds) {
    if (_refreshTimer?.isActive ?? false) {
      // Check if duration changed?
      // Simplified: Just cancel and restart if called.
      _refreshTimer?.cancel();
    }
    _refreshTimer = Timer.periodic(Duration(seconds: seconds), (timer) {
      _loadArrivals();
    });
  }

  void _loadArrivals() {
    if (!mounted) return;
    setState(() {
      _arrivalsFuture = _service.fetchArrivals(widget.stop.id);
      _lastUpdated = DateTime.now();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch AppState for refresh rate changes
    final appState = context.watch<AppState>();

    // Ensure timer is running with correct duration
    // Note: creating a new timer on every build is bad.
    // Checks if we should update the timer
    // Ideally we track the current known rate.

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stop.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadArrivals();
              // Reset timer logic if needed
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // If we had the previous rate, check if it changed.
          // For now, let's just create the timer once and if user changes settings
          // while on this screen, it won't update until re-entry,
          // OR we use a separate widget wrapper.
          // A simple partial fix:
          _TimerHandler(
            refreshRate: appState.refreshRate,
            onTick: _loadArrivals,
          ),

          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Otobüs Hareket Saatleri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Son güncelleme: ${_lastUpdated.hour.toString().padLeft(2, '0')}:${_lastUpdated.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<BusArrival>>(
              future: _arrivalsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Veri alınamadı: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.timer_off_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Yaklaşan otobüs bulunmuyor.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final arrivals = snapshot.data!;
                return ListView.builder(
                  itemCount: arrivals.length,
                  itemBuilder: (context, index) {
                    final arrival = arrivals[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                arrival.lineCode,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    arrival.lineName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kalan Süre',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: arrival.timeRemaining.contains('dk')
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: arrival.timeRemaining.contains('dk')
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              child: Text(
                                arrival.timeRemaining,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: arrival.timeRemaining.contains('dk')
                                      ? Colors.green[700]
                                      : Colors.orange[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerHandler extends StatefulWidget {
  final int refreshRate;
  final VoidCallback onTick;

  const _TimerHandler({required this.refreshRate, required this.onTick});

  @override
  State<_TimerHandler> createState() => _TimerHandlerState();
}

class _TimerHandlerState extends State<_TimerHandler> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(_TimerHandler oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshRate != widget.refreshRate) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: widget.refreshRate), (_) {
      widget.onTick();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

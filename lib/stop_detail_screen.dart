import 'package:flutter/material.dart';
import 'package:sivastopus/sivas_bus_service.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stop.name),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadArrivals),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadArrivals();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: Column(
          children: [
            // Auto refresh every 60 seconds
            _TimerHandler(refreshRate: 60, onTick: _loadArrivals),

            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF333333)
                            : null,
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
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white70
                                            : Colors.black87,
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
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.orange.withValues(alpha: 0.1),
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

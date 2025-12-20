import 'package:sivastopus/sivas_bus_service.dart';

void main() async {
  final service = SivasBusService();

  print('Fetching Smart Stops from Map data...');
  try {
    final stops = await service.fetchSmartStops();
    print('Found ${stops.length} stops.');

    // Check specific stop 546
    final stop546 = stops.where((s) => s.id == '546').firstOrNull;
    if (stop546 != null) {
      print('Successfully found Stop 546: $stop546');
    } else {
      print('WARNING: Stop 546 NOT found in the list!');
    }

    if (stops.isNotEmpty) {
      print('First 3 stops:');
      for (var i = 0; i < 3 && i < stops.length; i++) {
        print(stops[i]);
      }

      String targetId = stop546?.id ?? stops.first.id;
      print('\nFetching arrivals for stop ID: $targetId...');

      final arrivals = await service.fetchArrivals(targetId);
      print('Found ${arrivals.length} arrivals.');
      for (var arrival in arrivals) {
        print(arrival);
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}

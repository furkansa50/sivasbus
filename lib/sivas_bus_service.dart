import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class SmartStop {
  final String id;
  final String name;
  final double lat;
  final double lng;

  SmartStop({required this.id, required this.name, this.lat = 0, this.lng = 0});

  @override
  String toString() => 'SmartStop(id: $id, name: $name)';
}

class BusArrival {
  final String lineCode;
  final String lineName;
  final String timeRemaining;

  BusArrival({
    required this.lineCode,
    required this.lineName,
    required this.timeRemaining,
  });

  @override
  String toString() => '$lineCode - $lineName: $timeRemaining';
}

class SivasBusService {
  static const String _baseUrl = 'https://ulasim.sivas.bel.tr';
  static const String _listUrl = '$_baseUrl/Akilli-Duraklar-Liste';

  Future<List<SmartStop>> fetchSmartStops() async {
    try {
      final response = await http.get(Uri.parse(_listUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load stops: ${response.statusCode}');
      }

      final document = parser.parse(response.body);
      final rows = document.querySelectorAll('tbody tr');
      final stops = <SmartStop>[];

      for (var row in rows) {
        final cols = row.querySelectorAll('td');
        if (cols.length >= 3) {
          final id = cols[0].text.trim();
          final name = cols[1].text.trim();

          // ID might also be in the link: /Akilli-Durak/1
          // We can verify or just use col[0].

          stops.add(SmartStop(id: id, name: name));
        }
      }

      return stops;
    } catch (e) {
      print('Error fetching stops: $e');
      return [];
    }
  }

  Future<List<BusArrival>> fetchArrivals(String stopId) async {
    try {
      final url = '$_baseUrl/Akilli-Durak/$stopId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to load arrivals: ${response.statusCode}');
      }

      final document = parser.parse(response.body);
      // Logic to parse arrivals.
      // Based on inspection, we haven't confirmed the table structure for arrivals.
      // We will look for a table separate from the header.
      // Assuming a standard table with rows.

      final arrivals = <BusArrival>[];

      // Attempt to find rows with 3 columns?
      // Or look for specific class if we knew it.
      // For now, let's try to grab all TRs in the body that are NOT the header.

      // Note: The inspected HTML showed a table with 'tarih' and 'saat'.
      // This might be the header for the STOP, not the arrivals.
      // Real arrivals might be in another table or loaded dynamically.
      // If dynamic, we can't scrape static HTML easily without finding the API.
      // But let's check if there are other tables.

      final tables = document.querySelectorAll('table');
      for (var table in tables) {
        // Check if it looks like arrival table
        // Maybe it has headers "Hat", "Süre"?
        final headerText = table.text;
        if (headerText.contains('Hat') ||
            headerText.contains('Güzergah') ||
            headerText.contains('Süre') ||
            headerText.contains('Dakika')) {
          final rows = table.querySelectorAll('tbody tr');
          for (var row in rows) {
            final cells = row.querySelectorAll('td');
            if (cells.length >= 3) {
              arrivals.add(
                BusArrival(
                  lineCode: cells[0].text.trim(),
                  lineName: cells[1].text.trim(),
                  timeRemaining: cells[2].text.trim(),
                ),
              );
            }
          }
        }
      }

      return arrivals;
    } catch (e) {
      print('Error fetching arrivals: $e');
      return [];
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
  static const String _mapUrl = '$_baseUrl/Akilli-Duraklar-Harita';

  Future<List<SmartStop>> fetchSmartStops() async {
    try {
      final response = await http.get(Uri.parse(_mapUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load stops: ${response.statusCode}');
      }

      final body = response.body;
      final duraksMatch = RegExp(
        r'var duraks = (\[.*?\]);',
        dotAll: true,
      ).firstMatch(body);

      if (duraksMatch == null) {
        debugPrint('Could not find duraks variable in HTML');
        return [];
      }

      final duraksJson = duraksMatch.group(1)!;
      final cleanedJson = duraksJson.replaceAll("'", '"');

      final List<dynamic> duraksData;
      try {
        duraksData = _parseJsonArray(cleanedJson);
      } catch (e) {
        debugPrint('JSON parse error: $e');
        return [];
      }

      final stops = <SmartStop>[];
      for (var durak in duraksData) {
        final id = durak['DurakID']?.toString() ?? '';
        final name = durak['durakAd']?.toString() ?? '';
        final latStr = durak['durakLat']?.toString() ?? '0';
        final lngStr = durak['durakLng']?.toString() ?? '0';

        final lat = double.tryParse(latStr) ?? 0.0;
        final lng = double.tryParse(lngStr) ?? 0.0;

        if (id.isNotEmpty && name.isNotEmpty) {
          stops.add(SmartStop(id: id, name: name, lat: lat, lng: lng));
        }
      }

      return stops;
    } catch (e) {
      debugPrint('Error fetching stops: $e');
      return [];
    }
  }

  List<dynamic> _parseJsonArray(String json) {
    return jsonDecode(json) as List<dynamic>;
  }

  Future<List<BusArrival>> fetchArrivals(String stopId) async {
    try {
      final pageUrl = '$_baseUrl/Akilli-Durak/$stopId';
      final pageResponse = await http.get(Uri.parse(pageUrl));
      if (pageResponse.statusCode != 200) {
        throw Exception('Failed to load stop page: ${pageResponse.statusCode}');
      }

      final tokenMatch = RegExp(
        r'<input name="__RequestVerificationToken" type="hidden" value="([^"]+)"',
      ).firstMatch(pageResponse.body);

      if (tokenMatch == null) {
        debugPrint('Could not find verification token');
        return [];
      }

      final token = tokenMatch.group(1)!;
      final cookies = pageResponse.headers['set-cookie'] ?? '';

      final apiUrl = '$_baseUrl/durakTekrar';
      final apiResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'X-Requested-With': 'XMLHttpRequest',
          'Cookie': cookies,
        },
        body:
            'drkID=$stopId&__RequestVerificationToken=${Uri.encodeComponent(token)}',
      );

      if (apiResponse.statusCode != 200) {
        throw Exception('Failed to load arrivals: ${apiResponse.statusCode}');
      }

      final List<dynamic> arrivalsData;
      try {
        arrivalsData = jsonDecode(apiResponse.body) as List<dynamic>;
      } catch (e) {
        debugPrint('JSON parse error: $e');
        return [];
      }

      final arrivals = <BusArrival>[];
      for (var item in arrivalsData) {
        final lineCode = item['hatkod']?.toString() ?? '';
        final lineName = item['hatAd']?.toString() ?? '';
        final sureMinutes = item['sure'];

        String timeRemaining;
        if (sureMinutes is int) {
          timeRemaining = '$sureMinutes dk';
        } else if (sureMinutes is String) {
          timeRemaining = '$sureMinutes dk';
        } else {
          timeRemaining = 'Bilinmiyor';
        }

        if (lineCode.isNotEmpty) {
          arrivals.add(
            BusArrival(
              lineCode: lineCode,
              lineName: lineName,
              timeRemaining: timeRemaining,
            ),
          );
        }
      }

      return arrivals;
    } catch (e) {
      debugPrint('Error fetching arrivals: $e');
      return [];
    }
  }
}

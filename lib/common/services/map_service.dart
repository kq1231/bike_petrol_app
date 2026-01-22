import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

class LocationResult {
  final String name;
  final double lat;
  final double lng;

  LocationResult({required this.name, required this.lat, required this.lng});
}

class MapService {
  // Using OSRM (Open Source Routing Machine) demo server for distance
  // Note: For production, host your own OSRM instance.
  static const String _osrmUrl =
      'https://router.project-osrm.org/route/v1/driving/';

  // Using Nominatim (OpenStreetMap) for search
  static const String _nominatimUrl =
      'https://nominatim.openstreetmap.org/search';

  Future<double> calculateDistance(
      double startLat, double startLng, double endLat, double endLng) async {
    final url = '$_osrmUrl$startLng,$startLat;$endLng,$endLat?overview=false';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          return (data['routes'][0]['distance'] ?? 0) /
              1000.0; // Convert meters to km
        }
      }
    } catch (e) {
      // Error calculating distance: $e
    }
    // Fallback to Haversine if API fails
    return _haversineDistance(startLat, startLng, endLat, endLng);
  }

  Future<List<LocationResult>> searchLocation(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse('$_nominatimUrl?q=$query&format=json&limit=5');

    try {
      final response =
          await http.get(url, headers: {'User-Agent': 'BikePetrolApp'});
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map(
              (item) => LocationResult(
                name: item['display_name'],
                lat: double.parse(item['lat']),
                lng: double.parse(item['lon']),
              ),
            )
            .toList();
      }
    } catch (e) {
      // Error searching location: $e
    }
    return [];
  }

  double _haversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = 2 * (dLat * dLat) +
        _toRadians(lat1) *
            _toRadians(lat2) *
            2 *
            (dLon * dLon); // Simplified haversine fallback

    final double c = 2 * math.asin(math.sqrt(a / 2));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (3.14159265359 / 180);
  }
}

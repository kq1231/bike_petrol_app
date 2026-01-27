import 'package:objectbox/objectbox.dart';

@Entity()
class DrivingRoute {
  @Id()
  int id;

  String startLocation; // e.g., "Home"
  String endLocation; // e.g., "University"
  String? via; // Optional: e.g., "Via Shahrahe Faisal"
  double distanceKm;

  // Computed property for display name
  String get name {
    if (via != null && via!.isNotEmpty) {
      return '$startLocation → $endLocation (via $via)';
    }
    return '$startLocation → $endLocation';
  }

  // Getter for reverse route name
  String get reverseName {
    if (via != null && via!.isNotEmpty) {
      return '$endLocation → $startLocation (via $via)';
    }
    return '$endLocation → $startLocation';
  }

  DrivingRoute({
    this.id = 0,
    required this.startLocation,
    required this.endLocation,
    this.via,
    required this.distanceKm,
  });
}

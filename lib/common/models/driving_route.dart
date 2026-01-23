import 'package:objectbox/objectbox.dart';

@Entity()
class DrivingRoute {
  @Id()
  int id;

  String name; // e.g., "Home -> University"
  double distanceKm;

  DrivingRoute({
    this.id = 0,
    required this.name,
    required this.distanceKm,
  });
}

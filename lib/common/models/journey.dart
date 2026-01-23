import 'package:objectbox/objectbox.dart';

@Entity()
class Journey {
  @Id()
  int id;

  @Property()
  DateTime date;

  // Start Location
  String startName;
  double startLat;
  double startLng;

  // End Location
  String endName;
  double endLat;
  double endLng;

  double distanceKm;
  bool isRoundTrip;

  String? notes;

  // Calculated field stored for convenience
  double litresConsumed;

  Journey({
    this.id = 0,
    required this.date,
    required this.startName,
    required this.startLat,
    required this.startLng,
    required this.endName,
    required this.endLat,
    required this.endLng,
    required this.distanceKm,
    this.isRoundTrip = false,
    this.notes,
    this.litresConsumed = 0,
  });
}

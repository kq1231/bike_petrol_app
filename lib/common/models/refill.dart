import 'package:objectbox/objectbox.dart';

@Entity()
class Refill {
  @Id()
  int id;

  @Property()
  DateTime date;

  double litres;

  double? totalCost; // Optional
  double? costPerLitre; // Optional

  int? odometerReading;
  String? notes;

  Refill({
    this.id = 0,
    required this.date,
    required this.litres,
    this.totalCost,
    this.costPerLitre,
    this.odometerReading,
    this.notes,
  });
}

import 'package:objectbox/objectbox.dart';

@Entity()
class Refill {
  int id = 0;

  @Property()
  DateTime date;

  double litres;
  
  double? totalCost; // Optional
  double? costPerLitre; // Optional
  
  int? odometerReading;
  String? notes;

  Refill({
    required this.date,
    required this.litres,
    this.totalCost,
    this.costPerLitre,
    this.odometerReading,
    this.notes,
  });
}

import 'package:objectbox/objectbox.dart';

@Entity()
class Bike {
  @Id()
  int id;

  String name;
  double mileage; // km per litre

  @Property()
  DateTime createdAt;

  Bike({
    this.id = 0,
    this.name = 'My Bike',
    required this.mileage,
  }) : createdAt = DateTime.now();
}

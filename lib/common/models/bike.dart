import 'package:objectbox/objectbox.dart';

@Entity()
class Bike {
  int id = 0;
  
  String name;
  double mileage; // km per litre
  
  @Property()
  DateTime createdAt;

  Bike({
    this.name = 'My Bike',
    required this.mileage,
  }) : createdAt = DateTime.now();
}

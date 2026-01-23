import 'package:bike_petrol_app/common/models/bike.dart';
import 'package:bike_petrol_app/common/providers/objectbox_store_provider.dart';
import 'package:bike_petrol_app/objectbox.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BikeRepository {
  final Ref ref;

  BikeRepository(this.ref);

  Box<Bike> get _box => ref.read(objectBoxStoreProvider).value!.box<Bike>();

  Bike? getBike() {
    final bikes = _box.getAll();
    return bikes.isNotEmpty ? bikes.first : null;
  }

  void saveBike(Bike bike) async {
    if (bike.id == 0) {
      _box.put(bike);
    } else {
      _box.put(bike, mode: PutMode.update);
    }

    ref.invalidateSelf(); // This will cause providers watching this repository to also invalidate
  }
}

final bikeRepositoryProvider = Provider<BikeRepository>((ref) {
  return BikeRepository(ref);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/objectbox.g.dart';
import 'package:bike_petrol_app/common/models/bike.dart';
import 'package:bike_petrol_app/common/providers/objectbox_store_provider.dart';

class BikeRepository {
  final Ref ref;
  
  BikeRepository(this.ref);

  Box<Bike> get _box => ref.read(objectBoxStoreProvider).value!.box<Bike>();

  Bike? getBike() {
    final bikes = _box.getAll();
    return bikes.isNotEmpty ? bikes.first : null;
  }

  Future<void> saveBike(Bike bike) async {
    if (bike.id == 0) {
      _box.put(bike);
    } else {
      _box.put(bike, mode: PutMode.update);
    }
  }
}

final bikeRepositoryProvider = Provider<BikeRepository>((ref) {
  return BikeRepository(ref);
});

final bikeProvider = FutureProvider<Bike?>((ref) async {
  // Ensure store is ready
  await ref.watch(objectBoxStoreProvider.future);
  final repo = ref.watch(bikeRepositoryProvider);
  return repo.getBike();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/common/models/bike.dart';
import 'package:bike_petrol_app/features/bike_profile/repositories/bike_repository.dart';
import 'package:bike_petrol_app/common/providers/objectbox_store_provider.dart';

// AsyncNotifier for Bike to handle CRUD state
class BikeNotifier extends AsyncNotifier<Bike?> {
  @override
  Future<Bike?> build() async {
    await ref.read(objectBoxStoreProvider.future);
    final repo = ref.watch(bikeRepositoryProvider);
    return repo.getBike();
  }

  void updateBike(Bike bike) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(bikeRepositoryProvider);
      repo.saveBike(bike);
      return repo.getBike(); // Return updated bike
    });
  }
}

final bikeProvider = AsyncNotifierProvider<BikeNotifier, Bike?>(() {
  return BikeNotifier();
});

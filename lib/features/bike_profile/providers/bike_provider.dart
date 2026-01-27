import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/common/models/bike.dart';
import 'package:bike_petrol_app/features/bike_profile/repositories/bike_repository.dart';

// Notifier for Bike to handle CRUD state
class BikeNotifier extends Notifier<Bike?> {
  @override
  Bike? build() {
    final repo = ref.watch(bikeRepositoryProvider);
    return repo.getBike();
  }

  void updateBike(Bike bike) {
    final repo = ref.read(bikeRepositoryProvider);
    repo.saveBike(bike);
    state = repo.getBike(); // Update state with new bike
  }
}

final bikeProvider = NotifierProvider<BikeNotifier, Bike?>(() {
  return BikeNotifier();
});

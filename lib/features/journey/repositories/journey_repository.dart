import 'package:bike_petrol_app/common/models/journey.dart';
import 'package:bike_petrol_app/common/providers/objectbox_store_provider.dart';
import 'package:bike_petrol_app/objectbox.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JourneyRepository {
  final Ref ref;

  JourneyRepository(this.ref);

  Box<Journey> get _box =>
      ref.read(objectBoxStoreProvider).value!.box<Journey>();

  List<Journey> getAllJourneys({int? limit}) {
    final query =
        _box.query().order(Journey_.date, flags: Order.descending).build();
    if (limit != null && limit > 0) query.limit = limit;
    return query.find();
  }

  void addJourney(Journey journey) {
    _box.put(journey);
    ref.invalidateSelf(); // -> This should rebuild all providers 'watching' this repository
  }

  void deleteJourney(int id) {
    _box.remove(id);
    ref.invalidateSelf(); // -> This should rebuild all providers 'watching' this repository
  }

  void updateJourney(Journey journey) {
    _box.put(journey, mode: PutMode.update);
    ref.invalidateSelf(); // -> This should rebuild all providers 'watching' this repository
  }
}

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  return JourneyRepository(ref);
});

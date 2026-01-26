import 'package:bike_petrol_app/common/models/journey.dart';
import 'package:bike_petrol_app/common/providers/objectbox_store_provider.dart';
import 'package:bike_petrol_app/objectbox.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JourneyRepository {
  final Ref ref;

  JourneyRepository(this.ref);

  Box<Journey> get _box =>
      ref.read(objectBoxStoreProvider).value!.box<Journey>();

  List<Journey> getAllJourneys() {
    final query = _box
        .query()
        .order(Journey_.recordedAt, flags: Order.descending)
        .build();
    return query.find();
  }

  /// Get journeys with pagination support
  /// Sorted by recordedAt (descending) for proper chronological order
  List<Journey> getJourneysPaginated({
    required int limit,
    required int offset,
  }) {
    final query = _box
        .query()
        .order(Journey_.recordedAt, flags: Order.descending)
        .build();
    query
      ..limit = limit
      ..offset = offset;
    final results = query.find();
    query.close();
    return results;
  }

  /// Get total count of journeys (useful for pagination UI)
  int getTotalCount() {
    return _box.count();
  }

  void addJourney(Journey journey) {
    _box.put(journey);
    
  }

  void deleteJourney(int id) {
    _box.remove(id);
    
  }

  void updateJourney(Journey journey) {
    _box.put(journey, mode: PutMode.update);
    
  }
}

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  return JourneyRepository(ref);
});

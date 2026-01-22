import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/objectbox.g.dart';
import 'package:bike_petrol_app/common/models/journey.dart';
import 'package:bike_petrol_app/common/providers/objectbox_store_provider.dart';

class JourneyRepository {
  final Ref ref;

  JourneyRepository(this.ref);

  Box<Journey> get _box => ref.read(objectBoxStoreProvider).value!.box<Journey>();

  List<Journey> getAllJourneys() {
    return _box.getAll()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addJourney(Journey journey) async {
    _box.put(journey);
  }
  
  Future<void> deleteJourney(int id) async {
    _box.remove(id);
  }
}

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  return JourneyRepository(ref);
});
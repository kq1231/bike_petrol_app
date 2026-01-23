import 'package:bike_petrol_app/features/journey/repositories/journey_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/common/models/journey.dart';

class JourneyList extends AsyncNotifier<List<Journey>> {
  @override
  Future<List<Journey>> build() async {
    final repo = ref.watch(journeyRepositoryProvider);
    return repo.getAllJourneys();
  }

  void addJourney(Journey journey) async {
    final repo = ref.read(journeyRepositoryProvider);
    repo.addJourney(journey);
  }

  void deleteJourney(int id) async {
    final repo = ref.read(journeyRepositoryProvider);
    repo.deleteJourney(id);
  }

  void updateJourney(Journey journey) async {
    final repo = ref.read(journeyRepositoryProvider);
    repo.updateJourney(journey);
  }
}

final journeyListProvider =
    AsyncNotifierProvider<JourneyList, List<Journey>>(() {
  return JourneyList();
});

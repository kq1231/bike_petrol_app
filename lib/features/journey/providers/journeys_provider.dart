import 'package:bike_petrol_app/features/journey/repositories/journey_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/common/models/journey.dart';

final journeyListProvider = FutureProvider<List<Journey>>((ref) async {
  // Ensure store is ready (dependency of repository)
  // Watch the repository implicitly
  final repo = ref.watch(journeyRepositoryProvider);
  return repo.getAllJourneys();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/journey_repository.dart';

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  return JourneyRepository(ref);
});

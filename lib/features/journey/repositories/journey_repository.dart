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
    final query = _box.query().build();
    final journeys = query.find();
    query.close();
    return _sortJourneys(journeys);
  }

  /// Get journeys with pagination support
  /// Sorted by: startTime -> recordedAt -> date -> distance
  List<Journey> getJourneysPaginated({
    required int limit,
    required int offset,
  }) {
    // Get all journeys and sort them
    final query = _box.query().build();
    final allJourneys = query.find();
    query.close();

    final sortedJourneys = _sortJourneys(allJourneys);

    // Apply pagination
    final start = offset;
    final end = (offset + limit).clamp(0, sortedJourneys.length);

    if (start >= sortedJourneys.length) {
      return [];
    }

    return sortedJourneys.sublist(start, end);
  }

  /// Multi-level sorting logic:
  /// Combines journey date with time for accurate sorting
  /// 1. Primary: Journey date + user-given time (startTime) - DESC
  /// 2. Fallback 1: Journey date + recordedAt time - DESC
  /// 3. Fallback 2: Distance travelled - DESC (for same date/time)
  List<Journey> _sortJourneys(List<Journey> journeys) {
    final sorted = List<Journey>.from(journeys);

    sorted.sort((a, b) {
      // Get effective DateTime for sorting (date + time)
      final aDateTime = _getEffectiveDateTime(a);
      final bDateTime = _getEffectiveDateTime(b);

      // Primary: Sort by effective DateTime
      final dateTimeCompare = bDateTime.compareTo(aDateTime);
      if (dateTimeCompare != 0) return dateTimeCompare;

      // Fallback: Sort by distance (for same date/time)
      return b.distanceKm.compareTo(a.distanceKm);
    });

    return sorted;
  }

  /// Get the effective DateTime for sorting
  /// Priority: date + startTime > date + recordedAt time
  DateTime _getEffectiveDateTime(Journey journey) {
    if (journey.startTime != null) {
      // Use journey date with user-given start time
      return DateTime(
        journey.date.year,
        journey.date.month,
        journey.date.day,
        journey.startTime!.hour,
        journey.startTime!.minute,
        journey.startTime!.second,
      );
    } else {
      // Use journey date with recordedAt time
      return DateTime(
        journey.date.year,
        journey.date.month,
        journey.date.day,
        journey.recordedAt.hour,
        journey.recordedAt.minute,
        journey.recordedAt.second,
      );
    }
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

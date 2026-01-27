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
  /// 1. Primary: User-given time (startTime) - DESC
  /// 2. Fallback 1: recordedAt (when logged) - DESC
  /// 3. Fallback 2: Journey date - DESC
  /// 4. Fallback 3: Distance travelled - DESC (for same date/time)
  List<Journey> _sortJourneys(List<Journey> journeys) {
    final sorted = List<Journey>.from(journeys);
    
    sorted.sort((a, b) {
      // Primary: Sort by user-given start time if both have it
      if (a.startTime != null && b.startTime != null) {
        final timeCompare = b.startTime!.compareTo(a.startTime!);
        if (timeCompare != 0) return timeCompare;
      }
      // If only one has startTime, prioritize it
      else if (a.startTime != null) {
        return -1; // a comes first
      } else if (b.startTime != null) {
        return 1; // b comes first
      }
      
      // Fallback 1: Sort by recordedAt if both have it
      if (a.recordedAt != null && b.recordedAt != null) {
        final recordedCompare = b.recordedAt!.compareTo(a.recordedAt!);
        if (recordedCompare != 0) return recordedCompare;
      }
      // If only one has recordedAt, prioritize it
      else if (a.recordedAt != null) {
        return -1; // a comes first
      } else if (b.recordedAt != null) {
        return 1; // b comes first
      }
      
      // Fallback 2: Sort by journey date
      final dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) return dateCompare;
      
      // Fallback 3: Sort by distance (for same date)
      return b.distanceKm.compareTo(a.distanceKm);
    });
    
    return sorted;
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

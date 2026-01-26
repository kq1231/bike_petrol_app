import 'package:bike_petrol_app/features/journey/repositories/journey_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/common/models/journey.dart';

class PaginatedJourneyState {
  final List<Journey> items;
  final bool hasMore;
  final bool isLoadingMore;

  PaginatedJourneyState({
    required this.items,
    required this.hasMore,
    required this.isLoadingMore,
  });

  PaginatedJourneyState copyWith({
    List<Journey>? items,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PaginatedJourneyState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class JourneyList extends AsyncNotifier<PaginatedJourneyState> {
  static const int _pageSize = 20;
  int _currentOffset = 0;

  @override
  Future<PaginatedJourneyState> build() async {
    final repo = ref.watch(journeyRepositoryProvider);
    final items = repo.getJourneysPaginated(limit: _pageSize, offset: 0);
    _currentOffset = items.length;

    return PaginatedJourneyState(
      items: items,
      hasMore: items.length >= _pageSize,
      isLoadingMore: false,
    );
  }

  /// Load more journeys (called when user scrolls to bottom)
  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore || currentState.isLoadingMore) {
      return;
    }

    // Set loading flag
    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    final repo = ref.read(journeyRepositoryProvider);
    final newItems = repo.getJourneysPaginated(
      limit: _pageSize,
      offset: _currentOffset,
    );

    _currentOffset += newItems.length;

    // Update state with new items
    state = AsyncData(currentState.copyWith(
      items: [...currentState.items, ...newItems],
      hasMore: newItems.length >= _pageSize,
      isLoadingMore: false,
    ));
  }

  /// Refresh the list (called on pull-to-refresh)
  Future<void> refresh() async {
    _currentOffset = 0;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(journeyRepositoryProvider);
      final items = repo.getJourneysPaginated(limit: _pageSize, offset: 0);
      _currentOffset = items.length;

      return PaginatedJourneyState(
        items: items,
        hasMore: items.length >= _pageSize,
        isLoadingMore: false,
      );
    });
  }

  void addJourney(Journey journey) async {
    final repo = ref.read(journeyRepositoryProvider);
    repo.addJourney(journey);
    await refresh();
  }

  void deleteJourney(int id) async {
    final repo = ref.read(journeyRepositoryProvider);
    repo.deleteJourney(id);
    await refresh();
  }

  void updateJourney(Journey journey) async {
    final repo = ref.read(journeyRepositoryProvider);
    repo.updateJourney(journey);
    await refresh();
  }
}

final journeyListProvider =
    AsyncNotifierProvider<JourneyList, PaginatedJourneyState>(() {
  return JourneyList();
});

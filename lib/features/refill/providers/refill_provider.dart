import 'package:bike_petrol_app/features/refill/repositories/refill_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/common/models/refill.dart';

class PaginatedRefillState {
  final List<Refill> items;
  final bool hasMore;
  final bool isLoadingMore;

  PaginatedRefillState({
    required this.items,
    required this.hasMore,
    required this.isLoadingMore,
  });

  PaginatedRefillState copyWith({
    List<Refill>? items,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PaginatedRefillState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class RefillList extends AsyncNotifier<PaginatedRefillState> {
  static const int _pageSize = 20;
  int _currentOffset = 0;

  @override
  Future<PaginatedRefillState> build() async {
    final repo = ref.watch(refillRepositoryProvider);
    final items = repo.getRefillsPaginated(limit: _pageSize, offset: 0);
    _currentOffset = items.length;

    return PaginatedRefillState(
      items: items,
      hasMore: items.length >= _pageSize,
      isLoadingMore: false,
    );
  }

  /// Load more refills (called when user scrolls to bottom)
  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore || currentState.isLoadingMore) {
      return;
    }

    // Set loading flag
    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    final repo = ref.read(refillRepositoryProvider);
    final newItems = repo.getRefillsPaginated(
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
      final repo = ref.read(refillRepositoryProvider);
      final items = repo.getRefillsPaginated(limit: _pageSize, offset: 0);
      _currentOffset = items.length;

      return PaginatedRefillState(
        items: items,
        hasMore: items.length >= _pageSize,
        isLoadingMore: false,
      );
    });
  }

  void addRefill(Refill refill) async {
    final repo = ref.read(refillRepositoryProvider);
    repo.addRefill(refill);
    await refresh();
  }

  void deleteRefill(int id) async {
    final repo = ref.read(refillRepositoryProvider);
    repo.deleteRefill(id);
    await refresh();
  }

  void updateRefill(Refill refill) async {
    final repo = ref.read(refillRepositoryProvider);
    repo.updateRefill(refill);
    await refresh();
  }
}

final refillListProvider = AsyncNotifierProvider<RefillList, PaginatedRefillState>(() {
  return RefillList();
});

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

class RefillList extends Notifier<PaginatedRefillState> {
  static const int _pageSize = 20;
  int _currentOffset = 0;

  @override
  PaginatedRefillState build() {
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
  void loadMore() {
    if (state.hasMore && !state.isLoadingMore) {
      // Set loading flag
      state = state.copyWith(isLoadingMore: true);

      final repo = ref.read(refillRepositoryProvider);
      final newItems = repo.getRefillsPaginated(
        limit: _pageSize,
        offset: _currentOffset,
      );

      _currentOffset += newItems.length;

      // Update state with new items
      state = state.copyWith(
        items: [...state.items, ...newItems],
        hasMore: newItems.length >= _pageSize,
        isLoadingMore: false,
      );
    }
  }

  /// Refresh the list (called on pull-to-refresh)
  void refresh() {
    _currentOffset = 0;
    final repo = ref.read(refillRepositoryProvider);
    final items = repo.getRefillsPaginated(limit: _pageSize, offset: 0);
    _currentOffset = items.length;

    state = PaginatedRefillState(
      items: items,
      hasMore: items.length >= _pageSize,
      isLoadingMore: false,
    );
  }

  void addRefill(Refill refill) {
    final repo = ref.read(refillRepositoryProvider);
    repo.addRefill(refill);
    refresh();
  }

  void deleteRefill(int id) {
    final repo = ref.read(refillRepositoryProvider);
    repo.deleteRefill(id);
    refresh();
  }

  void updateRefill(Refill refill) {
    final repo = ref.read(refillRepositoryProvider);
    repo.updateRefill(refill);
    refresh();
  }
}

final refillListProvider = NotifierProvider<RefillList, PaginatedRefillState>(() {
  return RefillList();
});

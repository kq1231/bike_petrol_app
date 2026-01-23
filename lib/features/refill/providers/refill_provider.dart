import 'package:bike_petrol_app/features/refill/repositories/refill_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/common/models/refill.dart';

class RefillList extends AsyncNotifier<List<Refill>> {
  @override
  Future<List<Refill>> build() async {
    final repo = ref.watch(refillRepositoryProvider);
    return repo.getAllRefills();
  }

  void addRefill(Refill refill) async {
    final repo = ref.read(refillRepositoryProvider);
    repo.addRefill(refill);
  }

  void deleteRefill(int id) async {
    final repo = ref.read(refillRepositoryProvider);
    repo.deleteRefill(id);
  }

  void updateRefill(Refill refill) async {
    final repo = ref.read(refillRepositoryProvider);
    repo.updateRefill(refill);
  }
}

final refillListProvider = AsyncNotifierProvider<RefillList, List<Refill>>(() {
  return RefillList();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/objectbox.g.dart';
import 'package:bike_petrol_app/common/models/refill.dart';
import 'package:bike_petrol_app/common/providers/objectbox_store_provider.dart';

class RefillRepository {
  final Ref ref;

  RefillRepository(this.ref);

  Box<Refill> get _box => ref.read(objectBoxStoreProvider).value!.box<Refill>();

  List<Refill> getAllRefills() {
    return _box.getAll()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addRefill(Refill refill) async {
    _box.put(refill);
    ref.invalidateSelf(); // -> This should rebuild all providers 'watching' this repository
  }

  Future<void> deleteRefill(int id) async {
    _box.remove(id);
    ref.invalidateSelf(); // -> This should rebuild all providers 'watching' this repository
  }
}

final refillRepositoryProvider = Provider<RefillRepository>((ref) {
  return RefillRepository(ref);
});

final refillListProvider = FutureProvider<List<Refill>>((ref) async {
  final repo = ref.watch(refillRepositoryProvider);

  return repo.getAllRefills();
});

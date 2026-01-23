import 'package:bike_petrol_app/common/models/refill.dart';
import 'package:bike_petrol_app/common/providers/objectbox_store_provider.dart';
import 'package:bike_petrol_app/objectbox.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RefillRepository {
  final Ref ref;

  RefillRepository(this.ref);

  Box<Refill> get _box => ref.read(objectBoxStoreProvider).value!.box<Refill>();

  List<Refill> getAllRefills({int? limit}) {
    final query =
        _box.query().order(Refill_.date, flags: Order.descending).build();
    if (limit != null && limit > 0) query.limit = limit;
    return query.find();
  }

  void addRefill(Refill refill) async {
    _box.put(refill);
    ref.invalidateSelf(); // -> This should rebuild all providers 'watching' this repository
  }

  void deleteRefill(int id) async {
    _box.remove(id);
    ref.invalidateSelf(); // -> This should rebuild all providers 'watching' this repository
  }

  void updateRefill(Refill refill) async {
    _box.put(refill, mode: PutMode.update);
    ref.invalidateSelf(); // -> This should rebuild all providers 'watching' this repository
  }
}

final refillRepositoryProvider = Provider<RefillRepository>((ref) {
  return RefillRepository(ref);
});

import 'package:bike_petrol_app/features/refill/repositories/refill_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/common/models/refill.dart';

final refillListProvider = FutureProvider<List<Refill>>((ref) async {
  final repo = ref.watch(refillRepositoryProvider);

  return repo.getAllRefills();
});

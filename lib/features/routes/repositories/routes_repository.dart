import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/common/models/driving_route.dart';
import 'package:bike_petrol_app/common/providers/objectbox_store_provider.dart';
import 'package:bike_petrol_app/objectbox.g.dart';

class RoutesRepository {
  final Ref ref;
  RoutesRepository(this.ref);

  Box<DrivingRoute> get _box =>
      ref.read(objectBoxStoreProvider).value!.box<DrivingRoute>();

  List<DrivingRoute> getAllRoutes() {
    return _box.getAll()..sort((a, b) => a.name.compareTo(b.name));
  }

  void addRoute(DrivingRoute route) {
    _box.put(route);
  }

  void deleteRoute(int id) {
    _box.remove(id);
  }

  void updateRoute(DrivingRoute route) {
    _box.put(route, mode: PutMode.update);
  }
}

final routesRepositoryProvider = Provider<RoutesRepository>((ref) {
  return RoutesRepository(ref);
});

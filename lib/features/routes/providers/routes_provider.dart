import 'package:bike_petrol_app/features/routes/repositories/routes_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/common/models/driving_route.dart';

class RoutesList extends AsyncNotifier<List<DrivingRoute>> {
  @override
  Future<List<DrivingRoute>> build() async {
    final repo = ref.watch(routesRepositoryProvider);
    return repo.getAllRoutes();
  }

  void addRoute(DrivingRoute route) {
    final repo = ref.read(routesRepositoryProvider);
    repo.addRoute(route);
  }

  void deleteRoute(int id) {
    final repo = ref.read(routesRepositoryProvider);
    repo.deleteRoute(id);
  }

  void updateRoute(DrivingRoute route) {
    final repo = ref.read(routesRepositoryProvider);
    repo.updateRoute(route);
  }
}

final routesListProvider =
    AsyncNotifierProvider<RoutesList, List<DrivingRoute>>(() {
  return RoutesList();
});

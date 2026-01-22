import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/features/bike_profile/providers/bike_provider.dart';
import 'package:bike_petrol_app/features/refill/providers/refill_provider.dart';
import 'package:bike_petrol_app/features/journey/providers/journeys_provider.dart';

class DashboardStats {
  final double totalRefills;
  final double totalConsumed;
  final double currentBalance;
  final int totalJourneys;
  final double avgMileage; // Fallback or calculated

  DashboardStats({
    required this.totalRefills,
    required this.totalConsumed,
    required this.currentBalance,
    required this.totalJourneys,
    required this.avgMileage,
  });
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  await Future.wait([
    ref.read(bikeProvider.future),
    ref.read(refillListProvider.future),
    ref.read(journeyListProvider.future),
  ]);

  final bikeAsync = ref.watch(bikeProvider);
  final refills = ref.watch(refillListProvider).value!;
  final journeys = ref.watch(journeyListProvider).value!;

  final double mileage = bikeAsync.value?.mileage ?? 0;

  double totalRefillLitres = 0.0;
  for (var r in refills) {
    totalRefillLitres += r.litres;
  }

  double totalConsumedLitres = 0.0;
  for (var j in journeys) {
    totalConsumedLitres += j.litresConsumed;
  }

  return DashboardStats(
    totalRefills: totalRefillLitres,
    totalConsumed: totalConsumedLitres,
    currentBalance: totalRefillLitres - totalConsumedLitres,
    totalJourneys: journeys.length,
    avgMileage: mileage,
  );
});

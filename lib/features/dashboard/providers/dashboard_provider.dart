import 'package:bike_petrol_app/features/refill/providers/refill_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/features/bike_profile/providers/bike_provider.dart';
import 'package:bike_petrol_app/features/dashboard/repositories/dashboard_repository.dart';

class DashboardStats {
  final double totalRefills;
  final double totalConsumed;
  final double currentBalance;
  final int totalJourneys;
  final double avgMileage;
  final int totalRefillCount;
  final double averageRefillAmount;

  DashboardStats({
    required this.totalRefills,
    required this.totalConsumed,
    required this.currentBalance,
    required this.totalJourneys,
    required this.avgMileage,
    required this.totalRefillCount,
    required this.averageRefillAmount,
  });
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  // Watch the refill provider
  ref.watch(refillListProvider);

  // Watch bike provider
  final bike = ref.watch(bikeProvider);
  final double mileage = bike?.mileage ?? 0;

  // Use the new efficient repository for today's statistics
  final dashboardRepo = ref.watch(dashboardRepositoryProvider);
  final stats = dashboardRepo.calculateTodayStatistics();

  return DashboardStats(
    totalRefills: stats.totalRefills,
    totalConsumed: stats.totalConsumed,
    currentBalance: stats.currentBalance,
    totalJourneys: stats.totalJourneys,
    avgMileage: mileage,
    totalRefillCount: stats.totalRefillCount,
    averageRefillAmount: stats.averageRefillAmount,
  );
});

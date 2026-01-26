import 'package:bike_petrol_app/common/models/refill.dart';
import 'package:bike_petrol_app/common/models/journey.dart';
import 'package:bike_petrol_app/common/providers/objectbox_store_provider.dart';
import 'package:bike_petrol_app/objectbox.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardStatistics {
  final double totalRefills;
  final double totalConsumed;
  final double currentBalance;
  final int totalJourneys;
  final int totalRefillCount;
  final double averageRefillAmount;

  DashboardStatistics({
    required this.totalRefills,
    required this.totalConsumed,
    required this.currentBalance,
    required this.totalJourneys,
    required this.totalRefillCount,
    required this.averageRefillAmount,
  });

  DashboardStatistics copyWith({
    double? totalRefills,
    double? totalConsumed,
    double? currentBalance,
    int? totalJourneys,
    int? totalRefillCount,
    double? averageRefillAmount,
  }) {
    return DashboardStatistics(
      totalRefills: totalRefills ?? this.totalRefills,
      totalConsumed: totalConsumed ?? this.totalConsumed,
      currentBalance: currentBalance ?? this.currentBalance,
      totalJourneys: totalJourneys ?? this.totalJourneys,
      totalRefillCount: totalRefillCount ?? this.totalRefillCount,
      averageRefillAmount: averageRefillAmount ?? this.averageRefillAmount,
    );
  }
}

/// Repository for calculating dashboard statistics using efficient ObjectBox queries
class DashboardRepository {
  final Ref ref;

  DashboardRepository(this.ref);

  Box<Refill> get _refillBox =>
      ref.read(objectBoxStoreProvider).value!.box<Refill>();

  Box<Journey> get _journeyBox =>
      ref.read(objectBoxStoreProvider).value!.box<Journey>();

  /// Calculate all dashboard statistics efficiently using aggregate queries
  /// This avoids loading all records into memory
  DashboardStatistics calculateStatistics() {
    // Use ObjectBox aggregate queries for performance
    final refillQuery = _refillBox.query().build();
    final totalRefillLitres = refillQuery.property(Refill_.litres).sum();
    final refillCount = refillQuery.count();
    refillQuery.close();

    final journeyQuery = _journeyBox.query().build();
    final totalConsumedLitres = journeyQuery.property(Journey_.litresConsumed).sum();
    final journeyCount = journeyQuery.count();
    journeyQuery.close();

    final averageRefill = refillCount > 0 ? totalRefillLitres / refillCount : 0.0;
    final currentBalance = totalRefillLitres - totalConsumedLitres;

    return DashboardStatistics(
      totalRefills: totalRefillLitres,
      totalConsumed: totalConsumedLitres,
      currentBalance: currentBalance,
      totalJourneys: journeyCount,
      totalRefillCount: refillCount,
      averageRefillAmount: averageRefill,
    );
  }

  /// Get statistics for a specific date range (for analytics)
  DashboardStatistics calculateStatisticsForRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    // Query refills in date range
    final refillQuery = _refillBox
        .query(Refill_.date
            .greaterOrEqual(startDate.millisecondsSinceEpoch)
            .and(Refill_.date.lessOrEqual(endDate.millisecondsSinceEpoch)))
        .build();
    final totalRefillLitres = refillQuery.property(Refill_.litres).sum();
    final refillCount = refillQuery.count();
    refillQuery.close();

    // Query journeys in date range
    final journeyQuery = _journeyBox
        .query(Journey_.date
            .greaterOrEqual(startDate.millisecondsSinceEpoch)
            .and(Journey_.date.lessOrEqual(endDate.millisecondsSinceEpoch)))
        .build();
    final totalConsumedLitres = journeyQuery.property(Journey_.litresConsumed).sum();
    final journeyCount = journeyQuery.count();
    journeyQuery.close();

    final averageRefill = refillCount > 0 ? totalRefillLitres / refillCount : 0.0;
    final currentBalance = totalRefillLitres - totalConsumedLitres;

    return DashboardStatistics(
      totalRefills: totalRefillLitres,
      totalConsumed: totalConsumedLitres,
      currentBalance: currentBalance,
      totalJourneys: journeyCount,
      totalRefillCount: refillCount,
      averageRefillAmount: averageRefill,
    );
  }

  /// Get the minimum route distance (for low petrol warning)
  double getMinimumRouteDistance() {
    final journeyQuery = _journeyBox
        .query()
        .order(Journey_.distanceKm)
        .build();
    journeyQuery.limit = 1;
    final journeys = journeyQuery.find();
    journeyQuery.close();

    return journeys.isNotEmpty ? journeys.first.distanceKm : 0.0;
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref);
});

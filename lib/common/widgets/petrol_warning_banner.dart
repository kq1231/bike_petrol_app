import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/common/models/driving_route.dart';
import 'package:bike_petrol_app/features/routes/providers/routes_provider.dart';
import 'package:bike_petrol_app/features/dashboard/providers/dashboard_provider.dart';
import 'package:bike_petrol_app/features/bike_profile/providers/bike_provider.dart';
import 'package:bike_petrol_app/common/providers/tab_index_provider.dart';

enum PetrolWarningLevel {
  none,
  warning,  // Less than 3 routes possible
  low,      // Only 1-2 shortest routes possible
  critical, // Not enough for any route
}

class PetrolWarningBanner extends ConsumerWidget {
  final VoidCallback? onDismiss;

  const PetrolWarningBanner({
    super.key,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read all required data from providers
    final routes = ref.watch(routesListProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final bike = ref.watch(bikeProvider);

    final currentPetrol = stats.currentBalance;
    final mileage = bike?.mileage ?? 0;

    // Calculate warning level
    final level = _calculateWarningLevel(
      currentPetrol: currentPetrol,
      routes: routes,
      mileage: mileage,
    );

    if (level == PetrolWarningLevel.none) {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String title;
    String message;

    switch (level) {
      case PetrolWarningLevel.critical:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade900;
        icon = Icons.error;
        title = 'Critical: Out of Petrol';
        message = 'You have ${currentPetrol.toStringAsFixed(2)}L - not enough for any saved route.';
        break;
      case PetrolWarningLevel.low:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade900;
        icon = Icons.warning;
        title = 'Low Petrol Alert';
        message = 'You have ${currentPetrol.toStringAsFixed(2)}L - only enough for 1-2 shortest routes.';
        break;
      case PetrolWarningLevel.warning:
        backgroundColor = Colors.yellow.shade50;
        textColor = Colors.orange.shade800;
        icon = Icons.info;
        title = 'Petrol Running Low';
        message = 'You have ${currentPetrol.toStringAsFixed(2)}L - less than 3 routes possible.';
        break;
      case PetrolWarningLevel.none:
        return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: textColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: Icon(Icons.close, color: textColor),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: textColor, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to refill screen (tab index 1)
                  ref.read(tabIndexProvider.notifier).state = 1;
                },
                icon: const Icon(Icons.local_gas_station, size: 18),
                label: const Text('Refill Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: textColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PetrolWarningLevel _calculateWarningLevel({
    required double currentPetrol,
    required List<DrivingRoute> routes,
    required double mileage,
  }) {
    if (mileage <= 0 || routes.isEmpty) {
      return PetrolWarningLevel.none;
    }

    // Sort routes by distance to find the shortest
    final sortedRoutes = List<DrivingRoute>.from(routes)
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    // Count how many routes are feasible with current petrol
    int feasibleRoutesCount = 0;
    for (final route in sortedRoutes) {
      final requiredPetrol = route.distanceKm / mileage;
      if (currentPetrol >= requiredPetrol) {
        feasibleRoutesCount++;
      }
    }

    // Determine warning level based on feasible routes count
    if (feasibleRoutesCount == 0) {
      return PetrolWarningLevel.critical;
    } else if (feasibleRoutesCount <= 2) {
      return PetrolWarningLevel.low;
    } else if (feasibleRoutesCount < 3) {
      return PetrolWarningLevel.warning;
    } else {
      return PetrolWarningLevel.none;
    }
  }
}

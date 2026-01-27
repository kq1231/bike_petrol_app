import 'package:flutter/material.dart';

enum RouteFeasibility {
  canDoRoundTrip,   // ✅✅ Green - enough for round trip
  canDoOneWay,      // ✅ Green - enough for one-way
  insufficient,     // ❌ Red - not enough petrol
}

class RouteFeasibilityIndicator extends StatelessWidget {
  final RouteFeasibility feasibility;
  final double size;

  const RouteFeasibilityIndicator({
    super.key,
    required this.feasibility,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    switch (feasibility) {
      case RouteFeasibility.canDoRoundTrip:
        return Tooltip(
          message: 'Enough petrol for round trip',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: size),
              SizedBox(width: size * 0.2),
              Icon(Icons.check_circle, color: Colors.green, size: size),
            ],
          ),
        );
      case RouteFeasibility.canDoOneWay:
        return Tooltip(
          message: 'Enough petrol for one-way only',
          child: Icon(Icons.check_circle, color: Colors.green, size: size),
        );
      case RouteFeasibility.insufficient:
        return Tooltip(
          message: 'Not enough petrol',
          child: Icon(Icons.cancel, color: Colors.red, size: size),
        );
    }
  }

  static RouteFeasibility calculateFeasibility({
    required double currentPetrol,
    required double routeDistance,
    required double mileage,
  }) {
    if (mileage <= 0) return RouteFeasibility.insufficient;

    final oneWayConsumption = routeDistance / mileage;
    final roundTripConsumption = (routeDistance * 2) / mileage;

    if (currentPetrol >= roundTripConsumption) {
      return RouteFeasibility.canDoRoundTrip;
    } else if (currentPetrol >= oneWayConsumption) {
      return RouteFeasibility.canDoOneWay;
    } else {
      return RouteFeasibility.insufficient;
    }
  }
}

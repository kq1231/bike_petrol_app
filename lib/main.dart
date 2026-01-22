import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/start/widgets/app_startup_widget.dart';
import 'package:bike_petrol_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:bike_petrol_app/features/refill/screens/refill_screen.dart';
import 'package:bike_petrol_app/features/journey/screens/journey_screen.dart';
import 'package:bike_petrol_app/features/journey/screens/estimator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppStartupWidget();
  }
}

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const RefillScreen(),
    const JourneyScreen(),
    const EstimatorScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.local_gas_station), label: 'Refill'),
          BottomNavigationBarItem(icon: Icon(Icons.alt_route), label: 'Journey'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Estimate'),
        ],
      ),
    );
  }
}

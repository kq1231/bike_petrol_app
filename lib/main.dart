import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/start/widgets/app_startup_widget.dart';
import 'package:bike_petrol_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:bike_petrol_app/features/refill/screens/refill_screen.dart';
import 'package:bike_petrol_app/features/journey/screens/journey_screen.dart';
import 'package:bike_petrol_app/features/routes/screens/routes_screen.dart';
import 'package:bike_petrol_app/features/bike_profile/providers/bike_provider.dart';
import 'package:bike_petrol_app/features/bike_profile/widgets/bike_dialog.dart';
import 'package:bike_petrol_app/common/providers/tab_index_provider.dart';

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

class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check bike setup
    final bike = ref.watch(bikeProvider);

    return Scaffold(
      body: bike == null
          ? BikeDialog(initialBike: null)
          : _MainApp(),
    );
  }
}

class _MainApp extends ConsumerStatefulWidget {
  const _MainApp();

  @override
  ConsumerState<_MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<_MainApp> {
  final List<Widget> _screens = [
    const DashboardScreen(),
    const RefillScreen(),
    const JourneyScreen(),
    const RoutesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(tabIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) => ref.read(tabIndexProvider.notifier).state = index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_gas_station), label: 'Refill'),
          BottomNavigationBarItem(
              icon: Icon(Icons.alt_route), label: 'Journey'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Routes'),
        ],
      ),
    );
  }
}

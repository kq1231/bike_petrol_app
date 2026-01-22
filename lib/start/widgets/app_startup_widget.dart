import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/counter/screens/counter_screen.dart';
import '../providers/app_startup_provider.dart';

/// Widget that handles the app startup flow with proper loading and error states.
/// 
/// ARCHITECTURE NOTE:
/// This widget demonstrates the standard Riverpod pattern for handling async operations:
/// 1. Watch the async provider
/// 2. Handle loading state - show a loading indicator
/// 3. Handle error state - show an error message with retry
/// 4. Handle success state - show the actual app
/// 
/// This pattern should be used throughout your app whenever dealing with async data.
/// 
/// WHY THIS PATTERN:
/// - Separates concerns: startup logic is in the provider, UI is in the widget
/// - Type-safe: AsyncValue gives us compile-time guarantees about handling all states
/// - Testable: provider can be easily mocked and tested independently
/// - User-friendly: proper loading and error states improve UX
class AppStartupWidget extends ConsumerWidget {
  const AppStartupWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the appStartup provider
    // AsyncValue<T> is Riverpod's way of representing async data
    // It can be in one of three states: loading, error, or data
    final appStartupState = ref.watch(appStartupProvider);

    // Use pattern matching to handle different states
    // This is the recommended way to work with AsyncValue
    return appStartupState.when(
      // LOADING STATE
      // Shown while the app is initializing
      // Keep this simple - just a loading indicator on a plain background
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      
      // ERROR STATE
      // Shown if initialization fails
      // Always provide a way to retry - users shouldn't need to restart the app
      error: (error, stackTrace) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Retry button - invalidates the provider to trigger re-initialization
                ElevatedButton.icon(
                  onPressed: () {
                    // Invalidate the provider to retry initialization
                    // This is the standard way to "retry" an async operation in Riverpod
                    ref.invalidate(appStartupProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      
      // SUCCESS STATE
      // Initialization complete - show the actual app
      // This is where you return your MaterialApp with routes, theme, etc.
      data: (_) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Riverpod Architecture Starter',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        // For a real app, you would set up your routes here
        // For this starter, we just show the counter example
        home: const CounterScreen(),
      ),
    );
  }
}

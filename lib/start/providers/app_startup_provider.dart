import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that handles application startup and initialization.
/// 
/// This is where you initialize:
/// - Database connections (e.g., Hive, ObjectBox, SQLite)
/// - Services (e.g., Firebase, notification services)
/// - Authentication state
/// - Feature flags
/// - Any other async initialization required before the app can run
final appStartupProvider = AsyncNotifierProvider<AppStartupNotifier, void>(
  AppStartupNotifier.new,
);

/// AsyncNotifier for managing app startup state.
/// 
/// ASYNCNOTIFIER PATTERN:
/// - Extends `AsyncNotifier<T>` where T is your async state type
/// - build() returns a `Future<T>` with the initial async operation
/// - Has access to ref for reading other providers
/// - Can have methods to re-trigger initialization or update state
class AppStartupNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // This is where async initialization happens
    // The build method is called once when the provider is first accessed
    // If initialization fails, throw an exception and AppStartupWidget will show an error
    
    // Simulate async initialization (e.g., database setup, service initialization)
    // In a real app, you would initialize your services here using ref:
    // 
    // Example:
    // await ref.read(databaseServiceProvider).initialize();
    // await ref.read(authServiceProvider).checkAuthStatus();
    // await ref.read(notificationServiceProvider).initialize();
    
    await Future.delayed(const Duration(seconds: 2));
    
    // If initialization succeeds, this completes normally
    // The fact that this completes successfully is enough to signal "app is ready"
  }

  /// Optional: Method to re-initialize the app
  /// This can be called to retry initialization after a failure
  Future<void> retry() async {
    // Set state to loading
    state = const AsyncLoading();
    
    // Re-run initialization
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(seconds: 2));
      // Perform initialization again
    });
  }
}

// USAGE IN WIDGETS:
// 
// To watch the startup state:
//   final startupState = ref.watch(appStartupProvider);
// 
// The state is an AsyncValue which can be:
//   - AsyncLoading() - initialization in progress
//   - AsyncData(value) - initialization succeeded
//   - AsyncError(error, stackTrace) - initialization failed
// 
// To retry initialization:
//   ref.read(appStartupProvider.notifier).retry();

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A simple counter provider demonstrating state management with Riverpod.
final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

/// Notifier for managing counter state.
/// 
/// NOTIFIER PATTERN:
/// - Extends `Notifier<T>` where T is your state type
/// - build() returns the initial state
/// - Has access to ref for reading other providers
/// - Methods modify state by assigning to it
class CounterNotifier extends Notifier<int> {
  /// The initial state of the counter.
  /// 
  /// This method is called once when the provider is first accessed.
  /// Return the initial value of your state here.
  @override
  int build() {
    // You can perform initialization here if needed
    // For example, reading from shared preferences or a database
    // You can also use ref to read other providers:
    // final savedCount = ref.watch(savedCountProvider);
    // return savedCount ?? 0;
    
    return 0; // Initial counter value
  }

  /// Increment the counter by 1.
  /// 
  /// BEST PRACTICE:
  /// Keep business logic in providers, not in widgets.
  /// Widgets should call methods like this, not manipulate state directly.
  void increment() {
    // state is the current value
    // Assigning to state automatically notifies listeners
    state = state + 1;
  }

  /// Decrement the counter by 1.
  void decrement() {
    state = state - 1;
  }

  /// Reset the counter to 0.
  /// 
  /// This demonstrates that you can have any business logic you want.
  /// The widget doesn't need to know HOW to reset, just that it can call reset().
  void reset() {
    state = 0;
  }

  /// Increment by a custom amount.
  /// 
  /// This shows how to accept parameters in your methods.
  void incrementBy(int amount) {
    state = state + amount;
  }
}

// USAGE IN WIDGETS:
// 
// To read the current value:
//   final count = ref.watch(counterProvider);
// 
// To call methods:
//   ref.read(counterProvider.notifier).increment();
// 
// The .notifier gives you access to the CounterNotifier instance,
// allowing you to call its methods.

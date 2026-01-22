import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/counter_provider.dart';

/// The counter screen demonstrating Riverpod state management.
/// 
/// ARCHITECTURE NOTE:
/// This is a ConsumerWidget, which gives us access to WidgetRef.
/// WidgetRef is how we interact with providers - reading values and calling methods.
/// 
/// ALTERNATIVES:
/// - Consumer widget: for when only part of the tree needs to rebuild
/// - ConsumerStatefulWidget: when you need lifecycle methods
/// - Use hooks_riverpod package for a more functional approach with hooks
/// 
/// BEST PRACTICE:
/// Use ConsumerWidget by default. It's simple and performant.
/// Only use StatefulWidget when you specifically need lifecycle methods.
class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WATCHING PROVIDERS:
    // ref.watch() is used to read a provider and rebuild when it changes.
    // When the counter value changes, this widget will rebuild.
    // 
    // This is REACTIVE - you don't need to call setState() manually.
    // Riverpod handles rebuilding for you.
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Counter Example'),
        // Optional: Add a reset button in the app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset counter',
            onPressed: () {
              // ref.read() is used when you want to read WITHOUT listening to changes
              // Use it for calling methods or one-time reads
              // 
              // .notifier gives access to the Counter class to call methods
              ref.read(counterProvider.notifier).reset();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Explanatory text
            const Text(
              'You have pushed the button this many times:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            
            // Display the counter value
            // This text rebuilds whenever count changes
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            
            const SizedBox(height: 32),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decrement button
                FloatingActionButton(
                  heroTag: 'decrement', // Required when multiple FABs are used
                  onPressed: () {
                    // Call the decrement method
                    // This will update the state and trigger a rebuild
                    ref.read(counterProvider.notifier).decrement();
                  },
                  tooltip: 'Decrement',
                  child: const Icon(Icons.remove),
                ),
                
                const SizedBox(width: 16),
                
                // Increment button
                FloatingActionButton(
                  heroTag: 'increment',
                  onPressed: () {
                    ref.read(counterProvider.notifier).increment();
                  },
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Example of calling a method with parameters
            ElevatedButton(
              onPressed: () {
                ref.read(counterProvider.notifier).incrementBy(5);
              },
              child: const Text('Increment by 5'),
            ),
          ],
        ),
      ),
    );
  }
}

// KEY TAKEAWAYS:
// 
// 1. ConsumerWidget gives you access to WidgetRef
// 2. ref.watch() to read values and rebuild on changes
// 3. ref.read() for one-time reads or calling methods
// 4. .notifier to access the provider class methods
// 5. Keep business logic in providers, UI logic in widgets
// 6. No need for setState() - Riverpod handles rebuilds

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extension on AsyncValue to handle UI states in a standardized way.
/// 
/// ARCHITECTURE NOTE:
/// This is a utility extension that makes it easier to handle AsyncValue states
/// throughout your app. It provides a consistent pattern for:
/// - Showing loading indicators
/// - Displaying errors
/// - Rendering data
/// 
/// USAGE:
/// ```dart
/// final asyncData = ref.watch(someAsyncProvider);
/// return asyncData.buildUI(
///   data: (value) => Text('Data: $value'),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => Text('Error: $error'),
/// );
/// ```
extension AsyncValueUI on AsyncValue<void> {
  /// Show an error snackbar if the AsyncValue is in error state.
  /// 
  /// This is useful for operations where you want to show a temporary
  /// error message (like a failed save operation) rather than replacing
  /// the entire UI with an error state.
  /// 
  /// USAGE:
  /// ```dart
  /// ref.listen(someAsyncProvider, (previous, next) {
  ///   next.showSnackbarOnError(context);
  /// });
  /// ```
  void showSnackbarOnError(BuildContext context) {
    if (!isLoading && hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }
}

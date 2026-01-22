import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'start/widgets/app_startup_widget.dart';

/// The main entry point of the application.
/// 
/// We wrap the entire app in a [ProviderScope] which is required for Riverpod.
/// This enables dependency injection and state management throughout the app.
/// 
/// The [ProviderScope] acts as the root container for all providers,
/// similar to how InheritedWidget works but with much more power and flexibility.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // ProviderScope is the foundation of Riverpod
    // All providers must be descendants of ProviderScope
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// The root widget of the application.
/// 
/// This is kept minimal - the real app initialization happens in [AppStartupWidget].
/// This separation allows us to handle async initialization (database setup, 
/// service initialization, etc.) before showing the main app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AppStartupWidget handles the async initialization flow
    // It will show loading states while services are being initialized
    return const AppStartupWidget();
  }
}

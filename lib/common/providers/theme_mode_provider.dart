import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for managing app theme mode (light/dark/system).
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeModeEnum>(
  ThemeModeNotifier.new,
);

/// Notifier for managing theme mode state.
/// 
/// NOTIFIER PATTERN:
/// - Extends `Notifier<T>` where T is your state type
/// - build() method returns the initial state
/// - Has access to ref for reading other providers
/// - Methods modify state by assigning to it: state = newValue
/// - Listeners are automatically notified when state changes
class ThemeModeNotifier extends Notifier<ThemeModeEnum> {
  @override
  ThemeModeEnum build() {
    // In a real app, load the saved preference here
    // You can use ref to access other providers:
    // final prefs = ref.watch(sharedPreferencesProvider);
    // final savedMode = prefs.getString('theme_mode');
    // return ThemeModeEnum.values.firstWhere(
    //   (e) => e.name == savedMode,
    //   orElse: () => ThemeModeEnum.system,
    // );
    
    return ThemeModeEnum.system;
  }

  /// Set the theme mode and persist it
  void setThemeMode(ThemeModeEnum mode) {
    state = mode;
    
    // In a real app, persist the change here
    // You can use ref to access other providers:
    // final prefs = ref.read(sharedPreferencesProvider);
    // prefs.setString('theme_mode', mode.name);
  }

  /// Toggle between light and dark mode
  void toggle() {
    state = state == ThemeModeEnum.light 
        ? ThemeModeEnum.dark 
        : ThemeModeEnum.light;
  }
}

/// Enum for theme mode options
/// 
/// Using an enum instead of Flutter's ThemeMode for better type safety
/// and to demonstrate how to work with enums in providers
enum ThemeModeEnum {
  light,
  dark,
  system;

  /// Convert to Flutter's ThemeMode
  ThemeMode toThemeMode() {
    switch (this) {
      case ThemeModeEnum.light:
        return ThemeMode.light;
      case ThemeModeEnum.dark:
        return ThemeMode.dark;
      case ThemeModeEnum.system:
        return ThemeMode.system;
    }
  }
}

// USAGE IN WIDGETS:
// 
// To read the current theme mode:
//   final themeMode = ref.watch(themeModeProvider);
// 
// To change the theme:
//   ref.read(themeModeProvider.notifier).setThemeMode(ThemeModeEnum.dark);
// 
// To toggle:
//   ref.read(themeModeProvider.notifier).toggle();

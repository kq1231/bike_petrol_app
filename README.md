# Riverpod Architecture Starter

A production-ready Flutter starter template using **Riverpod** and **Clean Architecture** principles, based on the patterns taught by [Andrea Bizzotto (Code with Andrea)](https://codewithandrea.com/).

## 🎯 Purpose

This template provides a solid foundation for building scalable Flutter applications with:
- **Clear separation of concerns** through layered architecture
- **Type-safe state management** using Riverpod
- **Async initialization** handling with proper loading and error states
- **Code generation** for reducing boilerplate
- **Best practices** baked in from the start

## 📁 Project Structure
```
lib/
├── common/              # Shared code used across features
│   ├── providers/       # App-level providers (theme, auth, etc.)
│   ├── widgets/         # Reusable UI components
│   └── ...
├── features/            # Feature modules (each feature is self-contained)
│   └── counter/         # Example feature
│       ├── providers/   # Feature-specific state management
│       ├── screens/     # Feature screens
│       ├── widgets/     # Feature-specific widgets (optional)
│       ├── models/      # Feature domain models (optional)
│       ├── repositories/# Feature data layer (optional)
│       └── services/    # Feature services (optional)
├── start/               # App initialization
│   ├── providers/       # Startup provider
│   └── widgets/         # Startup widget
├── utils/               # Utility functions and extensions
└── main.dart            # App entry point
```
import 'package:flutter_riverpod/legacy.dart';

/// Provider to manage the currently selected bottom navigation tab
/// 0 = Dashboard, 1 = Refill, 2 = Journey, 3 = Routes
final tabIndexProvider = StateProvider<int>((ref) => 0);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/objectbox.g.dart';
import '../services/objectbox_service.dart';

/// Provider for ObjectBox store
/// 
/// This provider initializes the ObjectBox database and provides the Store instance
/// to the rest of the app. The store is automatically closed when the provider is disposed.
final objectBoxStoreProvider = FutureProvider<Store>((ref) async {
  final store = await ObjectBoxService.create();
  
  // Close the store when the provider is disposed
  ref.onDispose(() {
    store.close();
  });
  
  return store;
});

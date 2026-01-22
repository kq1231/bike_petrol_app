import 'package:bike_petrol_app/objectbox.g.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Service responsible for creating and providing ObjectBox Store
/// 
/// This service handles the initialization of the ObjectBox database.
/// It creates the store in the application's documents directory.
class ObjectBoxService {
  ObjectBoxService._();

  /// Create ObjectBox store with initialized database
  /// 
  /// The database will be stored in the app's documents directory
  /// under 'bike_petrol_app' folder.
  static Future<Store> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(
      directory: p.join(docsDir.path, 'bike_petrol_app :: database'),
    );
    return store;
  }
}
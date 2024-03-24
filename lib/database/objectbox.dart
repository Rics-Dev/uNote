import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


import '../models/entities.dart';
import '../objectbox.g.dart';

class ObjectBox {
  late final Store store;
  late final Box<Task> taskBox;
  ObjectBox._create(this.store) {
    taskBox = store.box<Task>();
    // Add any additional setup code, e.g. build queries.
  }
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store =
        await openStore(directory: p.join(docsDir.path, "obx-example"));
    return ObjectBox._create(store);
  }
}
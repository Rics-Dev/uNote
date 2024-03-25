import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


import '../models/entities.dart';
import '../objectbox.g.dart';

class ObjectBox {
  late final Store store;
  late final Box<Task> taskBox;
  late final Box<Tag> tagBox;
  late final Box<TaskList> taskListBox;
  ObjectBox._create(this.store) {
    taskBox = store.box<Task>();
    tagBox = store.box<Tag>();
    taskListBox = store.box<TaskList>();

    // Add any additional setup code, e.g. build queries.
  }
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store =
        await openStore(directory: p.join(docsDir.path, "obx-example"));
    return ObjectBox._create(store);
  }

  Stream<List<Task>> getTasks() {
    return taskBox.query().watch(triggerImmediately: true).map((query) {
      return query.find();
    });
  }

  Stream<List<Tag>> getTags() {
    return tagBox.query().watch(triggerImmediately: true).map((query) {
      return query.find();
    });
  }

  Stream<List<TaskList>> getTaskLists() {
    return taskListBox.query().watch(triggerImmediately: true).map((query) {
      return query.find();
    });
  }
}
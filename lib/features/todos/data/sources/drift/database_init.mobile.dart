import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

QueryExecutor openConnection() {
  return LazyDatabase(() => driftDatabase(name: 'todo'));
}

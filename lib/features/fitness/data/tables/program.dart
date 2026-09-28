import 'package:drift/drift.dart';
import 'package:tenkai/core/table_mixin.dart';

class Programs extends Table with TableMixin {
  TextColumn get title => text().withLength(min: 1, max: 64)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

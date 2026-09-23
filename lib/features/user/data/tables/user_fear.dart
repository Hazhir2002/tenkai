import 'package:drift/drift.dart';
import 'package:tenkai/core/table_mixin.dart';
import 'package:tenkai/features/user/models/user_fear_status.dart';

class UserFear extends Table with TableMixin {
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get why => text()();
  TextColumn get solution => text().nullable()();
  IntColumn get status => intEnum<UserFearStatus>().withDefault(
    Constant(UserFearStatus.unaddressed.index),
  )();
}

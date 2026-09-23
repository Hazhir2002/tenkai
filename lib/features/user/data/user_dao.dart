import 'package:drift/drift.dart';
import 'package:tenkai/core/database.dart';

import 'tables/user_stat.dart';
import 'tables/user_fear.dart';

part 'user_dao.g.dart';

/// Data access for the user feature (user stats).
@DriftAccessor(tables: [UserStat, UserFear])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Future<UserStatData> addStat(UserStatCompanion entry) {
    return into(userStat).insertReturning(entry);
  }

  Future<List<UserStatData>> get allUserStats => select(userStat).get();

  Future<UserStatData> updateStat(UserStatData entry) async {
    await update(userStat).replace(entry);
    return (select(userStat)..where((t) => t.id.equals(entry.id))).getSingle();
  }

  Future<List<UserFearData>> get allUserFears => select(userFear).get();

  Future<UserFearData> addUserFear(UserFearCompanion entry) {
    return transaction(() async {
      return await into(userFear).insertReturning(entry);
    });
  }
}

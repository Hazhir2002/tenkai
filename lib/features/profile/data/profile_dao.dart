import 'package:drift/drift.dart';
import 'package:tenkai/core/database.dart';

import 'tables/user_stat.dart';

part 'profile_dao.g.dart';

/// Data access for the profile feature (user stats).
@DriftAccessor(tables: [UserStat])
class ProfileDao extends DatabaseAccessor<AppDatabase> with _$ProfileDaoMixin {
  ProfileDao(super.db);

  Future<UserStatData> addStat(UserStatCompanion entry) {
    return into(userStat).insertReturning(entry);
  }

  Future<List<UserStatData>> get allUserStats => select(userStat).get();

  Future<UserStatData> updateStat(UserStatData entry) async {
    await update(userStat).replace(entry);
    return (select(
      userStat,
    )..where((t) => t.id.equals(entry.id))).getSingle();
  }
}

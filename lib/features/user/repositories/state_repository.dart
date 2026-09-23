import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/providers.dart';

class StatRepository {
  StatRepository(this._db);
  final AppDatabase _db;

  Future<UserStatData> addStat(UserStatCompanion entry) =>
      _db.userDao.addStat(entry);

  Future<List<UserStatData>> get allUserStats => _db.userDao.allUserStats;

  Future<UserStatData> updateStat(UserStatData entry) =>
      _db.userDao.updateStat(entry);
}

final statRepositoryProvider = Provider<StatRepository>(
  (ref) => StatRepository(ref.read(appDataBaseProvider)),
);

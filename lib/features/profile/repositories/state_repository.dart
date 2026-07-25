import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/providers.dart';

class StatRepository {
  StatRepository(this._db);
  final AppDatabase _db;

  Future<UserStatData> addStat(UserStatCompanion entry) =>
      _db.profileDao.addStat(entry);

  Future<List<UserStatData>> get allUserStats => _db.profileDao.allUserStats;

  Future<UserStatData> updateStat(UserStatData entry) =>
      _db.profileDao.updateStat(entry);
}

final statRepositoryProvider = Provider<StatRepository>(
  (ref) => StatRepository(ref.read(appDataBaseProvider)),
);

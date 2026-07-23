import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/providers.dart';

class StatRepository {
  StatRepository(this._db);
  final AppDatabase _db;

  Future<UserStatData> addStat(UserStatCompanion entry) {
    return _db.into(_db.userStat).insertReturning(entry);
  }

  Future<List<UserStatData>> get allUserStats => _db.select(_db.userStat).get();

  Future<UserStatData> updateStat(UserStatData entry) async {
    await _db.update(_db.userStat).replace(entry);
    return (_db.select(
      _db.userStat,
    )..where((t) => t.id.equals(entry.id))).getSingle();
  }
}

final statRepositoryProvider = Provider<StatRepository>(
  (ref) => StatRepository(ref.read(appDataBaseProvider)),
);

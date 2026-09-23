import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';
import 'package:tenkai/core/providers.dart';

class FearRepository {
  FearRepository(this._db);
  final AppDatabase _db;

  Future<UserFearData> addFear(UserFearCompanion entry) =>
      _db.userDao.addUserFear(entry);

  Future<List<UserFearData>> get allUserFears => _db.userDao.allUserFears;
}

final fearRepositoryProvider = Provider<FearRepository>(
  (ref) => FearRepository(ref.read(appDataBaseProvider)),
);

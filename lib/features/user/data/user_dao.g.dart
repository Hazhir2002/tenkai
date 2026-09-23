// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dao.dart';

// ignore_for_file: type=lint
mixin _$UserDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserStatTable get userStat => attachedDatabase.userStat;
  $UserFearTable get userFear => attachedDatabase.userFear;
  UserDaoManager get managers => UserDaoManager(this);
}

class UserDaoManager {
  final _$UserDaoMixin _db;
  UserDaoManager(this._db);
  $$UserStatTableTableManager get userStat =>
      $$UserStatTableTableManager(_db.attachedDatabase, _db.userStat);
  $$UserFearTableTableManager get userFear =>
      $$UserFearTableTableManager(_db.attachedDatabase, _db.userFear);
}

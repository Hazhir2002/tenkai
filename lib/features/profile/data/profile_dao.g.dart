// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dao.dart';

// ignore_for_file: type=lint
mixin _$ProfileDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserStatTable get userStat => attachedDatabase.userStat;
  ProfileDaoManager get managers => ProfileDaoManager(this);
}

class ProfileDaoManager {
  final _$ProfileDaoMixin _db;
  ProfileDaoManager(this._db);
  $$UserStatTableTableManager get userStat =>
      $$UserStatTableTableManager(_db.attachedDatabase, _db.userStat);
}

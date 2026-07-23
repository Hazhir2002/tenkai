import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tenkai/core/database.dart';

final appDataBaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

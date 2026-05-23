import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/database_service.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Isar> database(DatabaseRef ref) async {
  final isar = await DatabaseService.instance;
  ref.onDispose(() => DatabaseService.close());
  return isar;
}

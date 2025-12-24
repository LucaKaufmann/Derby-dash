import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/models.dart';

class DatabaseService {
  static Isar? _isar;

  static Future<Isar> get instance async {
    if (_isar != null) return _isar!;
    _isar = await _initDb();
    return _isar!;
  }

  static Future<Isar> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [CarSchema, TournamentSchema, RoundSchema, MatchSchema],
      directory: dir.path,
    );
  }

  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}

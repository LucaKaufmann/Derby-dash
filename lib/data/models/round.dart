import 'package:isar/isar.dart';
import 'match.dart';
import 'tournament.dart';

part 'round.g.dart';

@collection
class Round {
  Id id = Isar.autoIncrement;

  late int roundNumber;

  bool isCompleted = false;

  final matches = IsarLinks<Match>();

  @Backlink(to: 'rounds')
  final tournament = IsarLink<Tournament>();
}

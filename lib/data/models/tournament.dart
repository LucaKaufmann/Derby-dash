import 'package:isar/isar.dart';
import 'round.dart';

part 'tournament.g.dart';

enum TournamentStatus {
  setup,
  active,
  completed,
}

enum TournamentType {
  knockout,
  roundRobin,
  doubleElimination,
}

@collection
class Tournament {
  Id id = Isar.autoIncrement;

  late DateTime date;

  @Enumerated(EnumType.name)
  TournamentStatus status = TournamentStatus.setup;

  @Enumerated(EnumType.name)
  late TournamentType type;

  final rounds = IsarLinks<Round>();
}

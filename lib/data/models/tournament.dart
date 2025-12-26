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
  groupKnockout,
}

enum TournamentPhase {
  group,
  knockout,
}

@collection
class Tournament {
  Id id = Isar.autoIncrement;

  late DateTime date;

  @Enumerated(EnumType.name)
  TournamentStatus status = TournamentStatus.setup;

  @Enumerated(EnumType.name)
  late TournamentType type;

  /// For groupKnockout: which phase the tournament is in
  @Enumerated(EnumType.name)
  TournamentPhase phase = TournamentPhase.group;

  /// Number of groups (2, 4, or 8 for 8, 16, 32 cars)
  int? groupCount;

  /// Best-of format for knockout rounds as JSON
  /// Example: {"ro16": 1, "qf": 3, "sf": 5, "gf": 7}
  String? knockoutFormat;

  final rounds = IsarLinks<Round>();
}

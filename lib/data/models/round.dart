import 'package:isar/isar.dart';
import 'match.dart';
import 'tournament.dart';

part 'round.g.dart';

/// Bracket type for tournaments
enum BracketType {
  winners,     // Winner's bracket (also used for single elimination)
  losers,      // Loser's bracket
  grandFinals, // Final match between bracket winners
  // Group stage bracket types for groupKnockout tournaments
  groupA,
  groupB,
  groupC,
  groupD,
  groupE,
  groupF,
  groupG,
  groupH,
  knockout,    // Knockout phase of groupKnockout tournament
}

@collection
class Round {
  Id id = Isar.autoIncrement;

  late int roundNumber;

  bool isCompleted = false;

  final matches = IsarLinks<Match>();

  @Backlink(to: 'rounds')
  final tournament = IsarLink<Tournament>();

  /// Which bracket this round belongs to (for double elimination and groupKnockout)
  @Enumerated(EnumType.name)
  BracketType bracketType = BracketType.winners;

  /// For groupKnockout: which group this round belongs to (0=A, 1=B, etc.)
  int? groupIndex;

  /// For groupKnockout knockout phase: round name ("ro16", "qf", "sf", "gf")
  String? knockoutRoundName;
}

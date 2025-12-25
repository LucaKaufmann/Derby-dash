import 'package:isar/isar.dart';
import 'match.dart';
import 'tournament.dart';

part 'round.g.dart';

/// Bracket type for double elimination tournaments
enum BracketType {
  winners,     // Winner's bracket (also used for single elimination)
  losers,      // Loser's bracket
  grandFinals, // Final match between bracket winners
}

@collection
class Round {
  Id id = Isar.autoIncrement;

  late int roundNumber;

  bool isCompleted = false;

  final matches = IsarLinks<Match>();

  @Backlink(to: 'rounds')
  final tournament = IsarLink<Tournament>();

  /// Which bracket this round belongs to (for double elimination)
  @Enumerated(EnumType.name)
  BracketType bracketType = BracketType.winners;
}

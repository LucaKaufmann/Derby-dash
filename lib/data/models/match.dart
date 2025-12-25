import 'package:isar/isar.dart';
import 'car.dart';
import 'round.dart';

part 'match.g.dart';

@collection
class Match {
  Id id = Isar.autoIncrement;

  final carA = IsarLink<Car>();

  final carB = IsarLink<Car>(); // Nullable for bye matches

  final winner = IsarLink<Car>(); // Nullable until match completed

  bool isBye = false;

  @Backlink(to: 'matches')
  final round = IsarLink<Round>();

  /// Position within the round (0-indexed, used for bracket routing)
  int matchPosition = 0;

  /// For double elimination: ID of the loser's bracket match where loser goes
  /// Null for loser's bracket matches (losers are eliminated)
  int? loserDestinationMatchId;
}

import 'package:isar/isar.dart';
import 'car.dart';
import 'round.dart';

part 'match.g.dart';

@collection
class Match {
  Id id = Isar.autoIncrement;

  final carA = IsarLink<Car>();

  final carB = IsarLink<Car>();

  final winner = IsarLink<Car>(); // Nullable until match completed

  @Backlink(to: 'matches')
  final round = IsarLink<Round>();

  /// Position within the round (0-indexed, used for bracket routing)
  int matchPosition = 0;

  /// For double elimination: ID of the loser's bracket match where loser goes
  /// Null for loser's bracket matches (losers are eliminated)
  int? loserDestinationMatchId;

  /// For Best-of-X series: number of games in the series (1, 3, 5, or 7)
  int seriesLength = 1;

  /// For Best-of-X series: games won by carA
  int carASeriesWins = 0;

  /// For Best-of-X series: games won by carB
  int carBSeriesWins = 0;

  /// Check if series is complete (one car has reached winsNeeded)
  @ignore
  bool get isSeriesComplete {
    if (seriesLength == 1) return winner.value != null;
    final winsNeeded = (seriesLength + 1) ~/ 2;
    return carASeriesWins >= winsNeeded || carBSeriesWins >= winsNeeded;
  }

  /// Get the number of wins needed to win the series
  @ignore
  int get winsNeeded => (seriesLength + 1) ~/ 2;
}

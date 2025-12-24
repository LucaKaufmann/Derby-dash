import 'package:isar/isar.dart';
import '../data/models/models.dart';

class TournamentService {
  final Isar _isar;

  TournamentService(this._isar);

  /// Create a new tournament with the given cars
  Future<int> createTournament({
    required List<int> carIds,
    required TournamentType type,
  }) async {
    // Get and shuffle cars
    final cars = <Car>[];
    for (final id in carIds) {
      final car = await _isar.cars.get(id);
      if (car != null) {
        cars.add(car);
      }
    }
    cars.shuffle();

    // Create tournament
    final tournament = Tournament()
      ..date = DateTime.now()
      ..type = type
      ..status = TournamentStatus.active;

    await _isar.writeTxn(() async {
      await _isar.tournaments.put(tournament);
    });

    // Create first round based on type
    if (type == TournamentType.knockout) {
      await _createKnockoutRound(tournament, cars, 1);
    } else {
      await _createRoundRobinRounds(tournament, cars);
    }

    return tournament.id;
  }

  /// Create a knockout round with the given cars
  Future<void> _createKnockoutRound(
    Tournament tournament,
    List<Car> cars,
    int roundNumber,
  ) async {
    final round = Round()..roundNumber = roundNumber;

    await _isar.writeTxn(() async {
      await _isar.rounds.put(round);
      tournament.rounds.add(round);
      await tournament.rounds.save();
    });

    // Create matches - pair cars, handle odd numbers with bye
    final matches = <Match>[];
    for (int i = 0; i < cars.length; i += 2) {
      final match = Match();
      match.carA.value = cars[i];

      if (i + 1 < cars.length) {
        match.carB.value = cars[i + 1];
        match.isBye = false;
      } else {
        // Bye match - car advances automatically
        match.isBye = true;
        match.winner.value = cars[i];
      }

      matches.add(match);
    }

    await _isar.writeTxn(() async {
      for (final match in matches) {
        await _isar.matchs.put(match);
        await match.carA.save();
        await match.carB.save();
        await match.winner.save();
        round.matches.add(match);
      }
      await round.matches.save();
    });
  }

  /// Create all round robin rounds
  Future<void> _createRoundRobinRounds(
    Tournament tournament,
    List<Car> cars,
  ) async {
    // Generate all unique pairings
    final allMatches = <(Car, Car)>[];
    for (int i = 0; i < cars.length; i++) {
      for (int j = i + 1; j < cars.length; j++) {
        allMatches.add((cars[i], cars[j]));
      }
    }
    allMatches.shuffle();

    // Create a single round with all matches
    final round = Round()
      ..roundNumber = 1
      ..isCompleted = false;

    await _isar.writeTxn(() async {
      await _isar.rounds.put(round);
      tournament.rounds.add(round);
      await tournament.rounds.save();

      for (final (carA, carB) in allMatches) {
        final match = Match()..isBye = false;
        match.carA.value = carA;
        match.carB.value = carB;

        await _isar.matchs.put(match);
        await match.carA.save();
        await match.carB.save();
        round.matches.add(match);
      }
      await round.matches.save();
    });
  }

  /// Complete a match and set the winner
  Future<void> completeMatch(int matchId, int winnerId) async {
    final match = await _isar.matchs.get(matchId);
    if (match == null) return;

    final winner = await _isar.cars.get(winnerId);
    if (winner == null) return;

    await _isar.writeTxn(() async {
      match.winner.value = winner;
      await _isar.matchs.put(match);
      await match.winner.save();
    });

    // Check if round is complete and generate next round if needed
    await _checkRoundCompletion(matchId);
  }

  /// Clear the winner from a match (undo)
  Future<void> undoMatch(int matchId) async {
    final match = await _isar.matchs.get(matchId);
    if (match == null || match.isBye) return;

    await _isar.writeTxn(() async {
      match.winner.value = null;
      await _isar.matchs.put(match);
      await match.winner.save();
    });
  }

  /// Check if the current round is complete and generate next round
  Future<void> _checkRoundCompletion(int matchId) async {
    // Get the match and its round
    final match = await _isar.matchs.get(matchId);
    if (match == null) return;

    await match.round.load();
    final round = match.round.value;
    if (round == null) return;

    await round.matches.load();
    final allMatches = round.matches.toList();

    // Check if all matches have winners
    bool allComplete = true;
    for (final m in allMatches) {
      await m.winner.load();
      if (m.winner.value == null) {
        allComplete = false;
        break;
      }
    }

    if (!allComplete) return;

    // Mark round as complete
    await _isar.writeTxn(() async {
      round.isCompleted = true;
      await _isar.rounds.put(round);
    });

    // Get tournament
    await round.tournament.load();
    final tournament = round.tournament.value;
    if (tournament == null) return;

    // For knockout tournaments, generate next round
    if (tournament.type == TournamentType.knockout) {
      // Collect winners
      final winners = <Car>[];
      for (final m in allMatches) {
        await m.winner.load();
        if (m.winner.value != null) {
          winners.add(m.winner.value!);
        }
      }

      if (winners.length > 1) {
        // Create next round
        await _createKnockoutRound(tournament, winners, round.roundNumber + 1);
      } else {
        // Tournament complete
        await _isar.writeTxn(() async {
          tournament.status = TournamentStatus.completed;
          await _isar.tournaments.put(tournament);
        });
      }
    } else {
      // Round robin - tournament complete when all matches done
      await _isar.writeTxn(() async {
        tournament.status = TournamentStatus.completed;
        await _isar.tournaments.put(tournament);
      });
    }
  }

  /// Get tournament by ID
  Future<Tournament?> getTournament(int id) async {
    return await _isar.tournaments.get(id);
  }

  /// Get all rounds for a tournament
  Future<List<Round>> getRounds(int tournamentId) async {
    final tournament = await _isar.tournaments.get(tournamentId);
    if (tournament == null) return [];

    await tournament.rounds.load();
    final rounds = tournament.rounds.toList();
    rounds.sort((a, b) => a.roundNumber.compareTo(b.roundNumber));
    return rounds;
  }

  /// Get all matches for a round
  Future<List<Match>> getMatches(int roundId) async {
    final round = await _isar.rounds.get(roundId);
    if (round == null) return [];

    await round.matches.load();
    return round.matches.toList();
  }

  /// Get the current (incomplete) round for a tournament
  Future<Round?> getCurrentRound(int tournamentId) async {
    final rounds = await getRounds(tournamentId);
    for (final round in rounds) {
      if (!round.isCompleted) {
        return round;
      }
    }
    return rounds.isNotEmpty ? rounds.last : null;
  }

  /// Get the next incomplete match in a tournament
  Future<Match?> getNextMatch(int tournamentId) async {
    final currentRound = await getCurrentRound(tournamentId);
    if (currentRound == null) return null;

    final matches = await getMatches(currentRound.id);
    for (final match in matches) {
      await match.winner.load();
      if (match.winner.value == null && !match.isBye) {
        return match;
      }
    }
    return null;
  }

  /// Get match by ID with cars loaded
  Future<Match?> getMatch(int matchId) async {
    final match = await _isar.matchs.get(matchId);
    if (match == null) return null;

    await match.carA.load();
    await match.carB.load();
    await match.winner.load();
    return match;
  }

  /// Get tournament winner
  Future<Car?> getTournamentWinner(int tournamentId) async {
    final tournament = await getTournament(tournamentId);
    if (tournament == null ||
        tournament.status != TournamentStatus.completed) {
      return null;
    }

    if (tournament.type == TournamentType.knockout) {
      // Winner is the winner of the final match
      final rounds = await getRounds(tournamentId);
      if (rounds.isEmpty) return null;

      final finalRound = rounds.last;
      final matches = await getMatches(finalRound.id);
      if (matches.isEmpty) return null;

      await matches.first.winner.load();
      return matches.first.winner.value;
    } else {
      // Round robin - calculate winner by most wins
      final rounds = await getRounds(tournamentId);
      if (rounds.isEmpty) return null;

      final winCounts = <int, int>{};
      for (final round in rounds) {
        final matches = await getMatches(round.id);
        for (final match in matches) {
          await match.winner.load();
          if (match.winner.value != null) {
            final winnerId = match.winner.value!.id;
            winCounts[winnerId] = (winCounts[winnerId] ?? 0) + 1;
          }
        }
      }

      if (winCounts.isEmpty) return null;

      final sortedEntries = winCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return await _isar.cars.get(sortedEntries.first.key);
    }
  }

  /// Get active tournaments
  Future<List<Tournament>> getActiveTournaments() async {
    return await _isar.tournaments
        .filter()
        .statusEqualTo(TournamentStatus.active)
        .findAll();
  }
}

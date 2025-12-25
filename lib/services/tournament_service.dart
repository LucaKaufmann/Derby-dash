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
    } else if (type == TournamentType.doubleElimination) {
      await _createDoubleEliminationBrackets(tournament, cars);
    } else {
      await _createRoundRobinRounds(tournament, cars);
    }

    return tournament.id;
  }

  /// Create all brackets for a double elimination tournament
  Future<void> _createDoubleEliminationBrackets(
    Tournament tournament,
    List<Car> cars,
  ) async {
    // Create winner's bracket first round (same as knockout)
    await _createKnockoutRound(tournament, cars, 1, BracketType.winners);

    // Loser's bracket and subsequent winner's bracket rounds are created
    // dynamically as matches complete to properly route losers
  }

  /// Create a knockout round with the given cars
  Future<void> _createKnockoutRound(
    Tournament tournament,
    List<Car> cars,
    int roundNumber, [
    BracketType bracketType = BracketType.winners,
  ]) async {
    final round = Round()
      ..roundNumber = roundNumber
      ..bracketType = bracketType;

    await _isar.writeTxn(() async {
      await _isar.rounds.put(round);
      tournament.rounds.add(round);
      await tournament.rounds.save();
    });

    // Create matches - pair cars, handle odd numbers with bye
    final matches = <Match>[];
    for (int i = 0; i < cars.length; i += 2) {
      final match = Match()..matchPosition = i ~/ 2;
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

    // Handle based on tournament type
    if (tournament.type == TournamentType.knockout) {
      await _handleKnockoutRoundComplete(tournament, round, allMatches);
    } else if (tournament.type == TournamentType.doubleElimination) {
      await _handleDoubleEliminationRoundComplete(tournament, round, allMatches);
    } else {
      // Round robin - tournament complete when all matches done
      await _isar.writeTxn(() async {
        tournament.status = TournamentStatus.completed;
        await _isar.tournaments.put(tournament);
      });
    }
  }

  /// Handle knockout round completion
  Future<void> _handleKnockoutRoundComplete(
    Tournament tournament,
    Round round,
    List<Match> allMatches,
  ) async {
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
  }

  /// Handle double elimination round completion
  Future<void> _handleDoubleEliminationRoundComplete(
    Tournament tournament,
    Round round,
    List<Match> allMatches,
  ) async {
    // Collect winners and losers
    final winners = <Car>[];
    final losers = <Car>[];

    for (final m in allMatches) {
      await m.winner.load();
      await m.carA.load();
      await m.carB.load();

      if (m.winner.value != null) {
        winners.add(m.winner.value!);

        // Determine loser (if not a bye)
        if (!m.isBye && m.carA.value != null && m.carB.value != null) {
          final loser = m.winner.value!.id == m.carA.value!.id
              ? m.carB.value!
              : m.carA.value!;
          losers.add(loser);
        }
      }
    }

    if (round.bracketType == BracketType.winners) {
      await _handleWinnersBracketRoundComplete(tournament, round, winners, losers);
    } else if (round.bracketType == BracketType.losers) {
      await _handleLosersBracketRoundComplete(tournament, round, winners);
    } else if (round.bracketType == BracketType.grandFinals) {
      await _handleGrandFinalsComplete(tournament, round, allMatches);
    }
  }

  /// Handle grand finals completion with bracket reset logic
  Future<void> _handleGrandFinalsComplete(
    Tournament tournament,
    Round round,
    List<Match> allMatches,
  ) async {
    if (allMatches.isEmpty) return;

    final match = allMatches.first;
    await match.winner.load();
    await match.carA.load();
    await match.carB.load();

    final winner = match.winner.value;
    final winnersBracketChampion = match.carA.value; // Always carA in grand finals
    final losersBracketChampion = match.carB.value; // Always carB in grand finals

    if (winner == null || winnersBracketChampion == null || losersBracketChampion == null) {
      return;
    }

    // Check if this is round 1 or round 2 of grand finals
    if (round.roundNumber == 1 && winner.id == losersBracketChampion.id) {
      // Losers bracket champion won round 1 - bracket reset!
      // Create round 2 of grand finals (same matchup)
      await _createGrandFinalsRound2(tournament, winnersBracketChampion, losersBracketChampion);
    } else {
      // Either winners bracket champion won, or this is round 2
      // Tournament is complete
      await _isar.writeTxn(() async {
        tournament.status = TournamentStatus.completed;
        await _isar.tournaments.put(tournament);
      });
    }
  }

  /// Create round 2 of grand finals (bracket reset)
  Future<void> _createGrandFinalsRound2(
    Tournament tournament,
    Car winnersBracketChampion,
    Car losersBracketChampion,
  ) async {
    final round = Round()
      ..roundNumber = 2
      ..bracketType = BracketType.grandFinals;

    final match = Match()
      ..matchPosition = 0
      ..isBye = false;
    // Keep same order: carA = winners bracket, carB = losers bracket
    match.carA.value = winnersBracketChampion;
    match.carB.value = losersBracketChampion;

    await _isar.writeTxn(() async {
      await _isar.rounds.put(round);
      tournament.rounds.add(round);
      await tournament.rounds.save();

      await _isar.matchs.put(match);
      await match.carA.save();
      await match.carB.save();
      round.matches.add(match);
      await round.matches.save();
    });
  }

  /// Handle winner's bracket round completion in double elimination
  Future<void> _handleWinnersBracketRoundComplete(
    Tournament tournament,
    Round completedRound,
    List<Car> winners,
    List<Car> losers,
  ) async {
    // Get all existing rounds to determine state
    await tournament.rounds.load();
    final allRounds = tournament.rounds.toList();

    final losersRounds = allRounds
        .where((r) => r.bracketType == BracketType.losers)
        .toList()
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

    // Calculate next loser's bracket round number
    final nextLosersRoundNum = losersRounds.isEmpty ? 1 : losersRounds.last.roundNumber + 1;

    if (winners.length > 1) {
      // Create next winner's bracket round
      await _createKnockoutRound(
        tournament,
        winners,
        completedRound.roundNumber + 1,
        BracketType.winners,
      );

      // Create loser's bracket round with losers from this round
      if (losers.isNotEmpty) {
        await _createKnockoutRound(
          tournament,
          losers,
          nextLosersRoundNum,
          BracketType.losers,
        );
      }
    } else if (winners.length == 1) {
      // Winner's bracket complete - winner goes to grand finals
      // But first, losers from this final match go to loser's bracket

      if (losers.isNotEmpty) {
        // Check if there's an active loser's bracket
        final incompleteLosersRounds = losersRounds.where((r) => !r.isCompleted).toList();

        if (incompleteLosersRounds.isNotEmpty) {
          // Add loser to existing loser's bracket round or create new one
          // For simplicity, create a new round with just this loser
          // They'll play against the loser's bracket survivor
          await _createKnockoutRound(
            tournament,
            losers,
            nextLosersRoundNum,
            BracketType.losers,
          );
        } else if (losersRounds.isNotEmpty) {
          // Loser's bracket also complete - create grand finals immediately
          // Get loser's bracket winner
          final lastLosersRound = losersRounds.last;
          await lastLosersRound.matches.load();
          final losersMatches = lastLosersRound.matches.toList();

          if (losersMatches.isNotEmpty) {
            await losersMatches.first.winner.load();
            final losersBracketWinner = losersMatches.first.winner.value;

            if (losersBracketWinner != null) {
              // Create grand finals
              await _createKnockoutRound(
                tournament,
                [winners.first, losersBracketWinner],
                1,
                BracketType.grandFinals,
              );
            }
          }
        } else {
          // No loser's bracket yet - create it with the loser
          await _createKnockoutRound(
            tournament,
            losers,
            1,
            BracketType.losers,
          );
        }
      }

      // Check if we can create grand finals
      await _checkAndCreateGrandFinals(tournament);
    }
  }

  /// Handle loser's bracket round completion in double elimination
  Future<void> _handleLosersBracketRoundComplete(
    Tournament tournament,
    Round completedRound,
    List<Car> winners,
  ) async {
    if (winners.length > 1) {
      // Create next loser's bracket round
      await _createKnockoutRound(
        tournament,
        winners,
        completedRound.roundNumber + 1,
        BracketType.losers,
      );
    } else if (winners.length == 1) {
      // Loser's bracket complete - check if grand finals can be created
      await _checkAndCreateGrandFinals(tournament);
    }
  }

  /// Check if both brackets are complete and create grand finals
  Future<void> _checkAndCreateGrandFinals(Tournament tournament) async {
    await tournament.rounds.load();
    final allRounds = tournament.rounds.toList();

    // Check for existing grand finals
    final grandFinalsRounds = allRounds
        .where((r) => r.bracketType == BracketType.grandFinals)
        .toList();
    if (grandFinalsRounds.isNotEmpty) return; // Already created

    // Get winner's bracket rounds
    final winnersRounds = allRounds
        .where((r) => r.bracketType == BracketType.winners)
        .toList()
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

    // Get loser's bracket rounds
    final losersRounds = allRounds
        .where((r) => r.bracketType == BracketType.losers)
        .toList()
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

    if (winnersRounds.isEmpty || losersRounds.isEmpty) return;

    // Check if winner's bracket is complete
    final lastWinnersRound = winnersRounds.last;
    if (!lastWinnersRound.isCompleted) return;

    await lastWinnersRound.matches.load();
    final winnersMatches = lastWinnersRound.matches.toList();
    if (winnersMatches.isEmpty) return;

    await winnersMatches.first.winner.load();
    final winnersBracketChampion = winnersMatches.first.winner.value;
    if (winnersBracketChampion == null) return;

    // Check if loser's bracket is complete (only one car remaining)
    final lastLosersRound = losersRounds.last;
    if (!lastLosersRound.isCompleted) return;

    await lastLosersRound.matches.load();
    final losersMatches = lastLosersRound.matches.toList();
    if (losersMatches.isEmpty) return;

    await losersMatches.first.winner.load();
    final losersBracketChampion = losersMatches.first.winner.value;
    if (losersBracketChampion == null) return;

    // Both brackets complete - create grand finals
    await _createKnockoutRound(
      tournament,
      [winnersBracketChampion, losersBracketChampion],
      1,
      BracketType.grandFinals,
    );
  }

  /// Get rounds by bracket type for a tournament
  Future<List<Round>> getRoundsByBracket(
    int tournamentId,
    BracketType bracketType,
  ) async {
    final tournament = await _isar.tournaments.get(tournamentId);
    if (tournament == null) return [];

    await tournament.rounds.load();
    final rounds = tournament.rounds
        .where((r) => r.bracketType == bracketType)
        .toList()
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));
    return rounds;
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

    // For double elimination, sort by bracket type then round number
    // Order: Winners -> Losers -> Grand Finals
    if (tournament.type == TournamentType.doubleElimination) {
      rounds.sort((a, b) {
        // First sort by bracket type
        final bracketOrder = _bracketTypeOrder(a.bracketType)
            .compareTo(_bracketTypeOrder(b.bracketType));
        if (bracketOrder != 0) return bracketOrder;
        // Then by round number within the bracket
        return a.roundNumber.compareTo(b.roundNumber);
      });
    } else {
      rounds.sort((a, b) => a.roundNumber.compareTo(b.roundNumber));
    }
    return rounds;
  }

  /// Get sort order for bracket types
  int _bracketTypeOrder(BracketType type) {
    switch (type) {
      case BracketType.winners:
        return 0;
      case BracketType.losers:
        return 1;
      case BracketType.grandFinals:
        return 2;
    }
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

  /// Get completed tournaments ordered by date (newest first)
  Future<List<Tournament>> getCompletedTournaments() async {
    return await _isar.tournaments
        .filter()
        .statusEqualTo(TournamentStatus.completed)
        .sortByDateDesc()
        .findAll();
  }

  /// Get participant count for a tournament
  Future<int> getParticipantCount(int tournamentId) async {
    final rounds = await getRounds(tournamentId);
    if (rounds.isEmpty) return 0;

    final firstRound = rounds.first;
    final matches = await getMatches(firstRound.id);

    final carIds = <int>{};
    for (final match in matches) {
      await match.carA.load();
      await match.carB.load();
      if (match.carA.value != null) carIds.add(match.carA.value!.id);
      if (match.carB.value != null) carIds.add(match.carB.value!.id);
    }
    return carIds.length;
  }
}

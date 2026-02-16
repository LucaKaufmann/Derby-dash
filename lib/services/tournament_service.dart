import 'dart:convert';
import 'dart:math';
import 'package:isar/isar.dart';
import '../data/models/models.dart';

class TournamentService {
  final Isar _isar;
  final Random _random;

  TournamentService(this._isar, {Random? random}) : _random = random ?? Random();

  /// Check if a number is a power of 2 (2, 4, 8, 16, 32, 64, etc.)
  bool _isPowerOfTwo(int n) => n > 0 && (n & (n - 1)) == 0;

  /// Check if a number is valid for groupKnockout (8, 16, or 32)
  bool _isValidGroupKnockoutCount(int n) => n == 8 || n == 16 || n == 32;

  /// Get default knockout format based on car count
  Map<String, int> _defaultKnockoutFormat(int carCount) {
    return {
      'ro16': 1,
      'qf': 3,
      'sf': 5,
      'gf': 7,
    };
  }

  /// Create a new tournament with the given cars
  Future<int> createTournament({
    required List<int> carIds,
    required TournamentType type,
    Map<String, int>? knockoutFormat,
  }) async {
    // Validate car count
    if (type == TournamentType.knockout || type == TournamentType.doubleElimination) {
      if (carIds.length < 2) {
        throw ArgumentError('Tournament requires at least 2 cars');
      }
      if (!_isPowerOfTwo(carIds.length)) {
        throw ArgumentError('Knockout and double elimination tournaments require a power of 2 cars (4, 8, 16, 32, etc.)');
      }
      if (type == TournamentType.doubleElimination && carIds.length < 4) {
        throw ArgumentError('Double elimination requires at least 4 cars');
      }
    }

    // Validate groupKnockout car count
    if (type == TournamentType.groupKnockout) {
      if (!_isValidGroupKnockoutCount(carIds.length)) {
        throw ArgumentError('Group + Knockout requires exactly 8, 16, or 32 cars');
      }
    }

    // Get and shuffle cars
    final cars = <Car>[];
    for (final id in carIds) {
      final car = await _isar.cars.get(id);
      if (car != null) {
        cars.add(car);
      }
    }
    cars.shuffle(_random);

    // Create tournament
    final tournament = Tournament()
      ..date = DateTime.now()
      ..type = type
      ..status = TournamentStatus.active;

    // Set groupKnockout specific fields
    if (type == TournamentType.groupKnockout) {
      tournament
        ..phase = TournamentPhase.group
        ..groupCount = cars.length ~/ 4
        ..knockoutFormat = jsonEncode(knockoutFormat ?? _defaultKnockoutFormat(cars.length));
    }

    await _isar.writeTxn(() async {
      await _isar.tournaments.put(tournament);
    });

    // Create first round based on type
    if (type == TournamentType.knockout) {
      await _createKnockoutRound(tournament, cars, 1);
    } else if (type == TournamentType.doubleElimination) {
      await _createDoubleEliminationBrackets(tournament, cars);
    } else if (type == TournamentType.groupKnockout) {
      await _createGroupStage(tournament, cars);
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

    // Create matches - pair cars (even count guaranteed by validation)
    final matches = <Match>[];
    for (int i = 0; i < cars.length; i += 2) {
      final match = Match()..matchPosition = i ~/ 2;
      match.carA.value = cars[i];
      match.carB.value = cars[i + 1];
      matches.add(match);
    }

    await _isar.writeTxn(() async {
      for (final match in matches) {
        await _isar.matchs.put(match);
        await match.carA.save();
        await match.carB.save();
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
    allMatches.shuffle(_random);

    // Create a single round with all matches
    final round = Round()
      ..roundNumber = 1
      ..isCompleted = false;

    await _isar.writeTxn(() async {
      await _isar.rounds.put(round);
      tournament.rounds.add(round);
      await tournament.rounds.save();

      for (final (carA, carB) in allMatches) {
        final match = Match();
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

  /// Create group stage for groupKnockout tournament
  Future<void> _createGroupStage(Tournament tournament, List<Car> cars) async {
    final groupCount = tournament.groupCount ?? (cars.length ~/ 4);
    const carsPerGroup = 4;

    // Distribute shuffled cars to groups
    for (int g = 0; g < groupCount; g++) {
      final groupCars = cars.sublist(g * carsPerGroup, (g + 1) * carsPerGroup);
      await _createGroupRoundRobin(tournament, groupCars, g);
    }
  }

  /// Create round-robin matches for a single group
  Future<void> _createGroupRoundRobin(
    Tournament tournament,
    List<Car> cars,
    int groupIndex,
  ) async {
    // Determine bracket type based on group index
    final bracketType = BracketType.values[BracketType.groupA.index + groupIndex];

    // Create round for this group (single round with all 6 matches)
    final round = Round()
      ..roundNumber = 1
      ..bracketType = bracketType
      ..groupIndex = groupIndex
      ..isCompleted = false;

    await _isar.writeTxn(() async {
      await _isar.rounds.put(round);
      tournament.rounds.add(round);
      await tournament.rounds.save();

      // Generate all pairings within the group (4 cars = 6 matches)
      int position = 0;
      for (int i = 0; i < cars.length; i++) {
        for (int j = i + 1; j < cars.length; j++) {
          final match = Match()
            ..matchPosition = position++
            ..seriesLength = 1; // Group stage is always Best-of-1
          match.carA.value = cars[i];
          match.carB.value = cars[j];

          await _isar.matchs.put(match);
          await match.carA.save();
          await match.carB.save();
          round.matches.add(match);
        }
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
    if (match == null) return;

    await _isar.writeTxn(() async {
      match.winner.value = null;
      await _isar.matchs.put(match);
      await match.winner.save();
    });
  }

  /// Record a single game win in a Best-of-X series
  Future<void> recordSeriesGameWin(int matchId, int winnerId) async {
    final match = await _isar.matchs.get(matchId);
    if (match == null) return;

    await match.carA.load();
    await match.carB.load();

    final isCarAWinner = winnerId == match.carA.value?.id;

    await _isar.writeTxn(() async {
      if (isCarAWinner) {
        match.carASeriesWins += 1;
      } else {
        match.carBSeriesWins += 1;
      }

      // Check if series is complete
      final winsNeeded = match.winsNeeded;
      if (match.carASeriesWins >= winsNeeded) {
        match.winner.value = match.carA.value;
        await match.winner.save();
      } else if (match.carBSeriesWins >= winsNeeded) {
        match.winner.value = match.carB.value;
        await match.winner.save();
      }

      await _isar.matchs.put(match);
    });

    // Only check round completion when series is done
    if (match.isSeriesComplete) {
      await _checkRoundCompletion(matchId);
    }
  }

  /// Undo the last game in a Best-of-X series
  Future<void> undoSeriesGame(int matchId) async {
    final match = await _isar.matchs.get(matchId);
    if (match == null) return;

    // Can't undo if no games played
    if (match.carASeriesWins == 0 && match.carBSeriesWins == 0) return;

    await match.carA.load();
    await match.carB.load();

    await _isar.writeTxn(() async {
      // If winner was set, clear it first
      if (match.winner.value != null) {
        // Determine which car won and decrement their wins
        if (match.winner.value?.id == match.carA.value?.id) {
          match.carASeriesWins = (match.carASeriesWins - 1).clamp(0, 999);
        } else {
          match.carBSeriesWins = (match.carBSeriesWins - 1).clamp(0, 999);
        }
        match.winner.value = null;
        await match.winner.save();
      } else {
        // No winner set, decrement the most recent (higher score wins last game)
        // This is a heuristic - we assume last game went to leading car
        if (match.carASeriesWins > match.carBSeriesWins) {
          match.carASeriesWins -= 1;
        } else if (match.carBSeriesWins > match.carASeriesWins) {
          match.carBSeriesWins -= 1;
        } else if (match.carASeriesWins > 0) {
          // Tied, just decrement carA (arbitrary)
          match.carASeriesWins -= 1;
        }
      }

      await _isar.matchs.put(match);
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
    } else if (tournament.type == TournamentType.groupKnockout) {
      await _handleGroupKnockoutRoundComplete(tournament, round, allMatches);
    } else {
      // Round robin - tournament complete when all matches done
      await _isar.writeTxn(() async {
        tournament.status = TournamentStatus.completed;
        await _isar.tournaments.put(tournament);
      });
    }
  }

  /// Handle groupKnockout round completion
  Future<void> _handleGroupKnockoutRoundComplete(
    Tournament tournament,
    Round round,
    List<Match> allMatches,
  ) async {
    // Check if this is a group stage round
    if (round.groupIndex != null) {
      // Group stage round completed, check if all groups are done
      await _checkGroupStageCompletion(tournament);
    } else {
      // This is a knockout phase round
      await _handleKnockoutPhaseRoundComplete(tournament, round, allMatches);
    }
  }

  /// Handle knockout phase round completion for groupKnockout tournaments
  Future<void> _handleKnockoutPhaseRoundComplete(
    Tournament tournament,
    Round round,
    List<Match> allMatches,
  ) async {
    // Collect series winners
    final winners = <Car>[];
    for (final m in allMatches) {
      await m.winner.load();
      if (m.winner.value != null) {
        winners.add(m.winner.value!);
      }
    }

    if (winners.length <= 1) {
      // Tournament complete - we have a champion
      await _isar.writeTxn(() async {
        tournament.status = TournamentStatus.completed;
        await _isar.tournaments.put(tournament);
      });
      return;
    }

    // Create next knockout round
    final nextRoundName = _getNextKnockoutRound(round.knockoutRoundName ?? 'qf');
    final format = jsonDecode(tournament.knockoutFormat ?? '{}') as Map<String, dynamic>;
    final seriesLength = (format[nextRoundName] as int?) ?? 1;

    final nextRound = Round()
      ..roundNumber = round.roundNumber + 1
      ..bracketType = BracketType.knockout
      ..knockoutRoundName = nextRoundName
      ..isCompleted = false;

    await _isar.writeTxn(() async {
      await _isar.rounds.put(nextRound);
      tournament.rounds.add(nextRound);
      await tournament.rounds.save();

      // Pair winners
      for (int i = 0; i < winners.length; i += 2) {
        final match = Match()
          ..matchPosition = i ~/ 2
          ..seriesLength = seriesLength;
        match.carA.value = winners[i];
        match.carB.value = winners[i + 1];

        await _isar.matchs.put(match);
        await match.carA.save();
        await match.carB.save();
        nextRound.matches.add(match);
      }
      await nextRound.matches.save();
    });
  }

  /// Get next knockout round name
  String _getNextKnockoutRound(String current) {
    switch (current) {
      case 'ro16':
        return 'qf';
      case 'qf':
        return 'sf';
      case 'sf':
        return 'gf';
      default:
        return 'gf';
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

        // Determine loser
        if (m.carA.value != null && m.carB.value != null) {
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

    final match = Match()..matchPosition = 0;
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
  /// Winners bracket runs to completion first, then losers bracket starts
  Future<void> _handleWinnersBracketRoundComplete(
    Tournament tournament,
    Round completedRound,
    List<Car> winners,
    List<Car> losers,
  ) async {
    if (winners.length > 1) {
      // Create next winners bracket round
      await _createKnockoutRound(
        tournament,
        winners,
        completedRound.roundNumber + 1,
        BracketType.winners,
      );
    } else {
      // Winners bracket complete! Start losers bracket with WR1 losers
      await _initializeLosersBracket(tournament);
    }
  }

  /// Initialize the losers bracket with WR1 losers after winners bracket completes
  Future<void> _initializeLosersBracket(Tournament tournament) async {
    await tournament.rounds.load();
    final winnersRounds = tournament.rounds
        .where((r) => r.bracketType == BracketType.winners)
        .toList()
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

    if (winnersRounds.isEmpty) return;

    // Get WR1 losers
    final wr1 = winnersRounds.first;
    await wr1.matches.load();

    final wr1Losers = <Car>[];
    for (final match in wr1.matches) {
      await match.winner.load();
      await match.carA.load();
      await match.carB.load();
      if (match.winner.value != null &&
          match.carA.value != null &&
          match.carB.value != null) {
        final loser = match.winner.value!.id == match.carA.value!.id
            ? match.carB.value!
            : match.carA.value!;
        wr1Losers.add(loser);
      }
    }

    if (wr1Losers.length >= 2) {
      await _createKnockoutRound(tournament, wr1Losers, 1, BracketType.losers);
    } else if (wr1Losers.length == 1) {
      // Edge case: only 1 loser from WR1, check for grand finals
      await _checkAndCreateGrandFinals(tournament);
    }
  }

  /// Handle loser's bracket round completion in double elimination
  /// After each LR: check for pending WR losers to incorporate (cross-bracket)
  /// or create internal round if survivors > 1
  Future<void> _handleLosersBracketRoundComplete(
    Tournament tournament,
    Round completedRound,
    List<Car> survivors,
  ) async {
    if (survivors.isEmpty) return;

    // Get next batch of pending WR losers (those not yet in any LR match)
    final pendingLosers = await _getNextPendingWinnersLosers(tournament);

    if (pendingLosers.isNotEmpty && pendingLosers.length == survivors.length) {
      // Cross-bracket: pair survivors with pending losers
      final participants = <Car>[];
      for (int i = 0; i < survivors.length; i++) {
        participants.add(survivors[i]);
        participants.add(pendingLosers[i]);
      }
      await _createKnockoutRound(
        tournament,
        participants,
        completedRound.roundNumber + 1,
        BracketType.losers,
      );
    } else if (survivors.length > 1) {
      // Internal round: survivors play each other
      await _createKnockoutRound(
        tournament,
        survivors,
        completedRound.roundNumber + 1,
        BracketType.losers,
      );
    } else {
      // Single survivor and no matching pending losers - check for grand finals
      await _checkAndCreateGrandFinals(tournament);
    }
  }

  /// Get the next batch of WR losers that haven't been incorporated into LB yet
  /// Skips WR1 losers (used to create LR1) and finds the earliest WR whose
  /// losers haven't appeared in any LR match
  Future<List<Car>> _getNextPendingWinnersLosers(Tournament tournament) async {
    await tournament.rounds.load();

    final winnersRounds = tournament.rounds
        .where((r) => r.bracketType == BracketType.winners)
        .toList()
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

    final losersRounds = tournament.rounds
        .where((r) => r.bracketType == BracketType.losers)
        .toList();

    // Collect all car IDs that have appeared in losers bracket matches
    final carsInLosersBracket = <int>{};
    for (final lr in losersRounds) {
      await lr.matches.load();
      for (final match in lr.matches) {
        await match.carA.load();
        await match.carB.load();
        if (match.carA.value != null) {
          carsInLosersBracket.add(match.carA.value!.id);
        }
        if (match.carB.value != null) {
          carsInLosersBracket.add(match.carB.value!.id);
        }
      }
    }

    // Find first WR (after WR1) whose losers haven't been incorporated yet
    // Skip WR1 because its losers are used to create LR1
    for (int i = 1; i < winnersRounds.length; i++) {
      final wr = winnersRounds[i];
      await wr.matches.load();

      final wrLosers = <Car>[];
      for (final match in wr.matches) {
        await match.winner.load();
        await match.carA.load();
        await match.carB.load();
        if (match.winner.value != null &&
            match.carA.value != null &&
            match.carB.value != null) {
          final loser = match.winner.value!.id == match.carA.value!.id
              ? match.carB.value!
              : match.carA.value!;
          wrLosers.add(loser);
        }
      }

      // Check if any of these losers are already in LB
      final anyInLB = wrLosers.any((loser) => carsInLosersBracket.contains(loser.id));
      if (!anyInLB && wrLosers.isNotEmpty) {
        return wrLosers; // First pending batch
      }
    }

    return []; // No pending losers
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

    // For double elimination and groupKnockout, sort by bracket type then round number
    // Double elimination: Winners -> Losers -> Grand Finals
    // GroupKnockout: Group A -> Group B -> ... -> Knockout
    if (tournament.type == TournamentType.doubleElimination ||
        tournament.type == TournamentType.groupKnockout) {
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
      // For groupKnockout: groups come first, then knockout
      case BracketType.groupA:
        return 10;
      case BracketType.groupB:
        return 11;
      case BracketType.groupC:
        return 12;
      case BracketType.groupD:
        return 13;
      case BracketType.groupE:
        return 14;
      case BracketType.groupF:
        return 15;
      case BracketType.groupG:
        return 16;
      case BracketType.groupH:
        return 17;
      case BracketType.knockout:
        return 20;
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
      if (match.winner.value == null) {
        return match;
      }
    }
    return null;
  }

  /// Get match by ID with cars and round loaded
  Future<Match?> getMatch(int matchId) async {
    final match = await _isar.matchs.get(matchId);
    if (match == null) return null;

    await match.carA.load();
    await match.carB.load();
    await match.winner.load();
    await match.round.load();
    return match;
  }

  /// Get tournament winner
  Future<Car?> getTournamentWinner(int tournamentId) async {
    final tournament = await getTournament(tournamentId);
    if (tournament == null ||
        tournament.status != TournamentStatus.completed) {
      return null;
    }

    if (tournament.type == TournamentType.knockout ||
        tournament.type == TournamentType.doubleElimination ||
        tournament.type == TournamentType.groupKnockout) {
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

  /// Delete a tournament and all its rounds and matches
  Future<void> deleteTournament(int tournamentId) async {
    final tournament = await _isar.tournaments.get(tournamentId);
    if (tournament == null) return;

    await tournament.rounds.load();
    final rounds = tournament.rounds.toList();

    // Collect all match IDs to delete
    final matchIds = <int>[];
    for (final round in rounds) {
      await round.matches.load();
      for (final match in round.matches) {
        matchIds.add(match.id);
      }
    }

    // Delete in transaction: matches, rounds, then tournament
    await _isar.writeTxn(() async {
      await _isar.matchs.deleteAll(matchIds);
      await _isar.rounds.deleteAll(rounds.map((r) => r.id).toList());
      await _isar.tournaments.delete(tournamentId);
    });
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

  /// Get standings for a specific group in a groupKnockout tournament
  Future<List<GroupStanding>> getGroupStandings(
    int tournamentId,
    int groupIndex,
  ) async {
    final tournament = await _isar.tournaments.get(tournamentId);
    if (tournament == null) return [];

    await tournament.rounds.load();

    // Find the round for this group
    final groupRound = tournament.rounds.firstWhere(
      (r) => r.groupIndex == groupIndex,
      orElse: () => Round()..id = -1,
    );
    if (groupRound.id == -1) return [];

    await groupRound.matches.load();
    final matches = groupRound.matches.toList();

    // Build stats for each car in the group
    final carStats = <int, _GroupCarStats>{};

    for (final match in matches) {
      await match.carA.load();
      await match.carB.load();
      await match.winner.load();

      final carA = match.carA.value;
      final carB = match.carB.value;
      final winner = match.winner.value;

      if (carA == null || carB == null) continue;

      // Initialize stats if not present
      carStats.putIfAbsent(
        carA.id,
        () => _GroupCarStats(car: carA),
      );
      carStats.putIfAbsent(
        carB.id,
        () => _GroupCarStats(car: carB),
      );

      // Record result if match is complete
      if (winner != null) {
        if (winner.id == carA.id) {
          carStats[carA.id]!.wins++;
          carStats[carB.id]!.losses++;
          carStats[carA.id]!.headToHead[carB.id] = true;
          carStats[carB.id]!.headToHead[carA.id] = false;
        } else {
          carStats[carB.id]!.wins++;
          carStats[carA.id]!.losses++;
          carStats[carB.id]!.headToHead[carA.id] = true;
          carStats[carA.id]!.headToHead[carB.id] = false;
        }
      }
    }

    // Convert to standings and sort
    final standingsList = carStats.values.map((stats) {
      return GroupStanding(
        car: stats.car,
        wins: stats.wins,
        losses: stats.losses,
        points: stats.wins * 3,
        groupIndex: groupIndex,
        seed: 0, // Will be assigned after sorting
        headToHead: Map.from(stats.headToHead),
      );
    }).toList();

    // Sort by points (desc), then by head-to-head if tied
    standingsList.sort((a, b) {
      final pointsCompare = b.points.compareTo(a.points);
      if (pointsCompare != 0) return pointsCompare;

      // Head-to-head tiebreaker
      if (a.headToHead.containsKey(b.car.id)) {
        return a.headToHead[b.car.id]! ? -1 : 1;
      }
      return 0;
    });

    // Assign seeds (1, 2, 3, 4)
    final result = <GroupStanding>[];
    for (int i = 0; i < standingsList.length; i++) {
      result.add(standingsList[i].copyWith(seed: i + 1));
    }

    return result;
  }

  /// Check if group stage is complete and transition to knockout
  Future<void> _checkGroupStageCompletion(Tournament tournament) async {
    if (tournament.type != TournamentType.groupKnockout) return;
    if (tournament.phase != TournamentPhase.group) return;

    await tournament.rounds.load();

    // Get all group rounds
    final groupRounds = tournament.rounds
        .where((r) => r.groupIndex != null)
        .toList();

    // Check if all groups are complete
    final allGroupsComplete = groupRounds.every((r) => r.isCompleted);
    if (!allGroupsComplete) return;

    // Transition to knockout phase
    await _isar.writeTxn(() async {
      tournament.phase = TournamentPhase.knockout;
      await _isar.tournaments.put(tournament);
    });

    // Get top 2 from each group and create knockout bracket
    await _createKnockoutFromGroups(tournament);
  }

  /// Create knockout bracket from group stage results
  Future<void> _createKnockoutFromGroups(Tournament tournament) async {
    final groupCount = tournament.groupCount ?? 2;

    // Collect top 2 from each group
    final qualifiers = <(Car, int, int)>[]; // (car, seed, groupIndex)

    for (int g = 0; g < groupCount; g++) {
      final standings = await getGroupStandings(tournament.id, g);
      if (standings.length >= 2) {
        qualifiers.add((standings[0].car, 1, g)); // Group winner
        qualifiers.add((standings[1].car, 2, g)); // Group runner-up
      }
    }

    // Create cross-seeding pairings
    // Pattern: 1A vs 2B, 1B vs 2A, 1C vs 2D, 1D vs 2C, etc.
    final pairings = <(Car, Car)>[];
    for (int i = 0; i < groupCount; i += 2) {
      if (i + 1 < groupCount) {
        // Find 1st from group i and 2nd from group i+1
        final g1First = qualifiers.firstWhere((q) => q.$2 == 1 && q.$3 == i);
        final g2Second = qualifiers.firstWhere((q) => q.$2 == 2 && q.$3 == i + 1);
        pairings.add((g1First.$1, g2Second.$1));

        // Find 1st from group i+1 and 2nd from group i
        final g2First = qualifiers.firstWhere((q) => q.$2 == 1 && q.$3 == i + 1);
        final g1Second = qualifiers.firstWhere((q) => q.$2 == 2 && q.$3 == i);
        pairings.add((g2First.$1, g1Second.$1));
      }
    }

    // Determine first knockout round name based on qualifier count
    final qualifierCount = pairings.length * 2;
    String roundName;
    if (qualifierCount == 4) {
      roundName = 'sf'; // 8 cars -> 4 qualifiers -> Semifinals
    } else if (qualifierCount == 8) {
      roundName = 'qf'; // 16 cars -> 8 qualifiers -> Quarterfinals
    } else {
      roundName = 'ro16'; // 32 cars -> 16 qualifiers -> Round of 16
    }

    // Get series length from format
    final format = jsonDecode(tournament.knockoutFormat ?? '{}') as Map<String, dynamic>;
    final seriesLength = (format[roundName] as int?) ?? 1;

    // Create knockout round
    final round = Round()
      ..roundNumber = 1
      ..bracketType = BracketType.knockout
      ..knockoutRoundName = roundName
      ..isCompleted = false;

    await _isar.writeTxn(() async {
      await _isar.rounds.put(round);
      tournament.rounds.add(round);
      await tournament.rounds.save();

      for (int i = 0; i < pairings.length; i++) {
        final (carA, carB) = pairings[i];
        final match = Match()
          ..matchPosition = i
          ..seriesLength = seriesLength;
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

  /// Get win/loss stats for all cars in a tournament
  /// Returns a map of carId -> {car, wins, losses}
  /// For knockout tournaments, respects bracket placement:
  /// 1st: Grand finals winner, 2nd: Grand finals loser,
  /// 3rd/4th: Semi-finals losers (by wins, then alphabetically)
  Future<List<TournamentCarStats>> getTournamentStats(int tournamentId) async {
    final tournament = await getTournament(tournamentId);
    final rounds = await getRounds(tournamentId);
    if (rounds.isEmpty) return [];

    final carStats = <int, TournamentCarStats>{};

    // Track placement for knockout tournaments
    int? grandFinalsWinnerId;
    int? grandFinalsLoserId;
    final semiFinalsLoserIds = <int>[];

    for (final round in rounds) {
      final matches = await getMatches(round.id);
      for (final match in matches) {
        await match.carA.load();
        await match.carB.load();
        await match.winner.load();

        final carA = match.carA.value;
        final carB = match.carB.value;
        final winner = match.winner.value;

        // Initialize stats for cars if not present
        if (carA != null && !carStats.containsKey(carA.id)) {
          carStats[carA.id] = TournamentCarStats(car: carA, wins: 0, losses: 0);
        }
        if (carB != null && !carStats.containsKey(carB.id)) {
          carStats[carB.id] = TournamentCarStats(car: carB, wins: 0, losses: 0);
        }

        // Count wins and losses
        if (winner != null && carA != null && carB != null) {
          if (winner.id == carA.id) {
            carStats[carA.id] = carStats[carA.id]!.copyWith(
              wins: carStats[carA.id]!.wins + 1,
            );
            carStats[carB.id] = carStats[carB.id]!.copyWith(
              losses: carStats[carB.id]!.losses + 1,
            );
          } else if (winner.id == carB.id) {
            carStats[carB.id] = carStats[carB.id]!.copyWith(
              wins: carStats[carB.id]!.wins + 1,
            );
            carStats[carA.id] = carStats[carA.id]!.copyWith(
              losses: carStats[carA.id]!.losses + 1,
            );
          }

          // Track knockout placement
          final isKnockoutTournament = tournament?.type == TournamentType.knockout ||
              tournament?.type == TournamentType.groupKnockout;

          if (isKnockoutTournament) {
            // Grand finals
            if (round.knockoutRoundName == 'gf' ||
                round.bracketType == BracketType.grandFinals ||
                (tournament?.type == TournamentType.knockout && round.roundNumber == rounds.length)) {
              grandFinalsWinnerId = winner.id;
              grandFinalsLoserId = winner.id == carA.id ? carB.id : carA.id;
            }
            // Semifinals
            else if (round.knockoutRoundName == 'sf' ||
                (tournament?.type == TournamentType.knockout && round.roundNumber == rounds.length - 1 && rounds.length > 1)) {
              final loserId = winner.id == carA.id ? carB.id : carA.id;
              if (!semiFinalsLoserIds.contains(loserId)) {
                semiFinalsLoserIds.add(loserId);
              }
            }
          }
        }
      }
    }

    // Sort by wins (descending), then by losses (ascending), then by name
    final statsList = carStats.values.toList()
      ..sort((a, b) {
        final winCompare = b.wins.compareTo(a.wins);
        if (winCompare != 0) return winCompare;
        final lossCompare = a.losses.compareTo(b.losses);
        if (lossCompare != 0) return lossCompare;
        return a.car.name.compareTo(b.car.name);
      });

    // For knockout tournaments, apply placement ordering
    final isKnockoutTournament = tournament?.type == TournamentType.knockout ||
        tournament?.type == TournamentType.groupKnockout;

    if (isKnockoutTournament && grandFinalsWinnerId != null) {
      final result = <TournamentCarStats>[];

      // 1st: Grand finals winner
      final gfWinner = statsList.firstWhere((s) => s.car.id == grandFinalsWinnerId);
      result.add(gfWinner);

      // 2nd: Grand finals loser
      if (grandFinalsLoserId != null) {
        final gfLoser = statsList.firstWhere((s) => s.car.id == grandFinalsLoserId);
        result.add(gfLoser);
      }

      // 3rd/4th: Semi-finals losers, ordered by wins then alphabetically
      final sfLosers = statsList
          .where((s) => semiFinalsLoserIds.contains(s.car.id))
          .toList()
        ..sort((a, b) {
          final winCompare = b.wins.compareTo(a.wins);
          if (winCompare != 0) return winCompare;
          return a.car.name.compareTo(b.car.name);
        });
      result.addAll(sfLosers);

      // Rest: ordered by wins, then losses, then name
      final usedIds = {grandFinalsWinnerId, grandFinalsLoserId, ...semiFinalsLoserIds};
      final rest = statsList.where((s) => !usedIds.contains(s.car.id));
      result.addAll(rest);

      return result;
    }

    return statsList;
  }
}

/// Stats for a car in a specific tournament
class TournamentCarStats {
  final Car car;
  final int wins;
  final int losses;

  const TournamentCarStats({
    required this.car,
    required this.wins,
    required this.losses,
  });

  TournamentCarStats copyWith({
    Car? car,
    int? wins,
    int? losses,
  }) {
    return TournamentCarStats(
      car: car ?? this.car,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
    );
  }
}

/// Standings for a car within a group
class GroupStanding {
  final Car car;
  final int wins;
  final int losses;
  final int points; // 3 per win
  final int groupIndex;
  final int seed; // 1 or 2 (position within group)
  final Map<int, bool> headToHead; // carId -> won?

  const GroupStanding({
    required this.car,
    required this.wins,
    required this.losses,
    required this.points,
    required this.groupIndex,
    required this.seed,
    required this.headToHead,
  });

  GroupStanding copyWith({
    Car? car,
    int? wins,
    int? losses,
    int? points,
    int? groupIndex,
    int? seed,
    Map<int, bool>? headToHead,
  }) {
    return GroupStanding(
      car: car ?? this.car,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      points: points ?? this.points,
      groupIndex: groupIndex ?? this.groupIndex,
      seed: seed ?? this.seed,
      headToHead: headToHead ?? this.headToHead,
    );
  }
}

/// Helper class for calculating group standings
class _GroupCarStats {
  final Car car;
  int wins = 0;
  int losses = 0;
  final Map<int, bool> headToHead = {};

  _GroupCarStats({required this.car});
}

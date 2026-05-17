import 'package:isar/isar.dart';
import '../models/car.dart';
import '../models/match.dart';
import '../models/tournament.dart';

typedef CarStatsData = ({
  int wins,
  int losses,
  int totalMatches,
  int tournamentWins,
});

class _MutableCarStats {
  int wins = 0;
  int totalMatches = 0;
  int tournamentWins = 0;

  CarStatsData toData() => (
    wins: wins,
    losses: totalMatches - wins,
    totalMatches: totalMatches,
    tournamentWins: tournamentWins,
  );
}

class CarRepository {
  final Isar _isar;

  CarRepository(this._isar);

  // Get all non-deleted cars
  Future<List<Car>> getAllCars() async {
    return await _isar.cars.filter().isDeletedEqualTo(false).findAll();
  }

  // Get a car by ID
  Future<Car?> getCarById(Id id) async {
    return await _isar.cars.get(id);
  }

  // Get a car by UUID
  Future<Car?> getCarByUuid(String uuid) async {
    return await _isar.cars.filter().uuidEqualTo(uuid).findFirst();
  }

  // Add a new car
  Future<Id> addCar(Car car) async {
    return await _isar.writeTxn(() async {
      return await _isar.cars.put(car);
    });
  }

  // Update a car
  Future<void> updateCar(Car car) async {
    await _isar.writeTxn(() async {
      await _isar.cars.put(car);
    });
  }

  // Soft delete a car
  Future<void> deleteCar(Id id) async {
    await _isar.writeTxn(() async {
      final car = await _isar.cars.get(id);
      if (car != null) {
        car.isDeleted = true;
        await _isar.cars.put(car);
      }
    });
  }

  // Get win count for a car (dynamically calculated)
  Future<int> getWinCount(Id carId) async {
    return await _isar.matchs
        .filter()
        .winner((q) => q.idEqualTo(carId))
        .count();
  }

  // Get loss count for a car (dynamically calculated)
  Future<int> getLossCount(Id carId) async {
    // Losses = completed matches participated in - wins
    final matchCount = await getMatchCount(carId);
    final winCount = await getWinCount(carId);
    return matchCount - winCount;
  }

  // Get total match count for a car (completed matches only)
  Future<int> getMatchCount(Id carId) async {
    // Count completed matches where car was carA
    final asCarA = await _isar.matchs
        .filter()
        .carA((q) => q.idEqualTo(carId))
        .and()
        .winner((q) => q.idGreaterThan(0))
        .count();

    // Count completed matches where car was carB
    final asCarB = await _isar.matchs
        .filter()
        .carB((q) => q.idEqualTo(carId))
        .and()
        .winner((q) => q.idGreaterThan(0))
        .count();

    return asCarA + asCarB;
  }

  // Get tournament win count for a car (dynamically calculated)
  Future<int> getTournamentWinCount(Id carId) async {
    final completedTournaments = await _isar.tournaments
        .filter()
        .statusEqualTo(TournamentStatus.completed)
        .findAll();

    int tournamentWins = 0;

    for (final tournament in completedTournaments) {
      await tournament.rounds.load();
      final rounds = tournament.rounds.toList();
      if (rounds.isEmpty) continue;

      // Sort rounds to find the final round
      rounds.sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

      if (tournament.type == TournamentType.knockout ||
          tournament.type == TournamentType.tinyTournament ||
          tournament.type == TournamentType.doubleElimination ||
          tournament.type == TournamentType.groupKnockout) {
        // Winner is from the final match of the last round
        final finalRound = rounds.last;
        await finalRound.matches.load();
        final matches = finalRound.matches.toList();
        if (matches.isNotEmpty) {
          final finalMatch = matches.first;
          await finalMatch.winner.load();
          if (finalMatch.winner.value?.id == carId) {
            tournamentWins++;
          }
        }
      } else {
        // Round robin - winner is the car with most wins
        final winCounts = <int, int>{};
        for (final round in rounds) {
          await round.matches.load();
          for (final match in round.matches) {
            await match.winner.load();
            if (match.winner.value != null) {
              final winnerId = match.winner.value!.id;
              winCounts[winnerId] = (winCounts[winnerId] ?? 0) + 1;
            }
          }
        }

        if (winCounts.isNotEmpty) {
          final sortedEntries = winCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          if (sortedEntries.first.key == carId) {
            tournamentWins++;
          }
        }
      }
    }

    return tournamentWins;
  }

  Future<CarStatsData> getStatsForCar(Id carId) async {
    final wins = await getWinCount(carId);
    final matches = await getMatchCount(carId);
    final tournamentWins = await getTournamentWinCount(carId);

    return (
      wins: wins,
      losses: matches - wins,
      totalMatches: matches,
      tournamentWins: tournamentWins,
    );
  }

  Future<Map<Id, CarStatsData>> getStatsForCars(Iterable<Id> carIds) async {
    final targetIds = carIds.toSet();
    final mutableStatsById = {
      for (final id in targetIds) id: _MutableCarStats(),
    };

    if (targetIds.isEmpty) {
      return const {};
    }

    final completedMatches = await _isar.matchs
        .filter()
        .winner((q) => q.idGreaterThan(0))
        .findAll();

    for (final match in completedMatches) {
      await Future.wait([
        match.carA.load(),
        match.carB.load(),
        match.winner.load(),
      ]);

      final carAId = match.carA.value?.id;
      final carBId = match.carB.value?.id;
      final winnerId = match.winner.value?.id;

      if (carAId != null && targetIds.contains(carAId)) {
        mutableStatsById[carAId]!.totalMatches++;
      }
      if (carBId != null && targetIds.contains(carBId)) {
        mutableStatsById[carBId]!.totalMatches++;
      }
      if (winnerId != null && targetIds.contains(winnerId)) {
        mutableStatsById[winnerId]!.wins++;
      }
    }

    final tournamentWinCounts = await _getTournamentWinCountsForCars(targetIds);
    for (final entry in tournamentWinCounts.entries) {
      mutableStatsById[entry.key]!.tournamentWins = entry.value;
    }

    return {
      for (final entry in mutableStatsById.entries)
        entry.key: entry.value.toData(),
    };
  }

  Future<Map<Id, int>> _getTournamentWinCountsForCars(Set<Id> carIds) async {
    final tournamentWinCounts = {for (final id in carIds) id: 0};

    final completedTournaments = await _isar.tournaments
        .filter()
        .statusEqualTo(TournamentStatus.completed)
        .findAll();

    for (final tournament in completedTournaments) {
      await tournament.rounds.load();
      final rounds = tournament.rounds.toList();
      if (rounds.isEmpty) continue;

      rounds.sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

      if (tournament.type == TournamentType.knockout ||
          tournament.type == TournamentType.doubleElimination ||
          tournament.type == TournamentType.groupKnockout) {
        final finalRound = rounds.last;
        await finalRound.matches.load();
        final matches = finalRound.matches.toList();
        if (matches.isEmpty) continue;

        final finalMatch = matches.first;
        await finalMatch.winner.load();
        final winnerId = finalMatch.winner.value?.id;
        if (winnerId != null && carIds.contains(winnerId)) {
          tournamentWinCounts[winnerId] = tournamentWinCounts[winnerId]! + 1;
        }
      } else {
        final winCounts = <Id, int>{};
        for (final round in rounds) {
          await round.matches.load();
          for (final match in round.matches) {
            await match.winner.load();
            final winnerId = match.winner.value?.id;
            if (winnerId != null) {
              winCounts[winnerId] = (winCounts[winnerId] ?? 0) + 1;
            }
          }
        }

        if (winCounts.isNotEmpty) {
          final sortedEntries = winCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final winnerId = sortedEntries.first.key;
          if (carIds.contains(winnerId)) {
            tournamentWinCounts[winnerId] = tournamentWinCounts[winnerId]! + 1;
          }
        }
      }
    }

    return tournamentWinCounts;
  }

  // Watch cars stream for real-time updates
  Stream<List<Car>> watchCars() {
    return _isar.cars
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true);
  }
}

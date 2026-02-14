import 'dart:math';
import 'package:isar/isar.dart';
import '../data/models/models.dart';
import '../services/database_service.dart';
import '../services/tournament_service.dart';

class ScreenshotSeedContext {
  final int activeKnockoutTournamentId;
  final int completedKnockoutTournamentId;
  final int completedRoundRobinTournamentId;

  const ScreenshotSeedContext({
    required this.activeKnockoutTournamentId,
    required this.completedKnockoutTournamentId,
    required this.completedRoundRobinTournamentId,
  });
}

class ScreenshotDataSeeder {
  static Future<ScreenshotSeedContext> seed() async {
    final isar = await DatabaseService.instance;

    await isar.writeTxn(() async {
      await isar.clear();
    });

    final cars = await _seedCars(isar);
    final tournamentService = TournamentService(isar, random: Random(42));

    final activeKnockoutTournamentId = await tournamentService.createTournament(
      carIds: cars.take(8).map((car) => car.id).toList(),
      type: TournamentType.knockout,
    );
    await _completeOpenMatches(
      tournamentService,
      activeKnockoutTournamentId,
      maxMatches: 2,
    );

    final completedKnockoutTournamentId = await tournamentService
        .createTournament(
          carIds: cars.skip(2).take(8).map((car) => car.id).toList(),
          type: TournamentType.knockout,
        );
    await _completeAllMatches(tournamentService, completedKnockoutTournamentId);

    final completedRoundRobinTournamentId = await tournamentService
        .createTournament(
          carIds: cars.skip(6).take(6).map((car) => car.id).toList(),
          type: TournamentType.roundRobin,
        );
    await _completeAllMatches(
      tournamentService,
      completedRoundRobinTournamentId,
    );

    return ScreenshotSeedContext(
      activeKnockoutTournamentId: activeKnockoutTournamentId,
      completedKnockoutTournamentId: completedKnockoutTournamentId,
      completedRoundRobinTournamentId: completedRoundRobinTournamentId,
    );
  }

  static Future<List<Car>> _seedCars(Isar isar) async {
    const names = [
      'Blaze Fury',
      'Turbo Titan',
      'Midnight Bolt',
      'Storm Chaser',
      'Neon Phantom',
      'Crimson Rocket',
      'Silver Streak',
      'Blue Viper',
      'Gold Thunder',
      'Iron Comet',
      'Fire Drift',
      'Shadow Sprint',
      'Apex Racer',
      'Drift Nova',
    ];

    final now = DateTime(2026, 1, 1, 9, 0);
    final cars = names
        .asMap()
        .entries
        .map(
          (entry) => Car()
            ..uuid = 'screenshot-${entry.key + 1}'
            ..name = entry.value
            ..photoPath = ''
            ..createdAt = now.add(Duration(minutes: entry.key)),
        )
        .toList();

    await isar.writeTxn(() async {
      await isar.cars.putAll(cars);
    });

    return cars;
  }

  static Future<void> _completeOpenMatches(
    TournamentService service,
    int tournamentId, {
    required int maxMatches,
  }) async {
    var favorCarA = true;

    for (var completed = 0; completed < maxMatches; completed++) {
      final match = await _nextUnfinishedMatch(service, tournamentId);
      if (match == null) {
        return;
      }

      await match.carA.load();
      await match.carB.load();

      final winner = favorCarA ? match.carA.value : match.carB.value;
      if (winner == null) {
        return;
      }

      await service.completeMatch(match.id, winner.id);
      favorCarA = !favorCarA;
    }
  }

  static Future<void> _completeAllMatches(
    TournamentService service,
    int tournamentId,
  ) async {
    var favorCarA = true;

    for (var step = 0; step < 512; step++) {
      final match = await _nextUnfinishedMatch(service, tournamentId);
      if (match == null) {
        return;
      }

      await match.carA.load();
      await match.carB.load();

      final winner = favorCarA ? match.carA.value : match.carB.value;
      if (winner == null) {
        throw StateError(
          'Encountered a match without both cars during seeding',
        );
      }

      await service.completeMatch(match.id, winner.id);
      favorCarA = !favorCarA;
    }

    throw StateError(
      'Screenshot seeding exceeded expected match count for tournament $tournamentId',
    );
  }

  static Future<Match?> _nextUnfinishedMatch(
    TournamentService service,
    int tournamentId,
  ) async {
    final rounds = await service.getRounds(tournamentId);

    for (final round in rounds) {
      final matches = await service.getMatches(round.id)
        ..sort((a, b) => a.matchPosition.compareTo(b.matchPosition));

      for (final match in matches) {
        await match.winner.load();
        if (match.winner.value == null) {
          return match;
        }
      }
    }

    return null;
  }
}

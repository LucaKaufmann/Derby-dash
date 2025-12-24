import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/models.dart';
import '../services/tournament_service.dart';
import 'database_provider.dart';

part 'tournament_provider.g.dart';

@Riverpod(keepAlive: true)
TournamentService tournamentService(TournamentServiceRef ref) {
  final isar = ref.watch(databaseProvider).requireValue;
  return TournamentService(isar);
}

@riverpod
Future<Tournament?> tournament(TournamentRef ref, int id) async {
  final service = ref.watch(tournamentServiceProvider);
  return await service.getTournament(id);
}

@riverpod
Future<List<Round>> tournamentRounds(TournamentRoundsRef ref, int tournamentId) async {
  final service = ref.watch(tournamentServiceProvider);
  return await service.getRounds(tournamentId);
}

@riverpod
Future<List<Match>> roundMatches(RoundMatchesRef ref, int roundId) async {
  final service = ref.watch(tournamentServiceProvider);
  return await service.getMatches(roundId);
}

@riverpod
Future<Round?> currentRound(CurrentRoundRef ref, int tournamentId) async {
  final service = ref.watch(tournamentServiceProvider);
  return await service.getCurrentRound(tournamentId);
}

@riverpod
Future<Match?> matchDetails(MatchDetailsRef ref, int matchId) async {
  final service = ref.watch(tournamentServiceProvider);
  return await service.getMatch(matchId);
}

@riverpod
Future<Car?> tournamentWinner(TournamentWinnerRef ref, int tournamentId) async {
  final service = ref.watch(tournamentServiceProvider);
  return await service.getTournamentWinner(tournamentId);
}

@riverpod
Future<List<Tournament>> activeTournaments(ActiveTournamentsRef ref) async {
  final service = ref.watch(tournamentServiceProvider);
  return await service.getActiveTournaments();
}

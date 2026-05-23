import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/models.dart';
import '../services/tournament_service.dart';
export '../services/tournament_service.dart' show TournamentCarStats, GroupStanding;
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

@riverpod
Future<List<Tournament>> completedTournaments(CompletedTournamentsRef ref) async {
  final service = ref.watch(tournamentServiceProvider);
  return await service.getCompletedTournaments();
}

@riverpod
Future<int> tournamentParticipantCount(TournamentParticipantCountRef ref, int tournamentId) async {
  final service = ref.watch(tournamentServiceProvider);
  return await service.getParticipantCount(tournamentId);
}

@riverpod
Future<List<TournamentCarStats>> tournamentStats(TournamentStatsRef ref, int tournamentId) async {
  final service = ref.watch(tournamentServiceProvider);
  return await service.getTournamentStats(tournamentId);
}

/// Get standings for a specific group in a groupKnockout tournament
@riverpod
Future<List<GroupStanding>> groupStandings(
  GroupStandingsRef ref,
  int tournamentId,
  int groupIndex,
) async {
  final service = ref.watch(tournamentServiceProvider);
  return await service.getGroupStandings(tournamentId, groupIndex);
}

/// Get all group stage rounds for a groupKnockout tournament
@riverpod
Future<List<Round>> groupRounds(GroupRoundsRef ref, int tournamentId) async {
  final service = ref.watch(tournamentServiceProvider);
  final rounds = await service.getRounds(tournamentId);
  return rounds.where((r) => r.groupIndex != null).toList();
}

/// Get all knockout stage rounds for a groupKnockout tournament
@riverpod
Future<List<Round>> knockoutRounds(KnockoutRoundsRef ref, int tournamentId) async {
  final service = ref.watch(tournamentServiceProvider);
  final rounds = await service.getRounds(tournamentId);
  return rounds.where((r) => r.bracketType == BracketType.knockout).toList();
}

/// Check if the group stage is complete for a groupKnockout tournament
@riverpod
Future<bool> isGroupStageComplete(IsGroupStageCompleteRef ref, int tournamentId) async {
  final service = ref.watch(tournamentServiceProvider);
  final tournament = await service.getTournament(tournamentId);
  if (tournament == null || tournament.type != TournamentType.groupKnockout) {
    return true;
  }
  // If already in knockout phase, group stage is complete
  if (tournament.phase == TournamentPhase.knockout) {
    return true;
  }
  // Check if all group matches have winners
  final rounds = await service.getRounds(tournamentId);
  final groupRounds = rounds.where((r) => r.groupIndex != null).toList();
  for (final round in groupRounds) {
    final matches = await service.getMatches(round.id);
    for (final match in matches) {
      if (match.winner.value == null) {
        return false;
      }
    }
  }
  return true;
}

/// Get all standings for all groups in a groupKnockout tournament
@riverpod
Future<Map<int, List<GroupStanding>>> allGroupStandings(
  AllGroupStandingsRef ref,
  int tournamentId,
) async {
  final service = ref.watch(tournamentServiceProvider);
  final tournament = await service.getTournament(tournamentId);
  if (tournament == null || tournament.groupCount == null) {
    return {};
  }

  final result = <int, List<GroupStanding>>{};
  for (int i = 0; i < tournament.groupCount!; i++) {
    result[i] = await service.getGroupStandings(tournamentId, i);
  }
  return result;
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/models.dart';
import '../../providers/tournament_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/group/group_stage_view.dart';

class TournamentDashboardScreen extends ConsumerWidget {
  final int tournamentId;

  const TournamentDashboardScreen({
    super.key,
    required this.tournamentId,
  });

  String _getTournamentTypeLabel(TournamentType type) {
    switch (type) {
      case TournamentType.knockout:
        return 'KNOCKOUT';
      case TournamentType.doubleElimination:
        return 'DOUBLE ELIMINATION';
      case TournamentType.roundRobin:
        return 'ROUND ROBIN';
      case TournamentType.groupKnockout:
        return 'GROUP + KNOCKOUT';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentAsync = ref.watch(tournamentProvider(tournamentId));
    final roundsAsync = ref.watch(tournamentRoundsProvider(tournamentId));
    final winnerAsync = ref.watch(tournamentWinnerProvider(tournamentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('TOURNAMENT'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
        ),
        actions: [
          // Show bracket button for knockout/double elimination, standings for round robin
          tournamentAsync.maybeWhen(
            data: (tournament) {
              if (tournament?.type == TournamentType.knockout ||
                  tournament?.type == TournamentType.doubleElimination) {
                return IconButton(
                  icon: const Icon(Icons.account_tree),
                  tooltip: 'View Bracket',
                  onPressed: () => context.push('/tournament/$tournamentId/bracket'),
                );
              } else if (tournament?.type == TournamentType.roundRobin) {
                return IconButton(
                  icon: const Icon(Icons.leaderboard),
                  tooltip: 'View Standings',
                  onPressed: () => context.push('/tournament/$tournamentId/standings'),
                );
              } else if (tournament?.type == TournamentType.groupKnockout) {
                // Show bracket button in knockout phase
                if (tournament?.phase == TournamentPhase.knockout) {
                  return IconButton(
                    icon: const Icon(Icons.account_tree),
                    tooltip: 'View Bracket',
                    onPressed: () => context.push('/tournament/$tournamentId/bracket'),
                  );
                }
              }
              return const SizedBox.shrink();
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: tournamentAsync.when(
        data: (tournament) {
          if (tournament == null) {
            return const Center(child: Text('Tournament not found'));
          }

          // For groupKnockout in group phase, show GroupStageView
          if (tournament.type == TournamentType.groupKnockout &&
              tournament.phase == TournamentPhase.group) {
            return GroupStageView(tournament: tournament);
          }

          return Column(
            children: [
              // Tournament Status Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: tournament.status == TournamentStatus.completed
                    ? AppTheme.successColor.withOpacity(0.2)
                    : AppTheme.primaryColor.withOpacity(0.2),
                child: Text(
                  tournament.type == TournamentType.groupKnockout
                      ? 'KNOCKOUT STAGE'
                      : _getTournamentTypeLabel(tournament.type),
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),

              // Rounds List with Champion Card at top
              Expanded(
                child: roundsAsync.when(
                  data: (rounds) {
                    if (rounds.isEmpty) {
                      return const Center(child: Text('No rounds yet'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      // Add 1 for champion card if tournament is completed
                      itemCount: tournament.status == TournamentStatus.completed
                          ? rounds.length + 1
                          : rounds.length,
                      itemBuilder: (context, index) {
                        // First item is champion card for completed tournaments
                        if (tournament.status == TournamentStatus.completed &&
                            index == 0) {
                          return winnerAsync.when(
                            data: (winner) => winner != null
                                ? _ChampionCard(
                                    winner: winner,
                                    tournamentId: tournamentId,
                                  )
                                : const SizedBox.shrink(),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        }

                        // Adjust index for rounds when champion card is shown
                        final roundIndex =
                            tournament.status == TournamentStatus.completed
                                ? index - 1
                                : index;
                        final round = rounds[roundIndex];
                        return _RoundCard(
                          round: round,
                          tournamentId: tournamentId,
                          tournamentType: tournament.type,
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _RoundCard extends ConsumerWidget {
  final Round round;
  final int tournamentId;
  final TournamentType tournamentType;

  const _RoundCard({
    required this.round,
    required this.tournamentId,
    required this.tournamentType,
  });

  String _getRoundName() {
    if (tournamentType == TournamentType.roundRobin) return 'All Matches';

    // For double elimination, show bracket type
    if (tournamentType == TournamentType.doubleElimination) {
      final bracketLabel = _getBracketLabel();
      // Grand finals doesn't need "Round X" suffix
      if (round.bracketType == BracketType.grandFinals) {
        return bracketLabel;
      }
      return '$bracketLabel - Round ${round.roundNumber}';
    }

    // For knockout, just use round numbers
    return 'Round ${round.roundNumber}';
  }

  String _getBracketLabel() {
    switch (round.bracketType) {
      case BracketType.winners:
        return 'Winners';
      case BracketType.losers:
        return 'Losers';
      case BracketType.grandFinals:
        // Round 2 is bracket reset
        return round.roundNumber == 2 ? 'Grand Finals - RESET' : 'Grand Finals';
      case BracketType.knockout:
        // For groupKnockout knockout phase
        switch (round.knockoutRoundName) {
          case 'gf':
            return 'Grand Finals';
          case 'sf':
            return 'Semifinals';
          case 'qf':
            return 'Quarterfinals';
          case 'ro16':
            return 'Round of 16';
          default:
            return 'Knockout';
        }
      case BracketType.groupA:
      case BracketType.groupB:
      case BracketType.groupC:
      case BracketType.groupD:
      case BracketType.groupE:
      case BracketType.groupF:
      case BracketType.groupG:
      case BracketType.groupH:
        final groupLetter = String.fromCharCode('A'.codeUnitAt(0) + (round.groupIndex ?? 0));
        return 'Group $groupLetter';
    }
  }

  Color _getBracketColor() {
    if (tournamentType != TournamentType.doubleElimination &&
        tournamentType != TournamentType.groupKnockout) {
      return round.isCompleted ? AppTheme.successColor : AppTheme.primaryColor;
    }

    switch (round.bracketType) {
      case BracketType.winners:
        return round.isCompleted
            ? AppTheme.successColor
            : AppTheme.successColor.withValues(alpha: 0.7);
      case BracketType.losers:
        return round.isCompleted
            ? AppTheme.successColor
            : AppTheme.errorColor.withValues(alpha: 0.7);
      case BracketType.grandFinals:
        return round.isCompleted ? AppTheme.successColor : AppTheme.winnerColor;
      case BracketType.knockout:
        // For groupKnockout knockout phase
        if (round.knockoutRoundName == 'gf') {
          return round.isCompleted ? AppTheme.successColor : AppTheme.winnerColor;
        }
        return round.isCompleted ? AppTheme.successColor : AppTheme.primaryColor;
      case BracketType.groupA:
      case BracketType.groupB:
      case BracketType.groupC:
      case BracketType.groupD:
      case BracketType.groupE:
      case BracketType.groupF:
      case BracketType.groupG:
      case BracketType.groupH:
        return round.isCompleted ? AppTheme.successColor : AppTheme.primaryColor;
    }
  }

  IconData _getBracketIcon() {
    switch (round.bracketType) {
      case BracketType.winners:
        return Icons.emoji_events;
      case BracketType.losers:
        return Icons.trending_down;
      case BracketType.grandFinals:
        return Icons.military_tech;
      case BracketType.knockout:
        if (round.knockoutRoundName == 'gf') {
          return Icons.military_tech;
        }
        return Icons.sports_mma;
      case BracketType.groupA:
      case BracketType.groupB:
      case BracketType.groupC:
      case BracketType.groupD:
      case BracketType.groupE:
      case BracketType.groupF:
      case BracketType.groupG:
      case BracketType.groupH:
        return Icons.groups;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(roundMatchesProvider(round.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Round Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getBracketColor().withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Bracket icon for double elimination
                if (tournamentType == TournamentType.doubleElimination) ...[
                  Icon(
                    _getBracketIcon(),
                    color: _getBracketColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    _getRoundName(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (round.isCompleted)
                  const Icon(Icons.check_circle, color: AppTheme.successColor)
                else
                  Icon(Icons.play_circle, color: _getBracketColor()),
              ],
            ),
          ),

          // Matches
          matchesAsync.when(
            data: (matches) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: matches.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _MatchRow(
                    match: matches[index],
                    tournamentId: tournamentId,
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $error'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchRow extends ConsumerWidget {
  final Match match;
  final int tournamentId;

  const _MatchRow({
    required this.match,
    required this.tournamentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchAsync = ref.watch(matchDetailsProvider(match.id));

    return matchAsync.when(
      data: (matchDetails) {
        if (matchDetails == null) return const SizedBox.shrink();

        final carA = matchDetails.carA.value;
        final carB = matchDetails.carB.value;
        final winner = matchDetails.winner.value;

        return InkWell(
          onTap: winner == null
              ? () => context.push('/tournament/$tournamentId/match/${match.id}')
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: winner != null
                  ? AppTheme.successColor.withOpacity(0.1)
                  : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: winner != null
                    ? AppTheme.successColor
                    : AppTheme.primaryColor,
                width: 2,
              ),
            ),
            child: _buildMatchRow(context, carA, carB, winner),
          ),
        );
      },
      loading: () => const SizedBox(height: 60),
      error: (_, __) => const Text('Error'),
    );
  }

  Widget _buildMatchRow(
      BuildContext context, Car? carA, Car? carB, Car? winner) {
    final carAWon = winner?.id == carA?.id;
    final carBWon = winner?.id == carB?.id;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Car A
        Expanded(
          child: _CarInfo(
            car: carA,
            isWinner: carAWon,
            isLoser: carBWon,
          ),
        ),

        // VS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: winner != null
                  ? AppTheme.successColor.withValues(alpha: 0.2)
                  : AppTheme.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              winner != null ? '!' : 'VS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: winner != null ? AppTheme.successColor : AppTheme.primaryColor,
              ),
            ),
          ),
        ),

        // Car B
        Expanded(
          child: _CarInfo(
            car: carB,
            isWinner: carBWon,
            isLoser: carAWon,
            alignRight: true,
          ),
        ),
      ],
    );
  }
}

class _CarInfo extends StatelessWidget {
  final Car? car;
  final bool isWinner;
  final bool isLoser;
  final bool alignRight;

  const _CarInfo({
    required this.car,
    this.isWinner = false,
    this.isLoser = false,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Photo with winner badge
        _CarAvatar(photoPath: car?.photoPath, isWinner: isWinner),
        const SizedBox(height: 8),
        // Name
        Text(
          car?.name ?? 'Unknown',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isLoser ? AppTheme.textSecondary.withValues(alpha: 0.5) : null,
            decoration: isLoser ? TextDecoration.lineThrough : null,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CarAvatar extends StatelessWidget {
  final String? photoPath;
  final bool isWinner;

  const _CarAvatar({
    this.photoPath,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Photo
        Container(
          width: 56,
          height: 56,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: photoPath != null && File(photoPath!).existsSync()
              ? Image.file(File(photoPath!), fit: BoxFit.cover)
              : Container(
                  color: AppTheme.backgroundColor,
                  child: const Icon(Icons.directions_car, size: 24),
                ),
        ),
        // Winner border overlay
        if (isWinner)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.winnerColor, width: 3),
            ),
          ),
        // Winner trophy badge
        if (isWinner)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.winnerColor, width: 2),
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 12,
                color: AppTheme.winnerColor,
              ),
            ),
          ),
      ],
    );
  }
}

class _ChampionCard extends ConsumerWidget {
  final Car winner;
  final int tournamentId;

  const _ChampionCard({
    required this.winner,
    required this.tournamentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPhoto =
        winner.photoPath.isNotEmpty && File(winner.photoPath).existsSync();
    final statsAsync = ref.watch(tournamentStatsProvider(tournamentId));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Champion Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.winnerColor.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: AppTheme.winnerColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'CHAMPION',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.winnerColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                ),
              ],
            ),
          ),
          // Champion Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Car photo with border overlay
                Stack(
                  children: [
                    // Photo
                    Container(
                      width: 80,
                      height: 80,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.winnerColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: hasPhoto
                          ? Image.file(File(winner.photoPath), fit: BoxFit.cover)
                          : Container(
                              color: AppTheme.backgroundColor,
                              child: const Icon(
                                Icons.directions_car,
                                size: 40,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                    ),
                    // Border overlay
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.winnerColor,
                          width: 3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Car info and stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        winner.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Stats row
                      statsAsync.when(
                        data: (stats) {
                          final winnerStats = stats.firstWhere(
                            (s) => s.car.id == winner.id,
                            orElse: () => TournamentCarStats(
                              car: winner,
                              wins: 0,
                              losses: 0,
                            ),
                          );
                          final total =
                              winnerStats.wins + winnerStats.losses;
                          final winRate = total > 0
                              ? (winnerStats.wins / total * 100).round()
                              : 0;

                          return Row(
                            children: [
                              // Win/Loss record
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${winnerStats.wins}W',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.successColor,
                                      ),
                                    ),
                                    const Text(
                                      ' - ',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '${winnerStats.losses}L',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: winnerStats.losses > 0
                                            ? AppTheme.errorColor
                                            : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Win rate
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.winnerColor
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$winRate%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.winnerColor,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox(
                          height: 32,
                          child: Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

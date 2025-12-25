import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/models.dart';
import '../../providers/tournament_provider.dart';
import '../../theme/app_theme.dart';

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
          // Show bracket button for knockout and double elimination tournaments
          tournamentAsync.maybeWhen(
            data: (tournament) {
              if (tournament?.type == TournamentType.knockout ||
                  tournament?.type == TournamentType.doubleElimination) {
                return IconButton(
                  icon: const Icon(Icons.account_tree),
                  tooltip: 'View Bracket',
                  onPressed: () => context.push('/tournament/$tournamentId/bracket'),
                );
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
                  _getTournamentTypeLabel(tournament.type),
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),

              // Rounds List
              Expanded(
                child: roundsAsync.when(
                  data: (rounds) {
                    if (rounds.isEmpty) {
                      return const Center(child: Text('No rounds yet'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: rounds.length,
                      itemBuilder: (context, index) {
                        final round = rounds[index];
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

              // Champion Card at bottom
              if (tournament.status == TournamentStatus.completed)
                winnerAsync.when(
                  data: (winner) => winner != null
                      ? _ChampionCard(winner: winner)
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
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
    }
  }

  Color _getBracketColor() {
    if (tournamentType != TournamentType.doubleElimination) {
      return round.isCompleted ? AppTheme.successColor : AppTheme.primaryColor;
    }

    switch (round.bracketType) {
      case BracketType.winners:
        return round.isCompleted
            ? AppTheme.successColor
            : AppTheme.successColor.withOpacity(0.7);
      case BracketType.losers:
        return round.isCompleted
            ? AppTheme.successColor
            : AppTheme.errorColor.withOpacity(0.7);
      case BracketType.grandFinals:
        return round.isCompleted ? AppTheme.successColor : AppTheme.winnerColor;
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
            padding: const EdgeInsets.all(12),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: winner != null
                ? AppTheme.successColor.withOpacity(0.2)
                : AppTheme.primaryColor.withOpacity(0.2),
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
    return Row(
      mainAxisAlignment:
          alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!alignRight) ...[
          _CarAvatar(photoPath: car?.photoPath, isWinner: isWinner),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment:
                alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                car?.name ?? 'Unknown',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isLoser
                      ? AppTheme.textSecondary.withOpacity(0.5)
                      : null,
                  decoration: isLoser ? TextDecoration.lineThrough : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isWinner)
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events, size: 14, color: AppTheme.winnerColor),
                    SizedBox(width: 4),
                    Text(
                      'WINNER',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.winnerColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (alignRight) ...[
          const SizedBox(width: 8),
          _CarAvatar(photoPath: car?.photoPath, isWinner: isWinner),
        ],
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
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: isWinner
            ? Border.all(color: AppTheme.winnerColor, width: 3)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: photoPath != null && File(photoPath!).existsSync()
          ? Image.file(File(photoPath!), fit: BoxFit.cover)
          : Container(
              color: AppTheme.backgroundColor,
              child: const Icon(Icons.directions_car, size: 24),
            ),
    );
  }
}

class _ChampionCard extends StatelessWidget {
  final Car winner;

  const _ChampionCard({required this.winner});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = winner.photoPath.isNotEmpty &&
        File(winner.photoPath).existsSync();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.winnerColor.withOpacity(0.3),
            AppTheme.winnerColor.withOpacity(0.5),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🏆 CHAMPION 🏆',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: hasPhoto
                  ? Image.file(File(winner.photoPath), fit: BoxFit.cover)
                  : Container(
                      color: AppTheme.backgroundColor,
                      child: const Icon(
                        Icons.directions_car,
                        size: 48,
                        color: AppTheme.textSecondary,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              winner.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

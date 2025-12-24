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
                child: Column(
                  children: [
                    Text(
                      tournament.type == TournamentType.knockout
                          ? 'KNOCKOUT'
                          : 'ROUND ROBIN',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (tournament.status == TournamentStatus.completed)
                      winnerAsync.when(
                        data: (winner) => winner != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.emoji_events,
                                      color: AppTheme.winnerColor,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'WINNER: ${winner.name}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: AppTheme.winnerColor,
                                          ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                  ],
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
                          isKnockout:
                              tournament.type == TournamentType.knockout,
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
  final bool isKnockout;

  const _RoundCard({
    required this.round,
    required this.tournamentId,
    required this.isKnockout,
  });

  String _getRoundName() {
    if (!isKnockout) return 'All Matches';

    // For knockout, we might want to show "Finals", "Semi-Finals", etc.
    // But we don't know total rounds upfront, so just use numbers
    return 'Round ${round.roundNumber}';
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
              color: round.isCompleted
                  ? AppTheme.successColor.withOpacity(0.3)
                  : AppTheme.primaryColor.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  _getRoundName(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (round.isCompleted)
                  const Icon(Icons.check_circle, color: AppTheme.successColor)
                else
                  const Icon(Icons.play_circle, color: AppTheme.primaryColor),
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
        final isBye = matchDetails.isBye;

        return InkWell(
          onTap: winner == null && !isBye
              ? () => context.push('/tournament/$tournamentId/match/${match.id}')
              : isBye && winner == null
                  ? () => context.push('/tournament/$tournamentId/bye/${match.id}')
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
                    : winner == null && !isBye
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: isBye
                ? _buildByeRow(context, carA, winner != null)
                : _buildMatchRow(context, carA, carB, winner),
          ),
        );
      },
      loading: () => const SizedBox(height: 60),
      error: (_, __) => const Text('Error'),
    );
  }

  Widget _buildByeRow(BuildContext context, Car? car, bool acknowledged) {
    return Row(
      children: [
        _CarAvatar(photoPath: car?.photoPath),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                car?.name ?? 'Unknown',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                acknowledged ? 'Bye - Advanced' : 'Tap to acknowledge bye',
                style: TextStyle(
                  color: acknowledged
                      ? AppTheme.successColor
                      : AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        Icon(
          acknowledged ? Icons.check_circle : Icons.arrow_forward,
          color: acknowledged ? AppTheme.successColor : AppTheme.primaryColor,
          size: 32,
        ),
      ],
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

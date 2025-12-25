import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:derby_dash/data/models/models.dart';
import 'package:derby_dash/providers/tournament_provider.dart';
import 'package:derby_dash/theme/app_theme.dart';
import 'package:derby_dash/widgets/bracket/bracket_view.dart';

/// Screen displaying the tournament bracket visualization.
class BracketScreen extends ConsumerWidget {
  final int tournamentId;

  const BracketScreen({
    super.key,
    required this.tournamentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentAsync = ref.watch(tournamentProvider(tournamentId));
    final roundsAsync = ref.watch(tournamentRoundsProvider(tournamentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Bracket'),
      ),
      body: tournamentAsync.when(
        data: (tournament) {
          if (tournament == null) {
            return const Center(
              child: Text(
                'Tournament not found',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          // Only knockout tournaments have brackets
          if (tournament.type != TournamentType.knockout) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 64,
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bracket View Not Available',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Round Robin tournaments don\'t have a bracket structure.',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeMedium,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return roundsAsync.when(
            data: (rounds) => _BracketContent(
              tournament: tournament,
              rounds: rounds,
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error loading rounds: $error',
                style: const TextStyle(color: AppTheme.errorColor),
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading tournament: $error',
            style: const TextStyle(color: AppTheme.errorColor),
          ),
        ),
      ),
    );
  }
}

/// Content widget that loads matches for all rounds.
class _BracketContent extends ConsumerWidget {
  final Tournament tournament;
  final List<Round> rounds;

  const _BracketContent({
    required this.tournament,
    required this.rounds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load matches for all rounds
    final matchesByRound = <int, List<Match>>{};
    bool isLoading = false;
    String? errorMessage;

    for (final round in rounds) {
      final matchesAsync = ref.watch(roundMatchesProvider(round.id));
      matchesAsync.when(
        data: (matches) => matchesByRound[round.id] = matches,
        loading: () => isLoading = true,
        error: (e, s) => errorMessage = e.toString(),
      );
    }

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          'Error loading matches: $errorMessage',
          style: const TextStyle(color: AppTheme.errorColor),
        ),
      );
    }

    return Column(
      children: [
        // Status banner
        _StatusBanner(tournament: tournament),

        // Bracket view
        Expanded(
          child: BracketView(
            rounds: rounds,
            matchesByRound: matchesByRound,
            onMatchTap: (match) => _showMatchDetails(context, match),
          ),
        ),

        // Zoom hint
        Container(
          padding: const EdgeInsets.all(12),
          color: AppTheme.surfaceColor.withValues(alpha: 0.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pinch,
                size: 20,
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                'Pinch to zoom • Drag to pan',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMatchDetails(BuildContext context, Match match) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _MatchDetailsSheet(match: match),
    );
  }
}

/// Status banner showing tournament state.
class _StatusBanner extends StatelessWidget {
  final Tournament tournament;

  const _StatusBanner({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final isCompleted = tournament.status == TournamentStatus.completed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isCompleted
          ? AppTheme.successColor.withValues(alpha: 0.2)
          : AppTheme.primaryColor.withValues(alpha: 0.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCompleted ? Icons.emoji_events : Icons.play_circle,
            color: isCompleted ? AppTheme.winnerColor : AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            isCompleted ? 'Tournament Complete' : 'Tournament In Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isCompleted ? AppTheme.winnerColor : AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet showing match details.
class _MatchDetailsSheet extends StatelessWidget {
  final Match match;

  const _MatchDetailsSheet({required this.match});

  @override
  Widget build(BuildContext context) {
    final carA = match.carA.value;
    final carB = match.carB.value;
    final winner = match.winner.value;
    final isCompleted = winner != null;
    final isBye = match.isBye;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Text(
            isBye ? 'Bye Match' : 'Match Details',
            style: const TextStyle(
              fontSize: AppTheme.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          if (isBye) ...[
            // Bye match display
            _CarDisplay(
              car: carA,
              isWinner: true,
              label: 'Auto-advances',
            ),
          ] else ...[
            // Regular match display
            Row(
              children: [
                Expanded(
                  child: _CarDisplay(
                    car: carA,
                    isWinner: winner?.id == carA?.id,
                    isLoser: isCompleted && winner.id != carA?.id,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Expanded(
                  child: _CarDisplay(
                    car: carB,
                    isWinner: winner?.id == carB?.id,
                    isLoser: isCompleted && winner.id != carB?.id,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppTheme.successColor.withValues(alpha: 0.2)
                  : AppTheme.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isCompleted
                  ? isBye
                      ? 'Bye - Auto Advanced'
                      : 'Winner: ${winner.name}'
                  : 'Match Pending',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Car display widget for the details sheet.
class _CarDisplay extends StatelessWidget {
  final Car? car;
  final bool isWinner;
  final bool isLoser;
  final String? label;

  const _CarDisplay({
    required this.car,
    this.isWinner = false,
    this.isLoser = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final photoPath = car?.photoPath;
    final hasPhoto = photoPath != null &&
        photoPath.isNotEmpty &&
        File(photoPath).existsSync();

    return Column(
      children: [
        // Photo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isWinner
                  ? AppTheme.successColor
                  : isLoser
                      ? AppTheme.textSecondary.withValues(alpha: 0.3)
                      : AppTheme.primaryColor,
              width: isWinner ? 3 : 2,
            ),
            boxShadow: isWinner
                ? [
                    BoxShadow(
                      color: AppTheme.successColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: hasPhoto
              ? Image.file(
                  File(photoPath),
                  fit: BoxFit.cover,
                )
              : Container(
                  color: AppTheme.backgroundColor,
                  child: Icon(
                    Icons.directions_car,
                    size: 40,
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
        ),
        const SizedBox(height: 8),

        // Name
        Text(
          car?.name ?? 'TBD',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            color: isLoser
                ? AppTheme.textSecondary.withValues(alpha: 0.5)
                : isWinner
                    ? AppTheme.successColor
                    : AppTheme.textPrimary,
            decoration: isLoser ? TextDecoration.lineThrough : null,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        // Winner badge or label
        if (isWinner) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 16,
                color: AppTheme.winnerColor,
              ),
              const SizedBox(width: 4),
              Text(
                label ?? 'WINNER',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.winnerColor,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

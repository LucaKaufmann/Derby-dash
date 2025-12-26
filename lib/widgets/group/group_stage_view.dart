import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/models.dart';
import '../../providers/tournament_provider.dart';
import '../../theme/app_theme.dart';
import 'group_standings_table.dart';

class GroupStageView extends ConsumerWidget {
  final Tournament tournament;

  const GroupStageView({
    super.key,
    required this.tournament,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allStandingsAsync = ref.watch(allGroupStandingsProvider(tournament.id));
    final groupRoundsAsync = ref.watch(groupRoundsProvider(tournament.id));

    return allStandingsAsync.when(
      data: (allStandings) => groupRoundsAsync.when(
        data: (groupRounds) {
          // Count completed groups
          int completedGroups = 0;
          for (final round in groupRounds) {
            if (round.isCompleted) completedGroups++;
          }
          final totalGroups = tournament.groupCount ?? allStandings.length;

          return Column(
            children: [
              // Phase indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.2),
                      AppTheme.secondaryColor.withValues(alpha: 0.2),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.groups,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'GROUP STAGE',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completedGroups of $totalGroups groups complete',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    // Progress bar
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: totalGroups > 0 ? completedGroups / totalGroups : 0,
                        backgroundColor: AppTheme.surfaceColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completedGroups == totalGroups
                              ? AppTheme.successColor
                              : AppTheme.primaryColor,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),

              // Group standings and matches
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: allStandings.length,
                  itemBuilder: (context, index) {
                    final groupIndex = index;
                    final standings = allStandings[groupIndex] ?? [];

                    // Find the round for this group
                    final groupRound = groupRounds.firstWhere(
                      (r) => r.groupIndex == groupIndex,
                      orElse: () => groupRounds.first,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group standings table
                        GroupStandingsTable(
                          groupIndex: groupIndex,
                          standings: standings,
                        ),
                        const SizedBox(height: 8),

                        // Next match card (if group not complete)
                        if (!groupRound.isCompleted)
                          _NextMatchCard(
                            round: groupRound,
                            tournamentId: tournament.id,
                          ),

                        // Group matches
                        _GroupMatchesCard(
                          round: groupRound,
                          tournamentId: tournament.id,
                        ),

                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class _NextMatchCard extends ConsumerWidget {
  final Round round;
  final int tournamentId;

  const _NextMatchCard({
    required this.round,
    required this.tournamentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(roundMatchesProvider(round.id));

    return matchesAsync.when(
      data: (matches) {
        // Find the first incomplete match
        final nextMatch = matches.cast<Match?>().firstWhere(
              (m) => m?.winner.value == null,
              orElse: () => null,
            );

        if (nextMatch == null) {
          return const SizedBox.shrink();
        }

        return _NextMatchCardContent(
          match: nextMatch,
          tournamentId: tournamentId,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _NextMatchCardContent extends ConsumerWidget {
  final Match match;
  final int tournamentId;

  const _NextMatchCardContent({
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

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () =>
                  context.push('/tournament/$tournamentId/match/${match.id}'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_filled,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'NEXT MATCH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Car A
                        Expanded(
                          child: Text(
                            carA?.name ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // VS badge
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'VS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Car B
                        Expanded(
                          child: Text(
                            carB?.name ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to play',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _GroupMatchesCard extends ConsumerWidget {
  final Round round;
  final int tournamentId;

  const _GroupMatchesCard({
    required this.round,
    required this.tournamentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(roundMatchesProvider(round.id));

    return matchesAsync.when(
      data: (matches) {
        final completedCount = matches.where((m) => m.winner.value != null).length;
        final totalCount = matches.length;

        return Card(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: round.isCompleted
                      ? AppTheme.successColor.withValues(alpha: 0.1)
                      : AppTheme.surfaceColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Icon(
                      round.isCompleted ? Icons.check_circle : Icons.sports_mma,
                      size: 18,
                      color: round.isCompleted
                          ? AppTheme.successColor
                          : AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Matches',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$completedCount/$totalCount',
                      style: TextStyle(
                        fontSize: 13,
                        color: round.isCompleted
                            ? AppTheme.successColor
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Matches list
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: matches.map((match) {
                    return _GroupMatchRow(
                      match: match,
                      tournamentId: tournamentId,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class _GroupMatchRow extends ConsumerWidget {
  final Match match;
  final int tournamentId;

  const _GroupMatchRow({
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
        final isComplete = winner != null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isComplete
                  ? AppTheme.successColor.withValues(alpha: 0.1)
                  : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isComplete
                    ? AppTheme.successColor.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: Row(
                children: [
                  // Car A
                  Expanded(
                    child: Text(
                      carA?.name ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: winner?.id == carA?.id
                            ? AppTheme.successColor
                            : winner != null && winner.id != carA?.id
                                ? AppTheme.textSecondary.withValues(alpha: 0.6)
                                : null,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // VS or result indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isComplete
                            ? AppTheme.successColor.withValues(alpha: 0.2)
                            : AppTheme.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: isComplete
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: AppTheme.successColor,
                            )
                          : const Text(
                              'VS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                    ),
                  ),

                  // Car B
                  Expanded(
                    child: Text(
                      carB?.name ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: winner?.id == carB?.id
                            ? AppTheme.successColor
                            : winner != null && winner.id != carB?.id
                                ? AppTheme.textSecondary.withValues(alpha: 0.6)
                                : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        );
      },
      loading: () => const SizedBox(height: 40),
      error: (_, __) => const Text('Error'),
    );
  }
}

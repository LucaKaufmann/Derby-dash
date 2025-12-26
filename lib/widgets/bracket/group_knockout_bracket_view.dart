import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../providers/tournament_provider.dart';
import '../../theme/app_theme.dart';
import 'bracket_view.dart';

/// Bracket view for Group + Knockout tournaments showing group summary and knockout bracket.
class GroupKnockoutBracketView extends ConsumerWidget {
  final Tournament tournament;
  final List<Round> rounds;
  final Map<int, List<Match>> matchesByRound;
  final void Function(Match match)? onMatchTap;

  const GroupKnockoutBracketView({
    super.key,
    required this.tournament,
    required this.rounds,
    required this.matchesByRound,
    this.onMatchTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Separate knockout rounds from group rounds
    final knockoutRounds = rounds
        .where((r) => r.bracketType == BracketType.knockout)
        .toList();

    return Column(
      children: [
        // Group Summary section (horizontal scroll)
        _GroupSummarySection(tournamentId: tournament.id),

        // Knockout bracket
        Expanded(
          child: knockoutRounds.isEmpty
              ? const Center(
                  child: Text(
                    'Knockout phase not started yet',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                )
              : BracketView(
                  rounds: knockoutRounds,
                  matchesByRound: matchesByRound,
                  onMatchTap: onMatchTap,
                ),
        ),
      ],
    );
  }
}

/// Horizontal scrolling group summary section.
class _GroupSummarySection extends ConsumerWidget {
  final int tournamentId;

  const _GroupSummarySection({required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allStandingsAsync = ref.watch(allGroupStandingsProvider(tournamentId));

    return allStandingsAsync.when(
      data: (allStandings) {
        if (allStandings.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 140,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withValues(alpha: 0.5),
            border: Border(
              bottom: BorderSide(
                color: AppTheme.textSecondary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.groups,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'GROUP RESULTS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '→ Advanced',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.winnerColor.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: allStandings.length,
                  itemBuilder: (context, index) {
                    final standings = allStandings[index] ?? [];
                    return _GroupCard(
                      groupIndex: index,
                      standings: standings,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Individual group card showing top 2 advancing.
class _GroupCard extends StatelessWidget {
  final int groupIndex;
  final List<GroupStanding> standings;

  const _GroupCard({
    required this.groupIndex,
    required this.standings,
  });

  String get groupName => String.fromCharCode('A'.codeUnitAt(0) + groupIndex);

  @override
  Widget build(BuildContext context) {
    // Get top 2 (or all if less than 2)
    final topTwo = standings.take(2).toList();

    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Text(
              'GROUP $groupName',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: AppTheme.primaryColor,
              ),
            ),
          ),

          // Top 2 cars
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: topTwo.asMap().entries.map((entry) {
                  final index = entry.key;
                  final standing = entry.value;
                  return _MiniCarRow(
                    car: standing.car,
                    seed: index + 1,
                    isFirst: index == 0,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini car row showing photo, name, and seed.
class _MiniCarRow extends StatelessWidget {
  final Car car;
  final int seed;
  final bool isFirst;

  const _MiniCarRow({
    required this.car,
    required this.seed,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Seed badge
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: isFirst
                ? AppTheme.winnerColor.withValues(alpha: 0.2)
                : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            '$seed',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isFirst ? AppTheme.winnerColor : AppTheme.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Car photo
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isFirst ? AppTheme.winnerColor : AppTheme.textSecondary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: car.photoPath.isNotEmpty && File(car.photoPath).existsSync()
              ? Image.file(
                  File(car.photoPath),
                  fit: BoxFit.cover,
                )
              : Container(
                  color: AppTheme.surfaceColor,
                  child: const Icon(
                    Icons.directions_car,
                    size: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
        ),
        const SizedBox(width: 6),

        // Car name
        Expanded(
          child: Text(
            car.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isFirst ? FontWeight.w600 : FontWeight.normal,
              color: isFirst ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

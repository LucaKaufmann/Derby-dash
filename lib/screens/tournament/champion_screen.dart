import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/tournament_provider.dart';
import '../../theme/app_theme.dart';

class ChampionScreen extends ConsumerWidget {
  final int tournamentId;

  const ChampionScreen({
    super.key,
    required this.tournamentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final winnerAsync = ref.watch(tournamentWinnerProvider(tournamentId));
    final statsAsync = ref.watch(tournamentStatsProvider(tournamentId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: winnerAsync.when(
        data: (winner) {
          if (winner == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No champion found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('GO HOME'),
                  ),
                ],
              ),
            );
          }

          final hasPhoto =
              winner.photoPath.isNotEmpty && File(winner.photoPath).existsSync();

          return SafeArea(
            child: Column(
              children: [
                // Champion celebration section
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.winnerColor.withValues(alpha: 0.4),
                          AppTheme.winnerColor.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Trophy icon
                        const Icon(
                          Icons.emoji_events,
                          size: 60,
                          color: AppTheme.winnerColor,
                        ),
                        const SizedBox(height: 8),
                        // Champion title
                        const Text(
                          'CHAMPION',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Winner photo
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white,
                              width: 5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.winnerColor.withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: hasPhoto
                              ? Image.file(
                                  File(winner.photoPath),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: AppTheme.backgroundColor,
                                  child: const Icon(
                                    Icons.directions_car,
                                    size: 80,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),
                        // Winner name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            winner.name,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats section
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8, bottom: 12),
                          child: Text(
                            'TOURNAMENT RESULTS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Expanded(
                          child: statsAsync.when(
                            data: (stats) {
                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: stats.length,
                                itemBuilder: (context, index) {
                                  final stat = stats[index];
                                  final isChampion = stat.car.id == winner.id;
                                  return _StatRow(
                                    stat: stat,
                                    rank: index + 1,
                                    isChampion: isChampion,
                                  );
                                },
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (_, __) => const Center(
                              child: Text('Error loading stats'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                context.go('/tournament/$tournamentId'),
                            icon: const Icon(Icons.list),
                            label: const Text('VIEW MATCHES'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.go('/'),
                            icon: const Icon(Icons.home),
                            label: const Text('HOME'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final TournamentCarStats stat;
  final int rank;
  final bool isChampion;

  const _StatRow({
    required this.stat,
    required this.rank,
    required this.isChampion,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        stat.car.photoPath.isNotEmpty && File(stat.car.photoPath).existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isChampion
            ? AppTheme.winnerColor.withValues(alpha: 0.2)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: isChampion
            ? Border.all(color: AppTheme.winnerColor, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 32,
            child: Text(
              isChampion ? '' : '#$rank',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          // Trophy for champion
          if (isChampion) ...[
            const Icon(
              Icons.emoji_events,
              color: AppTheme.winnerColor,
              size: 24,
            ),
            const SizedBox(width: 8),
          ],
          // Car photo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isChampion
                  ? Border.all(color: AppTheme.winnerColor, width: 2)
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: hasPhoto
                ? Image.file(File(stat.car.photoPath), fit: BoxFit.cover)
                : Container(
                    color: AppTheme.backgroundColor,
                    child: const Icon(Icons.directions_car, size: 20),
                  ),
          ),
          const SizedBox(width: 12),
          // Car name
          Expanded(
            child: Text(
              stat.car.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isChampion ? AppTheme.winnerColor : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Win/Loss stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${stat.wins}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  ' W  ',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${stat.losses}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.errorColor,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  ' L',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
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

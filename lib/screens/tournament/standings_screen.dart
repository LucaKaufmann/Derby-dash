import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/tournament.dart';
import '../../providers/tournament_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/car_photo_frame.dart';

/// Standings screen for round robin tournaments showing all cars ranked by score.
class StandingsScreen extends ConsumerWidget {
  final int tournamentId;

  const StandingsScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentAsync = ref.watch(tournamentProvider(tournamentId));
    final statsAsync = ref.watch(tournamentStatsProvider(tournamentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('STANDINGS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: tournamentAsync.when(
        data: (tournament) {
          if (tournament == null) {
            return const Center(child: Text('Tournament not found'));
          }

          return Column(
            children: [
              // Status banner
              _StatusBanner(tournament: tournament),

              // Column headers
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: AppTheme.surfaceColor,
                child: Row(
                  children: [
                    const SizedBox(width: 40), // Rank column
                    const Expanded(
                      flex: 3,
                      child: Text(
                        'CAR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    _HeaderCell('W'),
                    _HeaderCell('L'),
                    _HeaderCell('WIN %'),
                    _HeaderCell('PTS'),
                  ],
                ),
              ),

              // Standings list
              Expanded(
                child: statsAsync.when(
                  data: (stats) {
                    if (stats.isEmpty) {
                      return const Center(
                        child: Text('No standings data available'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: stats.length,
                      itemBuilder: (context, index) {
                        final stat = stats[index];
                        return _StandingsRow(
                          stat: stat,
                          rank: index + 1,
                          isFirst: index == 0,
                          isSecond: index == 1,
                          isThird: index == 2,
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                ),
              ),

              // Legend
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.surfaceColor.withValues(alpha: 0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(
                      label: 'W = Wins',
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(width: 24),
                    _LegendItem(
                      label: 'L = Losses',
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(width: 24),
                    _LegendItem(
                      label: 'PTS = Points',
                      color: AppTheme.primaryColor,
                    ),
                  ],
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

class _HeaderCell extends StatelessWidget {
  final String label;

  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
          letterSpacing: 1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

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

class _StandingsRow extends StatelessWidget {
  final TournamentCarStats stat;
  final int rank;
  final bool isFirst;
  final bool isSecond;
  final bool isThird;

  const _StandingsRow({
    required this.stat,
    required this.rank,
    this.isFirst = false,
    this.isSecond = false,
    this.isThird = false,
  });

  Color? get _rankColor {
    if (isFirst) return AppTheme.winnerColor;
    if (isSecond) return Colors.grey[400];
    if (isThird) return Colors.orange[700];
    return null;
  }

  IconData? get _rankIcon {
    if (isFirst || isSecond || isThird) return Icons.emoji_events;
    return null;
  }

  int get _points => stat.wins * 3; // 3 points per win

  double get _winPercentage {
    final total = stat.wins + stat.losses;
    if (total == 0) return 0;
    return (stat.wins / total) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFirst
            ? AppTheme.winnerColor.withValues(alpha: 0.15)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: isFirst
            ? Border.all(color: AppTheme.winnerColor, width: 2)
            : isSecond || isThird
            ? Border.all(color: _rankColor!.withValues(alpha: 0.5), width: 1)
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: _rankIcon != null
                ? Icon(_rankIcon, color: _rankColor, size: 24)
                : Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),

          // Car photo and name
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CarPhotoFrame(
                  photoPath: stat.car.photoPath,
                  width: 44,
                  height: 44,
                  borderRadius: BorderRadius.circular(8),
                  border: isFirst
                      ? Border.all(color: AppTheme.winnerColor, width: 2)
                      : null,
                  imagePadding: 3,
                  imageFit: BoxFit.contain,
                  iconSize: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stat.car.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isFirst ? AppTheme.winnerColor : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Wins
          _StatCell(value: '${stat.wins}', color: AppTheme.successColor),

          // Losses
          _StatCell(value: '${stat.losses}', color: AppTheme.errorColor),

          // Win percentage
          _StatCell(
            value: '${_winPercentage.toStringAsFixed(0)}%',
            color: AppTheme.textSecondary,
          ),

          // Points
          _StatCell(
            value: '$_points',
            color: AppTheme.primaryColor,
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final Color color;
  final bool isBold;

  const _StatCell({
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

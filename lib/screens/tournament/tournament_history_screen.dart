import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/tournament.dart';
import '../../providers/tournament_provider.dart';
import '../../theme/app_theme.dart';

class TournamentHistoryScreen extends ConsumerWidget {
  const TournamentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentsAsync = ref.watch(completedTournamentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HISTORY'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: tournamentsAsync.when(
        data: (tournaments) {
          if (tournaments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tournaments yet!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete a tournament to see it here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          }

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tournaments.length,
                itemBuilder: (context, index) {
                  final tournament = tournaments[index];
                  return Dismissible(
                    key: Key('tournament_${tournament.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Tournament?'),
                              content: const Text(
                                'This will permanently delete this tournament and all its matches. This cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('CANCEL'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.errorColor,
                                  ),
                                  child: const Text('DELETE'),
                                ),
                              ],
                            ),
                          ) ??
                          false;

                      if (confirmed) {
                        // Delete before dismiss animation to avoid race condition
                        final service = ref.read(tournamentServiceProvider);
                        await service.deleteTournament(tournament.id);
                        ref.invalidate(completedTournamentsProvider);
                      }
                      return confirmed;
                    },
                    child: _TournamentHistoryCard(
                      tournament: tournament,
                      onTap: () => context.push('/tournament/${tournament.id}'),
                    ),
                  );
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _TournamentHistoryCard extends ConsumerWidget {
  final Tournament tournament;
  final VoidCallback onTap;

  const _TournamentHistoryCard({
    required this.tournament,
    required this.onTap,
  });

  String _getTournamentTypeLabel(TournamentType type) {
    switch (type) {
      case TournamentType.knockout:
        return 'KNOCKOUT';
      case TournamentType.doubleElimination:
        return 'DOUBLE ELIM';
      case TournamentType.roundRobin:
        return 'ROUND ROBIN';
      case TournamentType.groupKnockout:
        return 'GROUP + KO';
    }
  }

  Color _getTournamentTypeColor(TournamentType type) {
    switch (type) {
      case TournamentType.knockout:
        return AppTheme.primaryColor;
      case TournamentType.doubleElimination:
        return AppTheme.primaryColor;
      case TournamentType.roundRobin:
        return AppTheme.secondaryColor;
      case TournamentType.groupKnockout:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final winnerAsync = ref.watch(tournamentWinnerProvider(tournament.id));
    final participantCountAsync =
        ref.watch(tournamentParticipantCountProvider(tournament.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Winner card at top (match card style)
            winnerAsync.when(
              data: (winner) {
                if (winner == null) {
                  return const SizedBox.shrink();
                }
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.winnerColor.withValues(alpha: 0.15),
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.winnerColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Trophy icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.winnerColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: AppTheme.winnerColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Winner photo
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.winnerColor,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.winnerColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: winner.photoPath.isNotEmpty &&
                                File(winner.photoPath).existsSync()
                            ? Image.file(
                                File(winner.photoPath),
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppTheme.backgroundColor,
                                child: const Icon(
                                  Icons.directions_car,
                                  size: 28,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      // Winner info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CHAMPION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.winnerColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              winner.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 88,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Tournament info section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date and participant count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMM d, yyyy').format(tournament.date),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      participantCountAsync.when(
                        data: (count) => Text(
                          '$count cars competed',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  // Type badge and bracket/standings button
                  Row(
                    children: [
                      // Bracket button for knockout and double elimination tournaments
                      if (tournament.type == TournamentType.knockout ||
                          tournament.type == TournamentType.doubleElimination)
                        IconButton(
                          icon: const Icon(Icons.account_tree),
                          iconSize: 24,
                          tooltip: 'View Bracket',
                          color: AppTheme.primaryColor,
                          onPressed: () =>
                              context.push('/tournament/${tournament.id}/bracket'),
                        )
                      // Standings button for round robin tournaments
                      else if (tournament.type == TournamentType.roundRobin)
                        IconButton(
                          icon: const Icon(Icons.leaderboard),
                          iconSize: 24,
                          tooltip: 'View Standings',
                          color: AppTheme.primaryColor,
                          onPressed: () =>
                              context.push('/tournament/${tournament.id}/standings'),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getTournamentTypeColor(tournament.type)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getTournamentTypeLabel(tournament.type),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getTournamentTypeColor(tournament.type),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

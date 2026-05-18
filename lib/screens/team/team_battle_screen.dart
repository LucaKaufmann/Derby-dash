import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/car.dart';
import '../../data/models/match.dart';
import '../../data/models/tournament.dart';
import '../../providers/car_provider.dart';
import '../../providers/tournament_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/car_photo_frame.dart';

class TeamBattleScreen extends ConsumerStatefulWidget {
  final int tournamentId;

  const TeamBattleScreen({super.key, required this.tournamentId});

  @override
  ConsumerState<TeamBattleScreen> createState() => _TeamBattleScreenState();
}

class _TeamBattleScreenState extends ConsumerState<TeamBattleScreen> {
  int? _selectedWinnerId;
  bool _isSaving = false;

  void _selectWinner(Car winner) {
    if (_isSaving) return;

    setState(() {
      if (_selectedWinnerId == winner.id) {
        _selectedWinnerId = null;
      } else {
        _selectedWinnerId = winner.id;
      }
    });
  }

  Future<void> _confirmWinner(Match match) async {
    final winnerId = _selectedWinnerId;
    if (winnerId == null || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    await ref.read(tournamentServiceProvider).completeMatch(match.id, winnerId);

    ref.invalidate(tournamentProvider(widget.tournamentId));
    ref.invalidate(tournamentRoundsProvider(widget.tournamentId));
    ref.invalidate(currentRoundProvider(widget.tournamentId));
    ref.invalidate(roundMatchesProvider(match.round.value?.id ?? -1));
    ref.invalidate(completedTournamentsProvider);
    ref.invalidate(activeTournamentsProvider);
    ref.invalidate(carStatsProvider(winnerId));
    ref.invalidate(sortedCarsProvider);

    if (!mounted) return;
    setState(() {
      _selectedWinnerId = null;
      _isSaving = false;
    });
  }

  void _clearSelection() {
    if (_isSaving) return;
    setState(() {
      _selectedWinnerId = null;
    });
  }

  void _goBack() {
    if (_isSaving) return;
    context.go('/play');
  }

  @override
  Widget build(BuildContext context) {
    final tournamentAsync = ref.watch(tournamentProvider(widget.tournamentId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TEAM BATTLE'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _isSaving ? null : _goBack,
          ),
          actions: [
            if (_selectedWinnerId != null && !_isSaving)
              TextButton.icon(
                onPressed: _clearSelection,
                icon: const Icon(Icons.close),
                label: const Text('CLEAR'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
        body: tournamentAsync.when(
          data: (tournament) {
            if (tournament == null) {
              return const Center(child: Text('Team Battle not found'));
            }

            if (tournament.status == TournamentStatus.completed) {
              return _TeamVictoryView(tournament: tournament);
            }

            final roundAsync = ref.watch(
              currentRoundProvider(widget.tournamentId),
            );
            return roundAsync.when(
              data: (round) {
                if (round == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final matchesAsync = ref.watch(roundMatchesProvider(round.id));
                return matchesAsync.when(
                  data: (matches) {
                    if (matches.isEmpty) {
                      return const Center(child: Text('No race ready'));
                    }

                    final matchAsync = ref.watch(
                      matchDetailsProvider(matches.first.id),
                    );
                    return matchAsync.when(
                      data: (match) {
                        if (match == null) {
                          return const Center(child: Text('Race not found'));
                        }
                        return _BattleRaceView(
                          tournament: tournament,
                          match: match,
                          selectedWinnerId: _selectedWinnerId,
                          isSaving: _isSaving,
                          onWinnerSelected: _selectWinner,
                          onConfirmWinner: () => _confirmWinner(match),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(child: Text('Error: $error')),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

class _BattleRaceView extends StatelessWidget {
  final Tournament tournament;
  final Match match;
  final int? selectedWinnerId;
  final bool isSaving;
  final ValueChanged<Car> onWinnerSelected;
  final VoidCallback onConfirmWinner;

  const _BattleRaceView({
    required this.tournament,
    required this.match,
    required this.selectedWinnerId,
    required this.isSaving,
    required this.onWinnerSelected,
    required this.onConfirmWinner,
  });

  @override
  Widget build(BuildContext context) {
    final carA = match.carA.value;
    final carB = match.carB.value;

    if (carA == null || carB == null) {
      return const Center(child: Text('Cars not found'));
    }

    return SafeArea(
      child: Column(
        children: [
          _ScoreHeader(tournament: tournament),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
            child: Text(
              'TAP THE WINNER',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: _TeamRaceCarButton(
              car: carA,
              teamLabel: tournament.teamAName ?? 'Red Team',
              teamColor: AppTheme.errorColor,
              selectedWinnerId: selectedWinnerId,
              isSaving: isSaving,
              onTap: () => onWinnerSelected(carA),
            ),
          ),
          SizedBox(
            height: 100,
            width: double.infinity,
            child: Center(
              child: selectedWinnerId != null
                  ? ElevatedButton.icon(
                      onPressed: isSaving ? null : onConfirmWinner,
                      icon: isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check, size: 32),
                      label: Text(
                        isSaving ? 'SAVING...' : 'CONFIRM WINNER',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.textSecondary,
                          width: 3,
                        ),
                      ),
                      child: Text(
                        'VS',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
            ),
          ),
          Expanded(
            child: _TeamRaceCarButton(
              car: carB,
              teamLabel: tournament.teamBName ?? 'Blue Team',
              teamColor: AppTheme.secondaryColor,
              selectedWinnerId: selectedWinnerId,
              isSaving: isSaving,
              onTap: () => onWinnerSelected(carB),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  final Tournament tournament;

  const _ScoreHeader({required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppTheme.surfaceColor,
      child: Row(
        children: [
          Expanded(
            child: _ScoreBlock(
              label: tournament.teamAName ?? 'Red Team',
              score: tournament.teamAScore,
              color: AppTheme.errorColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              'TO ${tournament.targetScore}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _ScoreBlock(
              label: tournament.teamBName ?? 'Blue Team',
              score: tournament.teamBScore,
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBlock extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _ScoreBlock({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '$score',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _TeamRaceCarButton extends StatelessWidget {
  final Car car;
  final String teamLabel;
  final Color teamColor;
  final int? selectedWinnerId;
  final bool isSaving;
  final VoidCallback onTap;

  const _TeamRaceCarButton({
    required this.car,
    required this.teamLabel,
    required this.teamColor,
    required this.selectedWinnerId,
    required this.isSaving,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedWinnerId == car.id;
    final isLoser = selectedWinnerId != null && selectedWinnerId != car.id;
    final cardColor = isSelected
        ? AppTheme.successColor.withValues(alpha: 0.25)
        : isLoser
        ? AppTheme.surfaceColor.withValues(alpha: 0.3)
        : teamColor.withValues(alpha: 0.2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isLoser ? 0.45 : 1,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isSaving ? null : onTap,
            borderRadius: BorderRadius.circular(24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.successColor
                      : isLoser
                      ? AppTheme.textSecondary.withValues(alpha: 0.3)
                      : teamColor,
                  width: isSelected ? 6 : 3,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    teamLabel.toUpperCase(),
                    style: TextStyle(
                      color: teamColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: CarPhotoFrame(
                      photoPath: car.photoPath,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: BorderRadius.circular(18),
                      imagePadding: 10,
                      imageFit: BoxFit.contain,
                      iconSize: 90,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.emoji_events,
                            color: AppTheme.winnerColor,
                            size: 32,
                          ),
                        ),
                      Flexible(
                        child: Text(
                          car.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: isSelected
                                    ? AppTheme.winnerColor
                                    : isLoser
                                    ? AppTheme.textSecondary
                                    : null,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (!isSelected && !isLoser)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'TAP TO SELECT',
                        style: TextStyle(
                          color: teamColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamVictoryView extends StatelessWidget {
  final Tournament tournament;

  const _TeamVictoryView({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final redWon = tournament.teamAScore > tournament.teamBScore;
    final winnerName = redWon
        ? tournament.teamAName ?? 'Red Team'
        : tournament.teamBName ?? 'Blue Team';
    final winnerColor = redWon ? AppTheme.errorColor : AppTheme.secondaryColor;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.emoji_events, size: 110, color: winnerColor),
              const SizedBox(height: 24),
              Text(
                '$winnerName Wins!',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: winnerColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '${tournament.teamAScore} - ${tournament.teamBScore}',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 44),
              ElevatedButton.icon(
                onPressed: () => context.go('/team-battle/setup'),
                icon: const Icon(Icons.groups),
                label: const Text('NEW BATTLE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: winnerColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('HOME'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

  Future<void> _confirmWinner(Match match, Car winner) async {
    if (_isSaving) return;

    setState(() {
      _selectedWinnerId = winner.id;
      _isSaving = true;
    });

    await ref
        .read(tournamentServiceProvider)
        .completeMatch(match.id, winner.id);

    ref.invalidate(tournamentProvider(widget.tournamentId));
    ref.invalidate(tournamentRoundsProvider(widget.tournamentId));
    ref.invalidate(currentRoundProvider(widget.tournamentId));
    ref.invalidate(roundMatchesProvider(match.round.value?.id ?? -1));
    ref.invalidate(completedTournamentsProvider);
    ref.invalidate(activeTournamentsProvider);
    ref.invalidate(carStatsProvider(winner.id));
    ref.invalidate(sortedCarsProvider);

    if (!mounted) return;
    setState(() {
      _selectedWinnerId = null;
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tournamentAsync = ref.watch(tournamentProvider(widget.tournamentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('TEAM BATTLE'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
        ),
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
                        onWinnerSelected: (winner) =>
                            _confirmWinner(match, winner),
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
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

  const _BattleRaceView({
    required this.tournament,
    required this.match,
    required this.selectedWinnerId,
    required this.isSaving,
    required this.onWinnerSelected,
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
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.textSecondary, width: 2),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : Text('VS', style: Theme.of(context).textTheme.headlineMedium),
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
    final isDisabled = isSaving && !isSelected;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isDisabled ? 0.45 : 1,
      child: Material(
        color: isSelected
            ? AppTheme.successColor.withValues(alpha: 0.25)
            : teamColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: isSaving ? null : onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? AppTheme.successColor : teamColor,
                width: isSelected ? 6 : 4,
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
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  car.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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

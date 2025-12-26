import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/car.dart';
import '../../data/models/match.dart';
import '../../data/models/round.dart';
import '../../data/models/tournament.dart';
import '../../providers/tournament_provider.dart';
import '../../theme/app_theme.dart';

class MatchScreen extends ConsumerStatefulWidget {
  final int tournamentId;
  final int matchId;

  const MatchScreen({
    super.key,
    required this.tournamentId,
    required this.matchId,
  });

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  int? _selectedWinnerId;
  bool _isConfirming = false;

  void _selectWinner(Car winner) {
    if (_isConfirming) return;

    setState(() {
      // Toggle selection if tapping same car, otherwise select new one
      if (_selectedWinnerId == winner.id) {
        _selectedWinnerId = null;
      } else {
        _selectedWinnerId = winner.id;
      }
    });
  }

  Future<void> _confirmWinner([Match? currentMatch]) async {
    if (_selectedWinnerId == null || _isConfirming) return;

    setState(() {
      _isConfirming = true;
    });

    final service = ref.read(tournamentServiceProvider);

    // Check if this is a series match
    final isSeries = currentMatch != null && currentMatch.seriesLength > 1;

    if (isSeries) {
      // Record a single game win in the series
      await service.recordSeriesGameWin(widget.matchId, _selectedWinnerId!);

      // Refresh match data
      ref.invalidate(matchDetailsProvider(widget.matchId));

      // Get updated match to check if series is complete
      final updatedMatch = await service.getMatch(widget.matchId);

      if (updatedMatch != null && updatedMatch.isSeriesComplete) {
        // Series is complete, navigate
        ref.invalidate(tournamentRoundsProvider(widget.tournamentId));
        ref.invalidate(tournamentProvider(widget.tournamentId));
        ref.invalidate(tournamentWinnerProvider(widget.tournamentId));

        if (mounted) {
          final tournament = await service.getTournament(widget.tournamentId);

          if (tournament?.status == TournamentStatus.completed) {
            context.go('/tournament/${widget.tournamentId}/champion');
          } else {
            context.go('/tournament/${widget.tournamentId}');
          }
        }
      } else {
        // Series not complete, show feedback and reset for next game
        if (mounted) {
          final gameNumber = (updatedMatch?.carASeriesWins ?? 0) +
              (updatedMatch?.carBSeriesWins ?? 0);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Game $gameNumber recorded!'),
              duration: const Duration(seconds: 1),
              backgroundColor: AppTheme.successColor,
            ),
          );

          setState(() {
            _selectedWinnerId = null;
            _isConfirming = false;
          });
        }
      }
    } else {
      // Standard single-game match
      await service.completeMatch(widget.matchId, _selectedWinnerId!);

      // Invalidate providers to refresh data
      ref.invalidate(matchDetailsProvider(widget.matchId));
      ref.invalidate(tournamentRoundsProvider(widget.tournamentId));
      ref.invalidate(tournamentProvider(widget.tournamentId));
      ref.invalidate(tournamentWinnerProvider(widget.tournamentId));

      if (mounted) {
        final tournament = await service.getTournament(widget.tournamentId);

        if (tournament?.status == TournamentStatus.completed) {
          context.go('/tournament/${widget.tournamentId}/champion');
        } else {
          context.go('/tournament/${widget.tournamentId}');
        }
      }
    }
  }

  void _clearSelection() {
    if (_isConfirming) return;
    setState(() {
      _selectedWinnerId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchAsync = ref.watch(matchDetailsProvider(widget.matchId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: matchAsync.when(
        data: (match) {
          if (match == null) {
            return const Center(child: Text('Match not found'));
          }

          final carA = match.carA.value;
          final carB = match.carB.value;
          final round = match.round.value;

          if (carA == null || carB == null) {
            return const Center(child: Text('Cars not found'));
          }

          final isGrandFinals = round?.bracketType == BracketType.grandFinals ||
              round?.knockoutRoundName == 'gf';
          final colorA = isGrandFinals
              ? AppTheme.grandFinalsGold
              : AppTheme.primaryColor;
          final colorB = isGrandFinals
              ? AppTheme.grandFinalsPurple
              : AppTheme.secondaryColor;

          // Series info
          final isSeries = match.seriesLength > 1;
          final currentGame = match.carASeriesWins + match.carBSeriesWins + 1;

          return SafeArea(
            child: Column(
              children: [
                // Header with back button and round indicator
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 32),
                        onPressed: _isConfirming
                            ? null
                            : () => context.go('/tournament/${widget.tournamentId}'),
                      ),
                      Expanded(
                        child: _RoundIndicator(
                          round: round,
                          isGrandFinals: isGrandFinals,
                          seriesLength: match.seriesLength,
                        ),
                      ),
                      if (_selectedWinnerId != null && !_isConfirming)
                        TextButton.icon(
                          onPressed: _clearSelection,
                          icon: const Icon(Icons.close),
                          label: const Text('CLEAR'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.textSecondary,
                          ),
                        )
                      else
                        const SizedBox(width: 48), // Balance the layout
                    ],
                  ),
                ),

                // Series score header (when Best-of-X)
                if (isSeries)
                  _SeriesScoreHeader(
                    carA: carA,
                    carB: carB,
                    carAWins: match.carASeriesWins,
                    carBWins: match.carBSeriesWins,
                    currentGame: currentGame,
                    seriesLength: match.seriesLength,
                    colorA: colorA,
                    colorB: colorB,
                  ),

                // Car A (top half)
                Expanded(
                  child: _CarPanel(
                    car: carA,
                    isSelected: _selectedWinnerId == carA.id,
                    isLoser: _selectedWinnerId != null &&
                        _selectedWinnerId != carA.id,
                    onTap: () => _selectWinner(carA),
                    color: colorA,
                  ),
                ),

                // VS Divider / Confirm Button
                Container(
                  height: 100,
                  width: double.infinity,
                  color: AppTheme.backgroundColor,
                  child: Center(
                    child: _selectedWinnerId != null
                        ? ElevatedButton.icon(
                            onPressed: _isConfirming
                                ? null
                                : () => _confirmWinner(match),
                            icon: _isConfirming
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
                              _isConfirming
                                  ? 'SAVING...'
                                  : isSeries
                                      ? 'CONFIRM GAME $currentGame'
                                      : 'CONFIRM WINNER',
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
                              isSeries ? 'GAME $currentGame' : 'VS',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                  ),
                ),

                // Car B (bottom half)
                Expanded(
                  child: _CarPanel(
                    car: carB,
                    isSelected: _selectedWinnerId == carB.id,
                    isLoser: _selectedWinnerId != null &&
                        _selectedWinnerId != carB.id,
                    onTap: () => _selectWinner(carB),
                    color: colorB,
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

class _CarPanel extends StatelessWidget {
  final Car car;
  final bool isSelected;
  final bool isLoser;
  final VoidCallback onTap;
  final Color color;

  const _CarPanel({
    required this.car,
    required this.isSelected,
    required this.isLoser,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.successColor.withOpacity(0.3)
              : isLoser
                  ? AppTheme.surfaceColor.withOpacity(0.3)
                  : color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppTheme.successColor
                : isLoser
                    ? AppTheme.textSecondary.withOpacity(0.3)
                    : color,
            width: isSelected ? 6 : 3,
          ),
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isLoser ? 0.4 : 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Car photo
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.successColor.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ]
                          : null,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: car.photoPath.isNotEmpty &&
                            File(car.photoPath).existsSync()
                        ? Image.file(
                            File(car.photoPath),
                            fit: BoxFit.contain,
                          )
                        : const Center(
                            child: Icon(
                              Icons.directions_car,
                              size: 100,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                  ),
                ),
              ),

              // Car name
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.emoji_events,
                          color: AppTheme.winnerColor,
                          size: 36,
                        ),
                      ),
                    Flexible(
                      child: Text(
                        car.name,
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: isSelected
                                      ? AppTheme.winnerColor
                                      : isLoser
                                          ? AppTheme.textSecondary
                                          : null,
                                  decoration:
                                      isLoser ? TextDecoration.lineThrough : null,
                                ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Tap hint
              if (!isSelected && !isLoser)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'TAP TO SELECT',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIndicator extends StatelessWidget {
  final Round? round;
  final bool isGrandFinals;
  final int seriesLength;

  const _RoundIndicator({
    required this.round,
    required this.isGrandFinals,
    this.seriesLength = 1,
  });

  String _getRoundLabel() {
    if (round == null) return '';

    if (isGrandFinals) {
      return '🏆 GRAND FINALS 🏆';
    }

    switch (round!.bracketType) {
      case BracketType.winners:
        return 'Round ${round!.roundNumber}';
      case BracketType.losers:
        return 'Losers Round ${round!.roundNumber}';
      case BracketType.grandFinals:
        return '🏆 GRAND FINALS 🏆';
      case BracketType.knockout:
        // For groupKnockout knockout phase
        final roundName = round!.knockoutRoundName;
        switch (roundName) {
          case 'gf':
            return '🏆 GRAND FINALS 🏆';
          case 'sf':
            return 'SEMIFINALS';
          case 'qf':
            return 'QUARTERFINALS';
          case 'ro16':
            return 'ROUND OF 16';
          default:
            return 'Round ${round!.roundNumber}';
        }
      case BracketType.groupA:
      case BracketType.groupB:
      case BracketType.groupC:
      case BracketType.groupD:
      case BracketType.groupE:
      case BracketType.groupF:
      case BracketType.groupG:
      case BracketType.groupH:
        final groupLetter = String.fromCharCode('A'.codeUnitAt(0) + (round!.groupIndex ?? 0));
        return 'GROUP $groupLetter';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (round == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: isGrandFinals
                ? LinearGradient(
                    colors: [
                      AppTheme.grandFinalsGold.withOpacity(0.3),
                      AppTheme.grandFinalsPurple.withOpacity(0.3),
                    ],
                  )
                : null,
            color: isGrandFinals ? null : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: isGrandFinals
                ? Border.all(color: AppTheme.grandFinalsGold, width: 2)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getRoundLabel(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isGrandFinals ? 20 : 16,
                  fontWeight: FontWeight.bold,
                  color: isGrandFinals ? AppTheme.grandFinalsGold : AppTheme.textPrimary,
                  letterSpacing: isGrandFinals ? 2 : 1,
                ),
              ),
              if (seriesLength > 1) ...[
                const SizedBox(height: 4),
                Text(
                  'BEST OF $seriesLength',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isGrandFinals
                        ? AppTheme.grandFinalsGold.withValues(alpha: 0.8)
                        : AppTheme.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SeriesScoreHeader extends StatelessWidget {
  final Car carA;
  final Car carB;
  final int carAWins;
  final int carBWins;
  final int currentGame;
  final int seriesLength;
  final Color colorA;
  final Color colorB;

  const _SeriesScoreHeader({
    required this.carA,
    required this.carB,
    required this.carAWins,
    required this.carBWins,
    required this.currentGame,
    required this.seriesLength,
    required this.colorA,
    required this.colorB,
  });

  @override
  Widget build(BuildContext context) {
    final winsNeeded = (seriesLength + 1) ~/ 2;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textSecondary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Score row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Car A score
              Expanded(
                child: Column(
                  children: [
                    Text(
                      carA.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorA,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: carAWins >= winsNeeded
                            ? AppTheme.successColor.withValues(alpha: 0.2)
                            : colorA.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: carAWins >= winsNeeded ? AppTheme.successColor : colorA,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '$carAWins',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: carAWins >= winsNeeded ? AppTheme.successColor : colorA,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Dash separator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '-',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),

              // Car B score
              Expanded(
                child: Column(
                  children: [
                    Text(
                      carB.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorB,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: carBWins >= winsNeeded
                            ? AppTheme.successColor.withValues(alpha: 0.2)
                            : colorB.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: carBWins >= winsNeeded ? AppTheme.successColor : colorB,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '$carBWins',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: carBWins >= winsNeeded ? AppTheme.successColor : colorB,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // First to X wins indicator
          Text(
            'First to $winsNeeded wins',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

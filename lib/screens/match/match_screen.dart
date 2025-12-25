import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/car.dart';
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

  Future<void> _confirmWinner() async {
    if (_selectedWinnerId == null || _isConfirming) return;

    setState(() {
      _isConfirming = true;
    });

    // Complete match in database
    await ref
        .read(tournamentServiceProvider)
        .completeMatch(widget.matchId, _selectedWinnerId!);

    // Invalidate providers to refresh data
    ref.invalidate(matchDetailsProvider(widget.matchId));
    ref.invalidate(tournamentRoundsProvider(widget.tournamentId));
    ref.invalidate(tournamentProvider(widget.tournamentId));
    ref.invalidate(tournamentWinnerProvider(widget.tournamentId));

    if (mounted) {
      // Check if tournament is now completed
      final tournament = await ref
          .read(tournamentServiceProvider)
          .getTournament(widget.tournamentId);

      if (tournament?.status == TournamentStatus.completed) {
        // Navigate to champion screen
        context.go('/tournament/${widget.tournamentId}/champion');
      } else {
        // Navigate back to tournament dashboard
        context.go('/tournament/${widget.tournamentId}');
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

          if (carA == null || carB == null) {
            return const Center(child: Text('Cars not found'));
          }

          return SafeArea(
            child: Column(
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 32),
                        onPressed: _isConfirming
                            ? null
                            : () => context.go('/tournament/${widget.tournamentId}'),
                      ),
                      if (_selectedWinnerId != null && !_isConfirming)
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
                ),

                // Car A (top half)
                Expanded(
                  child: _CarPanel(
                    car: carA,
                    isSelected: _selectedWinnerId == carA.id,
                    isLoser: _selectedWinnerId != null &&
                        _selectedWinnerId != carA.id,
                    onTap: () => _selectWinner(carA),
                    color: AppTheme.primaryColor,
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
                            onPressed: _isConfirming ? null : _confirmWinner,
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
                              _isConfirming ? 'SAVING...' : 'CONFIRM WINNER',
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

                // Car B (bottom half)
                Expanded(
                  child: _CarPanel(
                    car: carB,
                    isSelected: _selectedWinnerId == carB.id,
                    isLoser: _selectedWinnerId != null &&
                        _selectedWinnerId != carB.id,
                    onTap: () => _selectWinner(carB),
                    color: AppTheme.secondaryColor,
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/car.dart';
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

class _MatchScreenState extends ConsumerState<MatchScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedWinnerId;
  bool _isAnimating = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectWinner(Car winner) async {
    if (_isAnimating) return;

    setState(() {
      _selectedWinnerId = winner.id;
      _isAnimating = true;
    });

    // Play winner animation
    await _animationController.forward();

    // Complete match in database
    await ref
        .read(tournamentServiceProvider)
        .completeMatch(widget.matchId, winner.id);

    // Invalidate providers to refresh data
    ref.invalidate(matchDetailsProvider(widget.matchId));
    ref.invalidate(tournamentRoundsProvider(widget.tournamentId));
    ref.invalidate(tournamentProvider(widget.tournamentId));

    // Wait a bit, then navigate back
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      context.go('/tournament/${widget.tournamentId}');
    }
  }

  void _undoSelection() {
    if (!_isAnimating || _selectedWinnerId == null) return;

    _animationController.reverse();
    setState(() {
      _selectedWinnerId = null;
      _isAnimating = false;
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
                // Header with back and undo
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 32),
                        onPressed: () =>
                            context.go('/tournament/${widget.tournamentId}'),
                      ),
                      if (_isAnimating)
                        TextButton.icon(
                          onPressed: _undoSelection,
                          icon: const Icon(Icons.undo),
                          label: const Text('UNDO'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
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
                    scaleAnimation: _scaleAnimation,
                    onTap: () => _selectWinner(carA),
                    color: AppTheme.primaryColor,
                  ),
                ),

                // VS Divider
                Container(
                  height: 80,
                  width: double.infinity,
                  color: AppTheme.backgroundColor,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isAnimating
                              ? AppTheme.successColor
                              : AppTheme.textSecondary,
                          width: 3,
                        ),
                      ),
                      child: Text(
                        _isAnimating ? 'WINNER!' : 'VS',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: _isAnimating
                                  ? AppTheme.successColor
                                  : AppTheme.textPrimary,
                            ),
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
                    scaleAnimation: _scaleAnimation,
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
  final Animation<double> scaleAnimation;
  final VoidCallback onTap;
  final Color color;

  const _CarPanel({
    required this.car,
    required this.isSelected,
    required this.isLoser,
    required this.scaleAnimation,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    Widget panel = GestureDetector(
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
                    'TAP TO SELECT WINNER',
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

    if (isSelected) {
      return AnimatedBuilder(
        animation: scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: panel,
          );
        },
      );
    }

    return panel;
  }
}

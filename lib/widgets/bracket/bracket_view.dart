import 'package:flutter/material.dart';
import 'package:derby_dash/data/models/match.dart';
import 'package:derby_dash/data/models/round.dart';
import 'package:derby_dash/theme/app_theme.dart';
import 'bracket_position.dart';
import 'bracket_painter.dart';
import 'bracket_match_card.dart';

/// Main bracket visualization widget.
/// Displays tournament bracket with matches and connecting lines.
class BracketView extends StatelessWidget {
  final List<Round> rounds;
  final Map<int, List<Match>> matchesByRound;
  final void Function(Match match)? onMatchTap;

  const BracketView({
    super.key,
    required this.rounds,
    required this.matchesByRound,
    this.onMatchTap,
  });

  @override
  Widget build(BuildContext context) {
    if (rounds.isEmpty) {
      return const Center(
        child: Text(
          'No bracket data available',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    // Sort rounds by round number and get matches in order
    final sortedRounds = List<Round>.from(rounds)
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

    final roundMatches = <List<Match>>[];
    for (final round in sortedRounds) {
      final matches = matchesByRound[round.id] ?? [];
      roundMatches.add(matches);
    }

    if (roundMatches.isEmpty || roundMatches.every((m) => m.isEmpty)) {
      return const Center(
        child: Text(
          'No matches in bracket',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    final calculator = BracketLayoutCalculator(roundMatches: roundMatches);
    final positions = calculator.calculatePositions();
    final connections = calculator.calculateConnections();
    final config = calculator.config;

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(100),
      minScale: 0.5,
      maxScale: 2.0,
      child: SizedBox(
        width: calculator.totalWidth,
        height: calculator.totalHeight + 40, // Extra space for round labels
        child: Stack(
          children: [
            // Round labels at the top
            ..._buildRoundLabels(sortedRounds, config),

            // Connection lines (behind match cards)
            Positioned.fill(
              top: 40, // Offset for round labels
              child: CustomPaint(
                painter: BracketPainter(connections: connections),
              ),
            ),

            // Match cards
            ...positions.map((pos) => Positioned(
                  left: pos.x,
                  top: pos.y + 40, // Offset for round labels
                  child: BracketMatchCard(
                    match: pos.match,
                    width: config.cardWidth,
                    height: config.cardHeight,
                    onTap: onMatchTap != null ? () => onMatchTap!(pos.match) : null,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRoundLabels(List<Round> sortedRounds, BracketLayoutConfig config) {
    return List.generate(sortedRounds.length, (index) {
      final x = config.padding + index * config.roundWidth;
      final label = _getRoundLabel(index, sortedRounds.length);

      return Positioned(
        left: x,
        top: 8,
        width: config.cardWidth,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
          ),
        ),
      );
    });
  }

  String _getRoundLabel(int roundIndex, int totalRounds) {
    // Name rounds from the end (Final, Semifinals, etc.)
    final roundsFromEnd = totalRounds - roundIndex;

    switch (roundsFromEnd) {
      case 1:
        return 'FINAL';
      case 2:
        return 'SEMIFINALS';
      case 3:
        return 'QUARTERFINALS';
      case 4:
        return 'ROUND OF 16';
      case 5:
        return 'ROUND OF 32';
      case 6:
        return 'ROUND OF 64';
      default:
        return 'ROUND ${roundIndex + 1}';
    }
  }
}

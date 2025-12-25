import 'package:flutter/material.dart';
import 'package:derby_dash/data/models/match.dart';
import 'package:derby_dash/data/models/round.dart';
import 'package:derby_dash/theme/app_theme.dart';
import 'bracket_position.dart';
import 'bracket_painter.dart';
import 'bracket_match_card.dart';

/// Double elimination bracket view showing winners bracket,
/// losers bracket, and grand finals.
class DoubleBracketView extends StatelessWidget {
  final List<Round> rounds;
  final Map<int, List<Match>> matchesByRound;
  final void Function(Match match)? onMatchTap;

  const DoubleBracketView({
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

    // Separate rounds by bracket type
    final winnersRounds = rounds
        .where((r) => r.bracketType == BracketType.winners)
        .toList()
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

    final losersRounds = rounds
        .where((r) => r.bracketType == BracketType.losers)
        .toList()
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

    final grandFinalsRounds = rounds
        .where((r) => r.bracketType == BracketType.grandFinals)
        .toList();

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(100),
      minScale: 0.3,
      maxScale: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Winners Bracket
            if (winnersRounds.isNotEmpty) ...[
              _BracketSection(
                title: 'WINNERS BRACKET',
                titleColor: AppTheme.successColor,
                icon: Icons.emoji_events,
                rounds: winnersRounds,
                matchesByRound: matchesByRound,
                onMatchTap: onMatchTap,
              ),
              const SizedBox(height: 32),
            ],

            // Losers Bracket
            if (losersRounds.isNotEmpty) ...[
              _BracketSection(
                title: 'LOSERS BRACKET',
                titleColor: AppTheme.errorColor,
                icon: Icons.trending_down,
                rounds: losersRounds,
                matchesByRound: matchesByRound,
                onMatchTap: onMatchTap,
              ),
              const SizedBox(height: 32),
            ],

            // Grand Finals
            if (grandFinalsRounds.isNotEmpty) ...[
              _GrandFinalsSection(
                rounds: grandFinalsRounds,
                matchesByRound: matchesByRound,
                onMatchTap: onMatchTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Section for a single bracket (winners or losers).
class _BracketSection extends StatelessWidget {
  final String title;
  final Color titleColor;
  final IconData icon;
  final List<Round> rounds;
  final Map<int, List<Match>> matchesByRound;
  final void Function(Match match)? onMatchTap;

  const _BracketSection({
    required this.title,
    required this.titleColor,
    required this.icon,
    required this.rounds,
    required this.matchesByRound,
    this.onMatchTap,
  });

  @override
  Widget build(BuildContext context) {
    final roundMatches = <List<Match>>[];
    for (final round in rounds) {
      final matches = matchesByRound[round.id] ?? [];
      roundMatches.add(matches);
    }

    if (roundMatches.isEmpty || roundMatches.every((m) => m.isEmpty)) {
      return const SizedBox.shrink();
    }

    final calculator = BracketLayoutCalculator(roundMatches: roundMatches);
    final positions = calculator.calculatePositions();
    final connections = calculator.calculateConnections();
    final config = calculator.config;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: titleColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: titleColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Bracket content
        SizedBox(
          width: calculator.totalWidth,
          height: calculator.totalHeight + 40,
          child: Stack(
            children: [
              // Round labels
              ..._buildRoundLabels(rounds, config),

              // Connection lines
              Positioned.fill(
                top: 40,
                child: CustomPaint(
                  painter: BracketPainter(connections: connections),
                ),
              ),

              // Match cards
              ...positions.map((pos) => Positioned(
                    left: pos.x,
                    top: pos.y + 40,
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
      ],
    );
  }

  List<Widget> _buildRoundLabels(List<Round> sortedRounds, BracketLayoutConfig config) {
    return List.generate(sortedRounds.length, (index) {
      final x = config.padding + index * config.roundWidth;
      final label = 'ROUND ${index + 1}';

      return Positioned(
        left: x,
        top: 8,
        width: config.cardWidth,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
          ),
        ),
      );
    });
  }
}

/// Special section for Grand Finals.
class _GrandFinalsSection extends StatelessWidget {
  final List<Round> rounds;
  final Map<int, List<Match>> matchesByRound;
  final void Function(Match match)? onMatchTap;

  const _GrandFinalsSection({
    required this.rounds,
    required this.matchesByRound,
    this.onMatchTap,
  });

  @override
  Widget build(BuildContext context) {
    if (rounds.isEmpty) return const SizedBox.shrink();

    // Sort rounds by round number
    final sortedRounds = List<Round>.from(rounds)
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

    // Get all matches from grand finals rounds
    final allMatches = <Match>[];
    for (final round in sortedRounds) {
      final matches = matchesByRound[round.id] ?? [];
      allMatches.addAll(matches);
    }

    if (allMatches.isEmpty) return const SizedBox.shrink();

    // Check if there's a bracket reset (round 2)
    final hasBracketReset = sortedRounds.any((r) => r.roundNumber == 2);

    // Find the final winner (last completed match)
    Match? championMatch;
    for (final match in allMatches.reversed) {
      if (match.winner.value != null) {
        championMatch = match;
        break;
      }
    }

    // Tournament is complete if last round is complete
    final lastRound = sortedRounds.last;
    final tournamentComplete = lastRound.isCompleted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grand Finals header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.winnerColor.withValues(alpha: 0.3),
                AppTheme.primaryColor.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.winnerColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.military_tech,
                color: AppTheme.winnerColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                hasBracketReset ? 'GRAND FINALS (BRACKET RESET)' : 'GRAND FINALS',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.winnerColor,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Show all grand finals matches
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < allMatches.length; i++) ...[
              if (i > 0) ...[
                // Arrow between matches
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        color: AppTheme.winnerColor.withValues(alpha: 0.7),
                        size: 24,
                      ),
                      Text(
                        'RESET',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.errorColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Column(
                children: [
                  Text(
                    i == 0 ? 'Match 1' : 'Match 2',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: allMatches[i].winner.value != null
                              ? AppTheme.winnerColor.withValues(alpha: 0.4)
                              : AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: BracketMatchCard(
                      match: allMatches[i],
                      width: 200,
                      height: 90,
                      onTap: onMatchTap != null ? () => onMatchTap!(allMatches[i]) : null,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),

        // Champion indicator (only show when tournament is complete)
        if (tournamentComplete && championMatch != null) ...[
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.winnerColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.winnerColor,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: AppTheme.winnerColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CHAMPION: ${championMatch.winner.value?.name ?? 'Unknown'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.winnerColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

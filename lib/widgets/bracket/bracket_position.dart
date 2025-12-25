import 'package:derby_dash/data/models/match.dart';

/// Represents a match's position in the visual bracket layout.
class BracketPosition {
  final int roundIndex; // 0-indexed round number
  final int matchIndex; // Position within the round (0, 1, 2...)
  final Match match;
  final double x; // X position (left edge of card)
  final double y; // Y position (top edge of card)

  const BracketPosition({
    required this.roundIndex,
    required this.matchIndex,
    required this.match,
    required this.x,
    required this.y,
  });
}

/// Configuration for bracket layout dimensions.
class BracketLayoutConfig {
  final double cardWidth;
  final double cardHeight;
  final double horizontalSpacing; // Space between rounds
  final double verticalSpacing; // Space between matches in same round
  final double padding; // Outer padding

  const BracketLayoutConfig({
    this.cardWidth = 160.0,
    this.cardHeight = 72.0,
    this.horizontalSpacing = 80.0,
    this.verticalSpacing = 24.0,
    this.padding = 24.0,
  });

  /// Total width needed for one round column (card + spacing)
  double get roundWidth => cardWidth + horizontalSpacing;
}

/// Calculates bracket positions for all matches.
class BracketLayoutCalculator {
  final BracketLayoutConfig config;
  final List<List<Match>> roundMatches; // Matches grouped by round

  BracketLayoutCalculator({
    required this.roundMatches,
    this.config = const BracketLayoutConfig(),
  });

  /// Calculate total bracket width.
  double get totalWidth {
    if (roundMatches.isEmpty) return 0;
    return config.padding * 2 +
        roundMatches.length * config.cardWidth +
        (roundMatches.length - 1) * config.horizontalSpacing;
  }

  /// Calculate total bracket height based on actual match positions.
  double get totalHeight {
    if (roundMatches.isEmpty) return 0;

    // Find the maximum Y position used by any match
    double maxY = 0;
    for (int roundIdx = 0; roundIdx < roundMatches.length; roundIdx++) {
      final matches = roundMatches[roundIdx];
      for (int matchIdx = 0; matchIdx < matches.length; matchIdx++) {
        final y = _calculateMatchY(roundIdx, matchIdx);
        if (y > maxY) maxY = y;
      }
    }

    // Total height is the max Y position plus card height plus padding
    return maxY + config.cardHeight + config.padding;
  }

  /// Calculate Y position for a match.
  /// Round 1 matches are evenly spaced.
  /// Subsequent rounds are centered between their feeder matches.
  double _calculateMatchY(int roundIndex, int matchIndex) {
    if (roundIndex == 0) {
      // First round: evenly distributed
      return config.padding +
          matchIndex * (config.cardHeight + config.verticalSpacing);
    }

    // Center between the two feeder matches from previous round
    final feeder1Y = _calculateMatchY(roundIndex - 1, matchIndex * 2);
    final feeder2Y = _calculateMatchY(roundIndex - 1, matchIndex * 2 + 1);

    // Center this match vertically between its two feeders
    return (feeder1Y + feeder2Y) / 2;
  }

  /// Calculate X position for a match based on its round.
  double _calculateMatchX(int roundIndex) {
    return config.padding + roundIndex * config.roundWidth;
  }

  /// Generate all bracket positions.
  List<BracketPosition> calculatePositions() {
    final positions = <BracketPosition>[];

    for (int roundIdx = 0; roundIdx < roundMatches.length; roundIdx++) {
      final matches = roundMatches[roundIdx];
      for (int matchIdx = 0; matchIdx < matches.length; matchIdx++) {
        positions.add(BracketPosition(
          roundIndex: roundIdx,
          matchIndex: matchIdx,
          match: matches[matchIdx],
          x: _calculateMatchX(roundIdx),
          y: _calculateMatchY(roundIdx, matchIdx),
        ));
      }
    }

    return positions;
  }

  /// Get connection points for drawing lines between rounds.
  /// Returns pairs of (start point, end point) for each connection.
  List<BracketConnection> calculateConnections() {
    final connections = <BracketConnection>[];

    for (int roundIdx = 1; roundIdx < roundMatches.length; roundIdx++) {
      final matches = roundMatches[roundIdx];
      for (int matchIdx = 0; matchIdx < matches.length; matchIdx++) {
        // Each match in round N connects to 2 matches in round N-1
        final feeder1Idx = matchIdx * 2;
        final feeder2Idx = matchIdx * 2 + 1;

        // Check if feeder matches exist (handle odd bracket sizes)
        if (feeder1Idx < roundMatches[roundIdx - 1].length) {
          final fromY = _calculateMatchY(roundIdx - 1, feeder1Idx);
          final toY = _calculateMatchY(roundIdx, matchIdx);
          final fromX = _calculateMatchX(roundIdx - 1) + config.cardWidth;
          final toX = _calculateMatchX(roundIdx);

          connections.add(BracketConnection(
            fromX: fromX,
            fromY: fromY + config.cardHeight / 2,
            toX: toX,
            toY: toY + config.cardHeight / 2,
            isWinnerPath: roundMatches[roundIdx - 1][feeder1Idx].winner.value != null,
          ));
        }

        if (feeder2Idx < roundMatches[roundIdx - 1].length) {
          final fromY = _calculateMatchY(roundIdx - 1, feeder2Idx);
          final toY = _calculateMatchY(roundIdx, matchIdx);
          final fromX = _calculateMatchX(roundIdx - 1) + config.cardWidth;
          final toX = _calculateMatchX(roundIdx);

          connections.add(BracketConnection(
            fromX: fromX,
            fromY: fromY + config.cardHeight / 2,
            toX: toX,
            toY: toY + config.cardHeight / 2,
            isWinnerPath: roundMatches[roundIdx - 1][feeder2Idx].winner.value != null,
          ));
        }
      }
    }

    return connections;
  }
}

/// Represents a connection line between two matches in adjacent rounds.
class BracketConnection {
  final double fromX;
  final double fromY;
  final double toX;
  final double toY;
  final bool isWinnerPath; // True if the source match has a winner

  const BracketConnection({
    required this.fromX,
    required this.fromY,
    required this.toX,
    required this.toY,
    required this.isWinnerPath,
  });
}

import 'package:flutter/material.dart';
import 'package:derby_dash/theme/app_theme.dart';
import 'bracket_position.dart';

/// CustomPainter that draws connecting lines between bracket matches.
class BracketPainter extends CustomPainter {
  final List<BracketConnection> connections;

  BracketPainter({required this.connections});

  @override
  void paint(Canvas canvas, Size size) {
    for (final connection in connections) {
      _drawConnection(canvas, connection);
    }
  }

  void _drawConnection(Canvas canvas, BracketConnection connection) {
    final paint = Paint()
      ..color = connection.isWinnerPath
          ? AppTheme.successColor.withValues(alpha: 0.7)
          : AppTheme.textSecondary.withValues(alpha: 0.4)
      ..strokeWidth = connection.isWinnerPath ? 3.0 : 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Start from right edge of source match card
    final startX = connection.fromX;
    final startY = connection.fromY;

    // End at left edge of destination match card
    final endX = connection.toX;
    final endY = connection.toY;

    // Calculate midpoint for the horizontal connector
    final midX = startX + (endX - startX) / 2;

    // Draw path: horizontal -> vertical -> horizontal (bracket style)
    path.moveTo(startX, startY);
    path.lineTo(midX, startY);
    path.lineTo(midX, endY);
    path.lineTo(endX, endY);

    canvas.drawPath(path, paint);

    // Draw small circles at connection points for winner paths
    if (connection.isWinnerPath) {
      final dotPaint = Paint()
        ..color = AppTheme.successColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(startX, startY), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BracketPainter oldDelegate) {
    return connections != oldDelegate.connections;
  }
}

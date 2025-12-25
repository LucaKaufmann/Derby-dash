import 'dart:io';
import 'package:flutter/material.dart';
import 'package:derby_dash/data/models/match.dart';
import 'package:derby_dash/data/models/car.dart';
import 'package:derby_dash/theme/app_theme.dart';

/// Compact match card for bracket display.
/// Shows both cars with winner highlighted.
class BracketMatchCard extends StatelessWidget {
  final Match match;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const BracketMatchCard({
    super.key,
    required this.match,
    this.width = 160.0,
    this.height = 72.0,
    this.onTap,
  });

  bool get _isCompleted => match.winner.value != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _isCompleted
              ? AppTheme.successColor.withValues(alpha: 0.15)
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isCompleted
                ? AppTheme.successColor
                : AppTheme.primaryColor.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildMatchContent(),
      ),
    );
  }

  Widget _buildMatchContent() {
    final carA = match.carA.value;
    final carB = match.carB.value;
    final winner = match.winner.value;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CarRow(
          car: carA,
          isWinner: winner?.id == carA?.id,
          isLoser: _isCompleted && winner?.id != carA?.id,
        ),
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: AppTheme.textSecondary.withValues(alpha: 0.3),
        ),
        _CarRow(
          car: carB,
          isWinner: winner?.id == carB?.id,
          isLoser: _isCompleted && winner?.id != carB?.id,
        ),
      ],
    );
  }
}

/// Single row displaying a car in the match card.
class _CarRow extends StatelessWidget {
  final Car? car;
  final bool isWinner;
  final bool isLoser;

  const _CarRow({
    required this.car,
    required this.isWinner,
    required this.isLoser,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            _CarPhoto(car: car, size: 24),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                car?.name ?? 'TBD',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                  color: isLoser
                      ? AppTheme.textSecondary.withValues(alpha: 0.5)
                      : isWinner
                          ? AppTheme.successColor
                          : AppTheme.textPrimary,
                  decoration: isLoser ? TextDecoration.lineThrough : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isWinner)
              const Icon(
                Icons.check_circle,
                size: 14,
                color: AppTheme.successColor,
              ),
          ],
        ),
      ),
    );
  }
}

/// Small circular car photo.
class _CarPhoto extends StatelessWidget {
  final Car? car;
  final double size;

  const _CarPhoto({
    required this.car,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final photoPath = car?.photoPath;
    final hasPhoto = photoPath != null &&
        photoPath.isNotEmpty &&
        File(photoPath).existsSync();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.backgroundColor,
        border: Border.all(
          color: AppTheme.textSecondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasPhoto
          ? Image.file(
              File(photoPath),
              fit: BoxFit.cover,
            )
          : Icon(
              Icons.directions_car,
              size: size * 0.6,
              color: AppTheme.textSecondary,
            ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/tournament_service.dart';
import '../../theme/app_theme.dart';

class GroupStandingsTable extends StatelessWidget {
  final int groupIndex;
  final List<GroupStanding> standings;
  final bool showAdvancing;
  final int advancingCount;

  const GroupStandingsTable({
    super.key,
    required this.groupIndex,
    required this.standings,
    this.showAdvancing = true,
    this.advancingCount = 2,
  });

  String get groupName => String.fromCharCode('A'.codeUnitAt(0) + groupIndex);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              'GROUP $groupName',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.5,
                color: AppTheme.primaryColor,
              ),
            ),
          ),

          // Standings list
          ...standings.asMap().entries.map((entry) {
            final index = entry.key;
            final standing = entry.value;
            final isAdvancing = showAdvancing && index < advancingCount;

            return _StandingRow(
              standing: standing,
              position: index + 1,
              isAdvancing: isAdvancing,
              isLast: index == standings.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  final GroupStanding standing;
  final int position;
  final bool isAdvancing;
  final bool isLast;

  const _StandingRow({
    required this.standing,
    required this.position,
    required this.isAdvancing,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final car = standing.car;

    return Container(
      decoration: BoxDecoration(
        color: isAdvancing
            ? (position == 1
                ? AppTheme.winnerColor.withValues(alpha: 0.15)
                : AppTheme.winnerColor.withValues(alpha: 0.08))
            : null,
        border: !isLast
            ? Border(
                bottom: BorderSide(
                  color: AppTheme.surfaceColor,
                  width: 1,
                ),
              )
            : null,
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(12))
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Position indicator
          SizedBox(
            width: 28,
            child: Row(
              children: [
                if (position == 1 && isAdvancing)
                  const Icon(
                    Icons.emoji_events,
                    color: AppTheme.winnerColor,
                    size: 18,
                  )
                else
                  Text(
                    '$position',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isAdvancing
                          ? AppTheme.winnerColor
                          : AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          // Car photo
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 12),
            child: Stack(
              children: [
                // Photo or placeholder (clipped)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: car.photoPath.isNotEmpty && File(car.photoPath).existsSync()
                        ? Image.file(
                            File(car.photoPath),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppTheme.surfaceColor,
                            child: const Icon(
                              Icons.directions_car,
                              size: 20,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                  ),
                ),
                // Border overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: isAdvancing
                          ? Border.all(color: AppTheme.winnerColor, width: 2)
                          : Border.all(color: AppTheme.surfaceColor, width: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Car name
          Expanded(
            child: Text(
              car.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isAdvancing ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // W-L stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${standing.wins}W-${standing.losses}L',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Points
          Container(
            width: 40,
            alignment: Alignment.centerRight,
            child: Text(
              '${standing.points}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isAdvancing ? AppTheme.winnerColor : AppTheme.textSecondary,
              ),
            ),
          ),

          // Pts label
          const SizedBox(width: 4),
          const Text(
            'pts',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

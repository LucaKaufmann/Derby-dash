import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/tournament.dart';
import '../../theme/app_theme.dart';

class PlayModeScreen extends StatelessWidget {
  const PlayModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PLAY'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth >= 900
                ? 820.0
                : double.infinity;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'CHOOSE A GAME',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Quick modes first, bigger tournaments last.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _PlayModeCard(
                      icon: Icons.shuffle,
                      label: 'MYSTERY RACE',
                      subtitle: 'Random cars, quick races',
                      color: AppTheme.primaryColor,
                      onTap: () => context.push('/mystery-race'),
                    ),
                    const SizedBox(height: 16),
                    _PlayModeCard(
                      icon: Icons.flash_on,
                      label: 'TINY TOURNAMENT',
                      subtitle: 'Pick 4 cars, crown a champion',
                      color: AppTheme.winnerColor,
                      onTap: () => context.push(
                        '/tournament/setup/cars',
                        extra: {'type': TournamentType.tinyTournament},
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PlayModeCard(
                      icon: Icons.groups,
                      label: 'TEAM BATTLE',
                      subtitle: 'Red team vs blue team',
                      color: AppTheme.secondaryColor,
                      onTap: () => context.push('/team-battle/setup'),
                    ),
                    const SizedBox(height: 16),
                    _PlayModeCard(
                      icon: Icons.emoji_events,
                      label: 'TOURNAMENT',
                      subtitle: 'Knockout, round robin, and more',
                      color: AppTheme.surfaceColor,
                      onTap: () => context.push('/tournament/setup'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PlayModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PlayModeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 116),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.45), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, size: 34, color: color),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary.withValues(alpha: 0.8),
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

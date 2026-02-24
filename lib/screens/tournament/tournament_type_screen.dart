import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/tournament.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

/// Screen for selecting the tournament type.
/// First step in the tournament creation flow.
class TournamentTypeScreen extends ConsumerWidget {
  const TournamentTypeScreen({super.key});

  void _selectType(BuildContext context, TournamentType type) {
    if (type == TournamentType.groupKnockout) {
      // Group+Knockout needs best-of configuration first
      context.push('/tournament/setup/config');
    } else {
      // Other types go directly to car selection
      context.push('/tournament/setup/cars', extra: {'type': type});
    }
  }

  Widget _buildBasicTypeRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeCard(
            label: 'KNOCKOUT',
            subtitle: 'Single elimination bracket',
            description: 'Lose once and you\'re out!',
            icon: Icons.emoji_events,
            color: AppTheme.winnerColor,
            onTap: () => _selectType(context, TournamentType.knockout),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _TypeCard(
            label: 'DOUBLE ELIM',
            subtitle: 'Second chance bracket',
            description: 'Lose twice to be eliminated',
            icon: Icons.repeat,
            color: AppTheme.primaryColor,
            onTap: () => _selectType(context, TournamentType.doubleElimination),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final advancedMode = settingsAsync.valueOrNull?.advancedMode ?? false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('NEW TOURNAMENT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentPadding = constraints.maxWidth >= 900 ? 32.0 : 24.0;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Padding(
                  padding: EdgeInsets.all(contentPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'SELECT FORMAT',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose how your tournament will be played',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      Expanded(
                        child: Column(
                          children: [
                            // Basic tournament types (always visible)
                            // Use fixed height when not in advanced mode, expand when in advanced mode
                            if (advancedMode)
                              Expanded(
                                child: _buildBasicTypeRow(context),
                              )
                            else
                              SizedBox(
                                height: 240,
                                child: _buildBasicTypeRow(context),
                              ),
                            // Advanced tournament types (only visible in advanced mode)
                            if (advancedMode) ...[
                              const SizedBox(height: 16),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _TypeCard(
                                        label: 'ROUND ROBIN',
                                        subtitle: 'Everyone plays everyone',
                                        description: 'Most wins takes the crown',
                                        icon: Icons.loop,
                                        color: AppTheme.secondaryColor,
                                        onTap: () => _selectType(
                                          context,
                                          TournamentType.roundRobin,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _TypeCard(
                                        label: 'GROUP + KO',
                                        subtitle: 'Groups then playoffs',
                                        description: 'Best-of series in finals',
                                        icon: Icons.view_module,
                                        color: Colors.purple,
                                        onTap: () => _selectType(
                                          context,
                                          TournamentType.groupKnockout,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Large tappable card for tournament type selection.
class _TypeCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TypeCard({
    required this.label,
    required this.subtitle,
    required this.description,
    required this.icon,
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

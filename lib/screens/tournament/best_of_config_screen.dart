import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/tournament.dart';
import '../../theme/app_theme.dart';

/// Screen for configuring Best-of-X format for knockout rounds.
/// Second step in tournament creation flow for Group+Knockout type.
class BestOfConfigScreen extends StatefulWidget {
  const BestOfConfigScreen({super.key});

  @override
  State<BestOfConfigScreen> createState() => _BestOfConfigScreenState();
}

class _BestOfConfigScreenState extends State<BestOfConfigScreen> {
  // Configure all possible knockout rounds - only relevant ones will be used
  // based on car count selected in the next step
  late Map<String, int> _knockoutFormat;

  @override
  void initState() {
    super.initState();
    _knockoutFormat = _getDefaultFormat();
  }

  /// All possible knockout rounds with default Best-of values
  Map<String, int> _getDefaultFormat() {
    return {
      'ro16': 1, // Round of 16 - Best of 1 (quick rounds)
      'qf': 3, // Quarterfinals - Best of 3
      'sf': 5, // Semifinals - Best of 5
      'gf': 7, // Grand Finals - Best of 7
    };
  }

  String _getRoundLabel(String round) {
    switch (round) {
      case 'ro16':
        return 'Round of 16';
      case 'qf':
        return 'Quarterfinals';
      case 'sf':
        return 'Semifinals';
      case 'gf':
        return 'Grand Finals';
      default:
        return round;
    }
  }

  String _getRoundInfo(String round) {
    switch (round) {
      case 'ro16':
        return 'Only used with 32 cars';
      case 'qf':
        return 'Used with 16 or 32 cars';
      case 'sf':
        return 'Used with 8, 16, or 32 cars';
      case 'gf':
        return 'Always the final match';
      default:
        return '';
    }
  }

  void _continueToCarSelection() {
    context.push(
      '/tournament/setup/cars',
      extra: {
        'type': TournamentType.groupKnockout,
        'knockoutFormat': _knockoutFormat,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CONFIGURE FORMAT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tournament overview card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.view_module,
                                  color: Colors.purple,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GROUP + KNOCKOUT',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Configure knockout round formats',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          // How it works
                          _InfoRow(
                            icon: Icons.groups,
                            color: AppTheme.secondaryColor,
                            title: 'GROUP STAGE',
                            subtitle: 'Round-robin in groups of 4 (Best-of-1)',
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.emoji_events,
                            color: AppTheme.winnerColor,
                            title: 'KNOCKOUT STAGE',
                            subtitle: 'Top 2 from each group advance to brackets',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Knockout format configuration
                  Text(
                    'KNOCKOUT FORMAT',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set the number of races per match in each knockout round',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Round configuration cards (all 4 rounds)
                  ...['gf', 'sf', 'qf', 'ro16'].map((round) => _RoundConfigCard(
                        roundKey: round,
                        roundLabel: _getRoundLabel(round),
                        roundInfo: _getRoundInfo(round),
                        selectedValue: _knockoutFormat[round]!,
                        onChanged: (value) {
                          setState(() {
                            _knockoutFormat[round] = value;
                          });
                        },
                      )),

                  const SizedBox(height: 16),

                  // Info card about car counts
                  Card(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryColor.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You\'ll select cars in the next step. The knockout rounds used depend on car count:\n• 8 cars → Semifinals + Finals\n• 16 cars → Quarterfinals + Semi + Finals\n• 32 cars → All rounds',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textPrimary.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Continue button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _continueToCarSelection,
                child: const Text('SELECT CARS'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundConfigCard extends StatelessWidget {
  final String roundKey;
  final String roundLabel;
  final String roundInfo;
  final int selectedValue;
  final ValueChanged<int> onChanged;

  const _RoundConfigCard({
    required this.roundKey,
    required this.roundLabel,
    required this.roundInfo,
    required this.selectedValue,
    required this.onChanged,
  });

  IconData _getIcon() {
    switch (roundKey) {
      case 'gf':
        return Icons.emoji_events;
      case 'sf':
        return Icons.looks_two;
      case 'qf':
        return Icons.looks_4;
      case 'ro16':
        return Icons.grid_view;
      default:
        return Icons.sports_score;
    }
  }

  Color _getColor() {
    switch (roundKey) {
      case 'gf':
        return AppTheme.winnerColor;
      case 'sf':
        return AppTheme.primaryColor;
      case 'qf':
        return AppTheme.secondaryColor;
      case 'ro16':
        return AppTheme.textSecondary;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIcon(),
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roundLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    roundInfo,
                    style: TextStyle(
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Best-of selector buttons
            Row(
              children: [1, 3, 5, 7].map((value) {
                final isSelected = selectedValue == value;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Material(
                    color: isSelected ? color : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () => onChanged(value),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        child: Text(
                          '$value',
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

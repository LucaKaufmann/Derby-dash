import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/tournament.dart';
import '../../providers/tournament_provider.dart';
import '../../theme/app_theme.dart';

class BestOfConfigScreen extends ConsumerStatefulWidget {
  final List<int> carIds;

  const BestOfConfigScreen({
    super.key,
    required this.carIds,
  });

  @override
  ConsumerState<BestOfConfigScreen> createState() => _BestOfConfigScreenState();
}

class _BestOfConfigScreenState extends ConsumerState<BestOfConfigScreen> {
  late Map<String, int> _knockoutFormat;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _knockoutFormat = _getDefaultFormat();
  }

  /// Get the knockout rounds based on car count
  List<String> get _knockoutRounds {
    final count = widget.carIds.length;
    if (count == 32) {
      return ['ro16', 'qf', 'sf', 'gf'];
    } else if (count == 16) {
      return ['qf', 'sf', 'gf'];
    } else {
      // 8 cars
      return ['sf', 'gf'];
    }
  }

  /// Get default Best-of format based on car count
  Map<String, int> _getDefaultFormat() {
    final rounds = _knockoutRounds;
    final format = <String, int>{};
    for (final round in rounds) {
      switch (round) {
        case 'ro16':
          format['ro16'] = 1;
          break;
        case 'qf':
          format['qf'] = 3;
          break;
        case 'sf':
          format['sf'] = 5;
          break;
        case 'gf':
          format['gf'] = 7;
          break;
      }
    }
    return format;
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

  String _getGroupInfo() {
    final count = widget.carIds.length;
    final groupCount = count ~/ 4;
    final groupLetters = List.generate(
      groupCount,
      (i) => String.fromCharCode('A'.codeUnitAt(0) + i),
    ).join(', ');
    return '$groupCount groups ($groupLetters) of 4 cars each';
  }

  Future<void> _startTournament() async {
    setState(() {
      _isCreating = true;
    });

    try {
      final tournamentId = await ref.read(tournamentServiceProvider).createTournament(
            carIds: widget.carIds,
            type: TournamentType.groupKnockout,
            knockoutFormat: jsonEncode(_knockoutFormat),
          );

      if (mounted) {
        context.go('/tournament/$tournamentId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CONFIGURE TOURNAMENT'),
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
                                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.view_module,
                                  color: AppTheme.primaryColor,
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
                                      '${widget.carIds.length} cars selected',
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
                          // Group stage info
                          Row(
                            children: [
                              const Icon(
                                Icons.groups,
                                color: AppTheme.secondaryColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'GROUP STAGE',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Text(
                                      _getGroupInfo(),
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Text(
                                      'Round-robin within each group (Best-of-1)',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                color: AppTheme.winnerColor,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'KNOCKOUT STAGE',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Text(
                                      'Top 2 from each group advance',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

                  // Round configuration cards
                  ..._knockoutRounds.map((round) => _RoundConfigCard(
                        roundKey: round,
                        roundLabel: _getRoundLabel(round),
                        selectedValue: _knockoutFormat[round]!,
                        onChanged: (value) {
                          setState(() {
                            _knockoutFormat[round] = value;
                          });
                        },
                      )),
                ],
              ),
            ),
          ),

          // Start button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _isCreating ? null : _startTournament,
                child: _isCreating
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : const Text('START TOURNAMENT'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundConfigCard extends StatelessWidget {
  final String roundKey;
  final String roundLabel;
  final int selectedValue;
  final ValueChanged<int> onChanged;

  const _RoundConfigCard({
    required this.roundKey,
    required this.roundLabel,
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
                    'Best of $selectedValue',
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
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
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: Text(
                          '$value',
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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

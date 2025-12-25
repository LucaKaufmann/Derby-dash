import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/car.dart';
import '../../data/models/tournament.dart';
import '../../providers/car_provider.dart';
import '../../providers/tournament_provider.dart';
import '../../theme/app_theme.dart';

class TournamentSetupScreen extends ConsumerStatefulWidget {
  const TournamentSetupScreen({super.key});

  @override
  ConsumerState<TournamentSetupScreen> createState() =>
      _TournamentSetupScreenState();
}

class _TournamentSetupScreenState extends ConsumerState<TournamentSetupScreen> {
  final Set<int> _selectedCarIds = {};
  TournamentType _tournamentType = TournamentType.knockout;
  bool _isCreating = false;

  int get _minCarsRequired =>
      _tournamentType == TournamentType.doubleElimination ? 4 : 2;

  /// Check if a number is a power of 2 (2, 4, 8, 16, 32, 64, etc.)
  bool _isPowerOfTwo(int n) => n > 0 && (n & (n - 1)) == 0;

  bool get _isValidCarCount {
    final count = _selectedCarIds.length;
    if (count < _minCarsRequired) return false;
    // Require power of 2 for knockout/double elimination (4, 8, 16, 32, etc.)
    if (_tournamentType == TournamentType.knockout ||
        _tournamentType == TournamentType.doubleElimination) {
      return _isPowerOfTwo(count);
    }
    return true; // Round robin allows any count >= 2
  }

  /// Get the next valid power of 2 for display
  int _nextPowerOfTwo(int n) {
    if (n <= 0) return 2;
    int power = 2;
    while (power < n) {
      power *= 2;
    }
    return power;
  }

  String? get _validationMessage {
    final count = _selectedCarIds.length;
    if (count < _minCarsRequired) {
      return 'Select at least $_minCarsRequired cars';
    }
    if ((_tournamentType == TournamentType.knockout ||
            _tournamentType == TournamentType.doubleElimination) &&
        !_isPowerOfTwo(count)) {
      final next = _nextPowerOfTwo(count);
      final prev = next ~/ 2;
      if (count > prev && prev >= _minCarsRequired) {
        return 'Select $prev or $next cars (power of 2 required)';
      }
      return 'Select $next cars (power of 2 required)';
    }
    return null;
  }

  Future<void> _startTournament() async {
    if (!_isValidCarCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_validationMessage ?? 'Invalid car selection'),
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final tournamentId = await ref.read(tournamentServiceProvider).createTournament(
            carIds: _selectedCarIds.toList(),
            type: _tournamentType,
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
    final carsAsync = ref.watch(carsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NEW TOURNAMENT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Tournament Type Selection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TypeButton(
                        label: 'KNOCKOUT',
                        subtitle: 'Single elimination',
                        icon: Icons.emoji_events,
                        isSelected: _tournamentType == TournamentType.knockout,
                        onTap: () => setState(() {
                          _tournamentType = TournamentType.knockout;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TypeButton(
                        label: 'DOUBLE ELIM',
                        subtitle: 'Lose twice = out',
                        icon: Icons.repeat,
                        isSelected: _tournamentType == TournamentType.doubleElimination,
                        onTap: () => setState(() {
                          _tournamentType = TournamentType.doubleElimination;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TypeButton(
                        label: 'ROUND ROBIN',
                        subtitle: 'Everyone plays',
                        icon: Icons.loop,
                        isSelected: _tournamentType == TournamentType.roundRobin,
                        onTap: () => setState(() {
                          _tournamentType = TournamentType.roundRobin;
                        }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Selection Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SELECT CARS: ',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedCarIds.length >= 2
                        ? AppTheme.successColor
                        : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedCarIds.length}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
          ),

          // Car Grid
          Expanded(
            child: carsAsync.when(
              data: (cars) {
                if (cars.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.directions_car,
                          size: 80,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No cars in garage!',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ElevatedButton(
                            onPressed: () => context.push('/garage'),
                            child: const Text('GO TO GARAGE'),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    final isSelected = _selectedCarIds.contains(car.id);

                    return _SelectableCarCard(
                      car: car,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedCarIds.remove(car.id);
                          } else {
                            _selectedCarIds.add(car.id);
                          }
                        });
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),

          // Validation message
          if (_validationMessage != null && _selectedCarIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _validationMessage!,
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Start Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isValidCarCount && !_isCreating
                    ? _startTournament
                    : null,
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

class _TypeButton extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 9,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppTheme.textSecondary.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectableCarCard extends StatelessWidget {
  final Car car;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableCarCard({
    required this.car,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.successColor : Colors.transparent,
            width: 4,
          ),
        ),
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: car.photoPath.isNotEmpty &&
                            File(car.photoPath).existsSync()
                        ? Image.file(
                            File(car.photoPath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : const Center(
                            child: Icon(
                              Icons.directions_car,
                              size: 40,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      child: Text(
                        car.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.successColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

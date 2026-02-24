import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/car.dart';
import '../../data/models/tournament.dart';
import '../../providers/car_provider.dart';
import '../../providers/tournament_provider.dart';
import '../../theme/app_theme.dart';

/// Screen for selecting cars for a tournament.
/// Second (or third for groupKnockout) step in tournament creation flow.
class CarSelectionScreen extends ConsumerStatefulWidget {
  final TournamentType tournamentType;
  final Map<String, int>? knockoutFormat; // Only for groupKnockout

  const CarSelectionScreen({
    super.key,
    required this.tournamentType,
    this.knockoutFormat,
  });

  @override
  ConsumerState<CarSelectionScreen> createState() => _CarSelectionScreenState();
}

class _CarSelectionScreenState extends ConsumerState<CarSelectionScreen> {
  final Set<int> _selectedCarIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isCreating = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _minCarsRequired {
    switch (widget.tournamentType) {
      case TournamentType.doubleElimination:
        return 4;
      case TournamentType.groupKnockout:
        return 8;
      default:
        return 2;
    }
  }

  /// Check if a number is a power of 2 (2, 4, 8, 16, 32, 64, etc.)
  bool _isPowerOfTwo(int n) => n > 0 && (n & (n - 1)) == 0;

  /// Valid counts for groupKnockout (8, 16, or 32 cars = 2, 4, or 8 groups of 4)
  bool _isValidGroupKnockoutCount(int n) => n == 8 || n == 16 || n == 32;

  bool get _isValidCarCount {
    final count = _selectedCarIds.length;
    if (count < _minCarsRequired) return false;
    // Require power of 2 for knockout/double elimination (4, 8, 16, 32, etc.)
    if (widget.tournamentType == TournamentType.knockout ||
        widget.tournamentType == TournamentType.doubleElimination) {
      return _isPowerOfTwo(count);
    }
    // Require 8, 16, or 32 for groupKnockout
    if (widget.tournamentType == TournamentType.groupKnockout) {
      return _isValidGroupKnockoutCount(count);
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

  String get _requirementText {
    switch (widget.tournamentType) {
      case TournamentType.knockout:
        return 'Requires 2, 4, 8, 16, or 32 cars';
      case TournamentType.doubleElimination:
        return 'Requires 4, 8, 16, or 32 cars';
      case TournamentType.roundRobin:
        return 'Requires at least 2 cars';
      case TournamentType.groupKnockout:
        return 'Requires exactly 8, 16, or 32 cars';
    }
  }

  String? get _validationMessage {
    final count = _selectedCarIds.length;
    if (count == 0) return null;
    if (count < _minCarsRequired) {
      if (widget.tournamentType == TournamentType.groupKnockout) {
        return 'Need ${8 - count} more cars (8, 16, or 32 required)';
      }
      return 'Need ${_minCarsRequired - count} more cars';
    }
    if ((widget.tournamentType == TournamentType.knockout ||
            widget.tournamentType == TournamentType.doubleElimination) &&
        !_isPowerOfTwo(count)) {
      final next = _nextPowerOfTwo(count);
      final prev = next ~/ 2;
      if (count > prev && prev >= _minCarsRequired) {
        return 'Select $prev or $next cars (power of 2 required)';
      }
      return 'Select $next cars (power of 2 required)';
    }
    if (widget.tournamentType == TournamentType.groupKnockout &&
        !_isValidGroupKnockoutCount(count)) {
      if (count < 8) {
        return 'Need ${8 - count} more cars';
      } else if (count < 16) {
        return 'Select 8 or 16 cars (currently $count)';
      } else if (count < 32) {
        return 'Select 16 or 32 cars (currently $count)';
      } else {
        return 'Maximum 32 cars allowed';
      }
    }
    return null;
  }

  String get _tournamentTypeName {
    switch (widget.tournamentType) {
      case TournamentType.knockout:
        return 'Knockout';
      case TournamentType.doubleElimination:
        return 'Double Elimination';
      case TournamentType.roundRobin:
        return 'Round Robin';
      case TournamentType.groupKnockout:
        return 'Group + Knockout';
    }
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
            type: widget.tournamentType,
            knockoutFormat: widget.knockoutFormat,
          );

      if (mounted) {
        // Navigate to tournament, replacing the entire setup flow
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

  void _selectAll(List<Car> cars) {
    setState(() {
      _selectedCarIds.addAll(cars.map((c) => c.id));
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedCarIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final carsAsync = ref.watch(carsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SELECT CARS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 900 ? 24.0 : 16.0;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  // Tournament type indicator
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 12,
                    ),
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: Row(
                      children: [
                        Icon(
                          _getTypeIcon(),
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _tournamentTypeName.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _requirementText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  Padding(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search cars...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppTheme.surfaceColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),

                  // Selection count and actions (hidden when searching)
                  if (_searchQuery.isEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _isValidCarCount
                                  ? AppTheme.successColor
                                  : _selectedCarIds.isNotEmpty
                                      ? Colors.orange
                                      : AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isValidCarCount
                                      ? Icons.check
                                      : Icons.directions_car,
                                  size: 18,
                                  color: _selectedCarIds.isNotEmpty
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_selectedCarIds.length} selected',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedCarIds.isNotEmpty
                                        ? Colors.white
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          carsAsync.maybeWhen(
                            data: (cars) {
                              final filteredCars = _filterCars(cars);
                              return Row(
                                children: [
                                  TextButton(
                                    onPressed:
                                        _selectedCarIds.isEmpty ? null : _deselectAll,
                                    child: const Text('Clear'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: filteredCars.length ==
                                            _selectedCarIds.length
                                        ? null
                                        : () => _selectAll(filteredCars),
                                    child: const Text('Select All'),
                                  ),
                                ],
                              );
                            },
                            orElse: () => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Car Grid
                  Expanded(
                    child: carsAsync.when(
                      data: (cars) {
                        final filteredCars = _filterCars(cars);

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
                                  style:
                                      Theme.of(context).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () => context.push('/garage'),
                                    child: const Text('GO TO GARAGE'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (filteredCars.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No cars match "$_searchQuery"',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: EdgeInsets.all(horizontalPadding),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: filteredCars.length,
                          itemBuilder: (context, index) {
                            final car = filteredCars[index];
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
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(child: Text('Error: $error')),
                    ),
                  ),

                  // Validation message and Start Button (hidden when searching)
                  if (_searchQuery.isEmpty) ...[
                    if (_validationMessage != null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 8,
                        ),
                        color: Colors.orange.withValues(alpha: 0.1),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _validationMessage!,
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Start Button
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          16,
                          horizontalPadding,
                          16,
                        ),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Car> _filterCars(List<Car> cars) {
    if (_searchQuery.isEmpty) return cars;
    return cars.where((car) => car.name.toLowerCase().contains(_searchQuery)).toList();
  }

  IconData _getTypeIcon() {
    switch (widget.tournamentType) {
      case TournamentType.knockout:
        return Icons.emoji_events;
      case TournamentType.doubleElimination:
        return Icons.repeat;
      case TournamentType.roundRobin:
        return Icons.loop;
      case TournamentType.groupKnockout:
        return Icons.view_module;
    }
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
                    child: car.photoPath.isNotEmpty && File(car.photoPath).existsSync()
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

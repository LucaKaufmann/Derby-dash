import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/car.dart';
import '../../providers/car_provider.dart';
import '../../providers/tournament_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/car_photo_frame.dart';

class TeamBattleSetupScreen extends ConsumerStatefulWidget {
  const TeamBattleSetupScreen({super.key});

  @override
  ConsumerState<TeamBattleSetupScreen> createState() =>
      _TeamBattleSetupScreenState();
}

class _TeamBattleSetupScreenState extends ConsumerState<TeamBattleSetupScreen> {
  final Set<int> _redTeamIds = {};
  final Set<int> _blueTeamIds = {};
  int _targetScore = 3;
  bool _isCreating = false;

  bool get _canStart => _redTeamIds.isNotEmpty && _blueTeamIds.isNotEmpty;

  void _toggleCar(Car car) {
    setState(() {
      if (_redTeamIds.remove(car.id)) {
        _blueTeamIds.add(car.id);
      } else if (_blueTeamIds.remove(car.id)) {
        // Third tap clears the assignment.
      } else {
        _redTeamIds.add(car.id);
      }
    });
  }

  Future<void> _startBattle() async {
    if (!_canStart || _isCreating) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final tournamentId = await ref
          .read(tournamentServiceProvider)
          .createTeamBattle(
            teamACarIds: _redTeamIds.toList(),
            teamBCarIds: _blueTeamIds.toList(),
            targetScore: _targetScore,
          );

      if (mounted) {
        context.go('/team-battle/$tournamentId');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isCreating = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final carsAsync = ref.watch(carsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TEAM BATTLE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: carsAsync.when(
        data: (cars) {
          if (cars.length < 2) {
            return _NotEnoughCars(onGarageTap: () => context.push('/garage'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _TeamCounter(
                            label: 'RED TEAM',
                            count: _redTeamIds.length,
                            color: AppTheme.errorColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TeamCounter(
                            label: 'BLUE TEAM',
                            count: _blueTeamIds.length,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 3, label: Text('3')),
                        ButtonSegment(value: 5, label: Text('5')),
                        ButtonSegment(value: 7, label: Text('7')),
                      ],
                      selected: {_targetScore},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _targetScore = selection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    final team = _redTeamIds.contains(car.id)
                        ? _Team.red
                        : _blueTeamIds.contains(car.id)
                        ? _Team.blue
                        : null;
                    return _TeamCarCard(
                      car: car,
                      team: team,
                      onTap: () => _toggleCar(car),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _canStart && !_isCreating ? _startBattle : null,
                    icon: _isCreating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.groups),
                    label: Text(
                      _canStart ? 'FIRST TO $_targetScore' : 'PICK BOTH TEAMS',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

enum _Team { red, blue }

class _TeamCounter extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _TeamCounter({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text('$count cars', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _TeamCarCard extends StatelessWidget {
  final Car car;
  final _Team? team;
  final VoidCallback onTap;

  const _TeamCarCard({
    required this.car,
    required this.team,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = team == _Team.red
        ? AppTheme.errorColor
        : team == _Team.blue
        ? AppTheme.secondaryColor
        : AppTheme.surfaceColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: team == null ? 2 : 4),
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
                    child: CarPhotoFrame(
                      photoPath: car.photoPath,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: BorderRadius.zero,
                      imageFit: BoxFit.cover,
                      iconSize: 48,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          car.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (team != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      team == _Team.red ? 'RED' : 'BLUE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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

class _NotEnoughCars extends StatelessWidget {
  final VoidCallback onGarageTap;

  const _NotEnoughCars({required this.onGarageTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.groups, size: 96, color: AppTheme.textSecondary),
            const SizedBox(height: 24),
            Text(
              'Need 2 cars',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onGarageTap,
              icon: const Icon(Icons.garage),
              label: const Text('GO TO GARAGE'),
            ),
          ],
        ),
      ),
    );
  }
}

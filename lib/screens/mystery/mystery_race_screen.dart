import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/car.dart';
import '../../data/models/match.dart';
import '../../providers/car_provider.dart';
import '../../providers/tournament_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/car_photo_frame.dart';

class MysteryRaceScreen extends ConsumerStatefulWidget {
  const MysteryRaceScreen({super.key});

  @override
  ConsumerState<MysteryRaceScreen> createState() => _MysteryRaceScreenState();
}

class _MysteryRaceScreenState extends ConsumerState<MysteryRaceScreen> {
  Match? _match;
  Car? _winner;
  bool _isRevealing = false;
  bool _isSaving = false;
  int? _previousCarAId;
  int? _previousCarBId;

  Future<void> _revealRace() async {
    if (_isRevealing || _isSaving) return;

    setState(() {
      _isRevealing = true;
      _winner = null;
    });

    try {
      final match = await ref
          .read(tournamentServiceProvider)
          .createMysteryRace(
            previousCarAId: _previousCarAId,
            previousCarBId: _previousCarBId,
          );

      if (!mounted) return;
      setState(() {
        _match = match;
        _previousCarAId = match.carA.value?.id;
        _previousCarBId = match.carB.value?.id;
        _isRevealing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isRevealing = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  Future<void> _selectWinner(Car car) async {
    final match = _match;
    if (match == null || _winner != null || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    await ref.read(tournamentServiceProvider).completeMatch(match.id, car.id);

    ref.invalidate(completedTournamentsProvider);
    ref.invalidate(carStatsProvider(car.id));
    ref.invalidate(sortedCarsProvider);

    if (!mounted) return;
    setState(() {
      _winner = car;
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final carsAsync = ref.watch(carsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MYSTERY RACE'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
        ),
      ),
      body: carsAsync.when(
        data: (cars) {
          if (cars.length < 2) {
            return _NotEnoughCars(onGarageTap: () => context.push('/garage'));
          }

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth >= 900
                    ? 760.0
                    : double.infinity;

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _winner != null
                            ? _WinnerView(
                                key: ValueKey('winner-${_winner!.id}'),
                                winner: _winner!,
                                onNextRace: _revealRace,
                              )
                            : _match != null
                            ? _RaceView(
                                key: ValueKey('match-${_match!.id}'),
                                match: _match!,
                                isSaving: _isSaving,
                                onWinnerSelected: _selectWinner,
                              )
                            : _RevealView(
                                key: const ValueKey('reveal'),
                                isRevealing: _isRevealing,
                                onReveal: _revealRace,
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _RevealView extends StatelessWidget {
  final bool isRevealing;
  final VoidCallback onReveal;

  const _RevealView({
    super.key,
    required this.isRevealing,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.help, size: 120, color: AppTheme.winnerColor),
        const SizedBox(height: 32),
        Text(
          'WHO WILL RACE?',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        ElevatedButton.icon(
          onPressed: isRevealing ? null : onReveal,
          icon: isRevealing
              ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.shuffle, size: 36),
          label: Text(isRevealing ? 'PICKING...' : 'REVEAL RACERS'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _RaceView extends StatelessWidget {
  final Match match;
  final bool isSaving;
  final ValueChanged<Car> onWinnerSelected;

  const _RaceView({
    super.key,
    required this.match,
    required this.isSaving,
    required this.onWinnerSelected,
  });

  @override
  Widget build(BuildContext context) {
    final carA = match.carA.value;
    final carB = match.carB.value;

    if (carA == null || carB == null) {
      return const Center(child: Text('Cars not found'));
    }

    return Column(
      children: [
        Text(
          'TAP THE WINNER',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _MysteryCarButton(
            car: carA,
            color: AppTheme.primaryColor,
            enabled: !isSaving,
            onTap: () => onWinnerSelected(carA),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.textSecondary, width: 2),
          ),
          child: isSaving
              ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : Text('VS', style: Theme.of(context).textTheme.headlineMedium),
        ),
        Expanded(
          child: _MysteryCarButton(
            car: carB,
            color: AppTheme.secondaryColor,
            enabled: !isSaving,
            onTap: () => onWinnerSelected(carB),
          ),
        ),
      ],
    );
  }
}

class _MysteryCarButton extends StatelessWidget {
  final Car car;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _MysteryCarButton({
    required this.car,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: enabled ? 0.22 : 0.08),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color, width: 4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: CarPhotoFrame(
                  photoPath: car.photoPath,
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: BorderRadius.circular(18),
                  imagePadding: 10,
                  imageFit: BoxFit.contain,
                  iconSize: 90,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                car.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WinnerView extends StatelessWidget {
  final Car winner;
  final VoidCallback onNextRace;

  const _WinnerView({
    super.key,
    required this.winner,
    required this.onNextRace,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.emoji_events, size: 96, color: AppTheme.winnerColor),
        const SizedBox(height: 24),
        Text(
          'WINNER!',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppTheme.winnerColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Center(
          child: CarPhotoFrame(
            photoPath: winner.photoPath,
            width: 220,
            height: 220,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.winnerColor, width: 5),
            imagePadding: 14,
            imageFit: BoxFit.contain,
            iconSize: 100,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          winner.name,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 44),
        ElevatedButton.icon(
          onPressed: onNextRace,
          icon: const Icon(Icons.shuffle, size: 32),
          label: const Text('NEXT RACE'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
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
            const Icon(
              Icons.directions_car,
              size: 96,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Need 2 cars',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Add more cars to start a Mystery Race.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
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

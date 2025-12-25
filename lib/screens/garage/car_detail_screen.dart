import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/car.dart';
import '../../providers/car_provider.dart';
import '../../theme/app_theme.dart';

class CarDetailScreen extends ConsumerWidget {
  final int carId;

  const CarDetailScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(carsProvider);
    final statsAsync = ref.watch(carStatsProvider(carId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppTheme.errorColor,
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: carsAsync.when(
        data: (cars) {
          final car = cars.where((c) => c.id == carId).firstOrNull;
          if (car == null) {
            return const Center(child: Text('Car not found'));
          }
          return _buildContent(context, car, statsAsync);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Car car,
    AsyncValue<CarStats> statsAsync,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Large photo
          AspectRatio(
            aspectRatio: 1,
            child: car.photoPath.isNotEmpty && File(car.photoPath).existsSync()
                ? Image.file(
                    File(car.photoPath),
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: AppTheme.surfaceColor,
                    child: const Center(
                      child: Icon(
                        Icons.directions_car,
                        size: 120,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
          ),

          // Car name
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              car.name,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),

          // Stats section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: statsAsync.when(
              data: (stats) => _buildStats(context, stats),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Could not load stats'),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, CarStats stats) {
    return Column(
      children: [
        // Win/Loss record
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatCard(
              label: 'WINS',
              value: stats.wins.toString(),
              color: AppTheme.successColor,
            ),
            _StatCard(
              label: 'LOSSES',
              value: stats.losses.toString(),
              color: AppTheme.errorColor,
            ),
            _StatCard(
              label: 'MATCHES',
              value: stats.totalMatches.toString(),
              color: AppTheme.primaryColor,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Win rate
        if (stats.totalMatches > 0)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'WIN RATE',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(stats.winRate * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: stats.winRate >= 0.5
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Car?'),
        content: const Text('This will remove the car from your garage.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(carsProvider.notifier).deleteCar(carId);
      context.pop();
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

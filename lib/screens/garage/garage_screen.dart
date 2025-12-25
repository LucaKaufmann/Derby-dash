import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/car_provider.dart';
import '../../theme/app_theme.dart';

class GarageScreen extends ConsumerStatefulWidget {
  const GarageScreen({super.key});

  @override
  ConsumerState<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends ConsumerState<GarageScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carsAsync = ref.watch(carsProvider);

    return Scaffold(
      appBar: AppBar(
        title: carsAsync.when(
          data: (cars) => Text('GARAGE (${cars.length})'),
          loading: () => const Text('GARAGE'),
          error: (_, __) => const Text('GARAGE'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: carsAsync.when(
        data: (cars) {
          if (cars.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 80,
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No cars yet!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first car',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          // Filter cars based on search query
          final filteredCars = _searchQuery.isEmpty
              ? cars
              : cars
                  .where((car) => car.name
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .toList();

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search cars...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              // Results
              Expanded(
                child: filteredCars.isEmpty
                    ? Center(
                        child: Text(
                          'No cars match "$_searchQuery"',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: filteredCars.length,
                        itemBuilder: (context, index) {
                          final car = filteredCars[index];
                          return _CarCard(
                            name: car.name,
                            photoPath: car.photoPath,
                            carId: car.id,
                            onDelete: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Car?'),
                                  content: Text(
                                      'Remove ${car.name} from your garage?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('CANCEL'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.errorColor,
                                      ),
                                      child: const Text('DELETE'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                ref
                                    .read(carsProvider.notifier)
                                    .deleteCar(car.id);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/garage/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CarCard extends ConsumerWidget {
  final String name;
  final String photoPath;
  final int carId;
  final VoidCallback onDelete;

  const _CarCard({
    required this.name,
    required this.photoPath,
    required this.carId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(carStatsProvider(carId));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onLongPress: onDelete,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: photoPath.isNotEmpty && File(photoPath).existsSync()
                  ? Image.file(
                      File(photoPath),
                      fit: BoxFit.cover,
                    )
                  : const Center(
                      child: Icon(
                        Icons.directions_car,
                        size: 64,
                        color: AppTheme.textSecondary,
                      ),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    statsAsync.when(
                      data: (stats) => Text(
                        '${stats.wins}W - ${stats.losses}L',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: stats.wins > stats.losses
                                  ? AppTheme.successColor
                                  : stats.losses > stats.wins
                                      ? AppTheme.errorColor
                                      : AppTheme.textSecondary,
                            ),
                      ),
                      loading: () => const Text('-'),
                      error: (_, __) => const Text('-'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

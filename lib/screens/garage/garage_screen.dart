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

  String _getSortLabel(GarageSortOption option) {
    return switch (option) {
      GarageSortOption.wins => 'Most Wins',
      GarageSortOption.losses => 'Most Losses',
      GarageSortOption.winRate => 'Win Rate',
      GarageSortOption.name => 'Name',
      GarageSortOption.newest => 'Newest',
      GarageSortOption.oldest => 'Oldest',
    };
  }

  @override
  Widget build(BuildContext context) {
    final sortedCarsAsync = ref.watch(sortedCarsProvider);
    final currentSort = ref.watch(garageSortProvider);

    return Scaffold(
      appBar: AppBar(
        title: sortedCarsAsync.when(
          data: (cars) => Text('GARAGE (${cars.length})'),
          loading: () => const Text('GARAGE'),
          error: (_, __) => const Text('GARAGE'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: sortedCarsAsync.when(
        data: (carsWithStats) {
          if (carsWithStats.isEmpty) {
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
              ? carsWithStats
              : carsWithStats
                  .where((item) => item.car.name
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .toList();

          return Column(
            children: [
              // Search and sort row
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Search bar
                    Expanded(
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
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Sort dropdown
                    PopupMenuButton<GarageSortOption>(
                      initialValue: currentSort,
                      onSelected: (option) {
                        ref.read(garageSortProvider.notifier).setSort(option);
                      },
                      itemBuilder: (context) => GarageSortOption.values
                          .map((option) => PopupMenuItem(
                                value: option,
                                child: Row(
                                  children: [
                                    if (option == currentSort)
                                      const Icon(Icons.check, size: 20)
                                    else
                                      const SizedBox(width: 20),
                                    const SizedBox(width: 8),
                                    Text(_getSortLabel(option)),
                                  ],
                                ),
                              ))
                          .toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.textSecondary),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sort, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              _getSortLabel(currentSort),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                          final item = filteredCars[index];
                          return _CarCard(
                            name: item.car.name,
                            photoPath: item.car.photoPath,
                            stats: item.stats,
                            onTap: () =>
                                context.push('/garage/car/${item.car.id}'),
                            onDelete: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Car?'),
                                  content: Text(
                                      'Remove ${item.car.name} from your garage?'),
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
                                    .deleteCar(item.car.id);
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

class _CarCard extends StatelessWidget {
  final String name;
  final String photoPath;
  final CarStats stats;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CarCard({
    required this.name,
    required this.photoPath,
    required this.stats,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                    Text(
                      '${stats.wins}W - ${stats.losses}L',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: stats.wins > stats.losses
                                ? AppTheme.successColor
                                : stats.losses > stats.wins
                                    ? AppTheme.errorColor
                                    : AppTheme.textSecondary,
                          ),
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

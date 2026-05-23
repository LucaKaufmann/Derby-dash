import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/car_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/car_photo_frame.dart';

class MysteryRaceSettingsScreen extends ConsumerWidget {
  const MysteryRaceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(carsProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MYSTERY CARS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: settingsAsync.when(
        data: (settings) => carsAsync.when(
          data: (cars) {
            if (cars.isEmpty) {
              return const Center(child: Text('No cars in the garage yet'));
            }

            final hiddenIds = settings.hiddenMysteryCarIds;
            final availableCount = cars
                .where((car) => !hiddenIds.contains(car.id))
                .length;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          availableCount >= 2
                              ? Icons.shuffle
                              : Icons.warning_amber,
                          color: availableCount >= 2
                              ? AppTheme.primaryColor
                              : AppTheme.winnerColor,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            availableCount >= 2
                                ? '$availableCount cars available for Mystery Race'
                                : 'Mystery Race needs at least 2 visible cars',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        if (hiddenIds.isNotEmpty)
                          TextButton(
                            onPressed: () => ref
                                .read(settingsProvider.notifier)
                                .showAllMysteryCars(),
                            child: const Text('SHOW ALL'),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                for (final car in cars) ...[
                  Card(
                    child: SwitchListTile(
                      value: hiddenIds.contains(car.id),
                      onChanged: (hidden) => ref
                          .read(settingsProvider.notifier)
                          .setMysteryCarHidden(car.id, hidden),
                      activeThumbColor: AppTheme.errorColor,
                      secondary: SizedBox(
                        width: 56,
                        height: 56,
                        child: CarPhotoFrame(
                          photoPath: car.photoPath,
                          width: 56,
                          height: 56,
                          borderRadius: BorderRadius.circular(12),
                          imagePadding: 4,
                          imageFit: BoxFit.contain,
                          iconSize: 28,
                        ),
                      ),
                      title: Text(
                        car.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        hiddenIds.contains(car.id)
                            ? 'Hidden from Mystery Race'
                            : 'Available for Mystery Race',
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

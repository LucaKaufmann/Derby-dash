import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../data/models/car.dart';
import '../../providers/car_provider.dart';
import '../../theme/app_theme.dart';

class CarDetailScreen extends ConsumerStatefulWidget {
  final int carId;

  const CarDetailScreen({super.key, required this.carId});

  @override
  ConsumerState<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends ConsumerState<CarDetailScreen> {
  Future<void> _editName(Car car) async {
    final controller = TextEditingController(text: car.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Enter car name',
          ),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != car.name) {
      await ref.read(carsProvider.notifier).updateCarDetails(
            carId: widget.carId,
            name: newName,
          );
    }
  }

  Future<void> _changePhoto() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Photo',
            toolbarColor: AppTheme.backgroundColor,
            toolbarWidgetColor: Colors.white,
            backgroundColor: AppTheme.backgroundColor,
            activeControlsWidgetColor: AppTheme.primaryColor,
            cropFrameColor: AppTheme.primaryColor,
            cropGridColor: AppTheme.textSecondary,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Photo',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedFile != null) {
        await ref.read(carsProvider.notifier).updateCarDetails(
              carId: widget.carId,
              tempPhotoPath: croppedFile.path,
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating photo: $e')),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
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

    if (confirmed == true && mounted) {
      ref.read(carsProvider.notifier).deleteCar(widget.carId);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final carsAsync = ref.watch(carsProvider);
    final statsAsync = ref.watch(carStatsProvider(widget.carId));

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
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: carsAsync.when(
        data: (cars) {
          final car = cars.where((c) => c.id == widget.carId).firstOrNull;
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
          // Large photo (tappable to change)
          GestureDetector(
            onTap: _changePhoto,
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  car.photoPath.isNotEmpty && File(car.photoPath).existsSync()
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
                  // Camera overlay
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Car name (tappable to edit)
          GestureDetector(
            onTap: () => _editName(car),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      car.name,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit,
                    color: AppTheme.textSecondary,
                    size: 24,
                  ),
                ],
              ),
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

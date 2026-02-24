import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../providers/car_provider.dart';
import '../../theme/app_theme.dart';

class AddCarScreen extends ConsumerStatefulWidget {
  const AddCarScreen({super.key});

  @override
  ConsumerState<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends ConsumerState<AddCarScreen> {
  final _nameController = TextEditingController();
  String? _photoPath;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) return;

      // Crop to square
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
        setState(() {
          _photoPath = croppedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  Future<void> _saveCar() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for your car')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(carsProvider.notifier).addCar(
            name: _nameController.text.trim(),
            tempPhotoPath: _photoPath,
          );

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving car: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADD CAR'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentPadding = constraints.maxWidth >= 900 ? 32.0 : 24.0;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: EdgeInsets.all(contentPadding),
                  child: Column(
                    children: [
                      // Photo area (optional)
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 520,
                              maxHeight: 520,
                            ),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: GestureDetector(
                                onTap: _takePhoto,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _photoPath != null
                                          ? AppTheme.primaryColor
                                          : AppTheme.textSecondary
                                              .withValues(alpha: 0.3),
                                      width: 3,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _photoPath != null
                                      ? Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.file(
                                              File(_photoPath!),
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              bottom: 12,
                                              right: 12,
                                              child: FloatingActionButton.small(
                                                onPressed: _takePhoto,
                                                backgroundColor:
                                                    AppTheme.surfaceColor,
                                                child: const Icon(
                                                  Icons.camera_alt,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_a_photo,
                                              size: 64,
                                              color: AppTheme.textSecondary
                                                  .withValues(alpha: 0.5),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'TAP TO ADD PHOTO',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textSecondary
                                                    .withValues(alpha: 0.5),
                                                letterSpacing: 1,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '(optional)',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppTheme.textSecondary
                                                    .withValues(alpha: 0.4),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Name input
                      TextField(
                        controller: _nameController,
                        autofocus: true,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(fontSize: 24),
                        decoration: const InputDecoration(
                          hintText: 'Enter car name',
                          prefixIcon: Icon(Icons.edit, size: 28),
                        ),
                        onSubmitted: (_) => _saveCar(),
                      ),
                      const SizedBox(height: 24),

                      // Save button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveCar,
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('SAVE CAR'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

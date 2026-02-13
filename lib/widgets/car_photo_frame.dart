import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CarPhotoFrame extends StatelessWidget {
  final String? photoPath;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final double imagePadding;
  final BoxFit imageFit;
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;

  const CarPhotoFrame({
    super.key,
    required this.photoPath,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.border,
    this.boxShadow,
    this.imagePadding = 0,
    this.imageFit = BoxFit.contain,
    this.iconSize = 24,
    this.iconColor,
    this.backgroundColor,
  });

  bool get _hasPhoto {
    final path = photoPath;
    return path != null && path.isNotEmpty && File(path).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.backgroundColor;

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
        border: border,
        boxShadow: boxShadow,
      ),
      child: ColoredBox(
        color: bgColor,
        child: _hasPhoto
            ? Padding(
                padding: EdgeInsets.all(imagePadding),
                child: Image.file(
                  File(photoPath!),
                  fit: imageFit,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            : Center(
                child: Icon(
                  Icons.directions_car,
                  size: iconSize,
                  color: iconColor ?? AppTheme.textSecondary,
                ),
              ),
      ),
    );
  }
}

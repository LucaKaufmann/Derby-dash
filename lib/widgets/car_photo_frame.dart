import 'dart:io';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A single, shared component for rendering a car's photo (or a placeholder)
/// inside a rounded or circular frame with an optional border and shadow.
///
/// Rendering approach (important):
/// The image is clipped to the frame's shape *first*, and the border is then
/// painted as a separate overlay on top of the clipped image. Combining a
/// `border` + `borderRadius`/`circle` + `clipBehavior` on a single
/// [BoxDecoration] is a long-standing source of visual artifacts in Flutter:
/// the child gets clipped to the *outer* radius while the border's inner edge
/// sits at a smaller radius, leaving the image's corners poking out as sharp
/// edges. Clipping the image independently and overlaying the border keeps the
/// corners perfectly rounded and the border flush against the edge.
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
  final int? cacheWidth;
  final int? cacheHeight;

  /// Optional widget(s) painted on top of the (already clipped) image, e.g. a
  /// camera button or a gradient. They are clipped to the frame shape too.
  final List<Widget> overlays;

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
    this.cacheWidth,
    this.cacheHeight,
    this.overlays = const [],
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.backgroundColor;
    final path = photoPath;
    final hasPhotoPath = path != null && path.isNotEmpty;
    final isCircle = shape == BoxShape.circle;
    final resolvedRadius = isCircle
        ? null
        : (borderRadius ?? BorderRadius.zero);

    final placeholder = Center(
      child: Icon(
        Icons.directions_car,
        size: iconSize,
        color: iconColor ?? AppTheme.textSecondary,
      ),
    );

    Widget content = ColoredBox(
      color: bgColor,
      child: hasPhotoPath
          ? Padding(
              padding: EdgeInsets.all(imagePadding),
              child: Image.file(
                File(path),
                fit: imageFit,
                width: double.infinity,
                height: double.infinity,
                cacheWidth: cacheWidth,
                cacheHeight: cacheHeight,
                filterQuality: FilterQuality.low,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => placeholder,
              ),
            )
          : placeholder,
    );

    if (overlays.isNotEmpty) {
      content = Stack(
        fit: StackFit.expand,
        children: [content, ...overlays],
      );
    }

    // Clip the image (+ overlays) to the frame's shape first.
    final Widget clipped = isCircle
        ? ClipOval(child: content)
        : ClipRRect(borderRadius: resolvedRadius!, child: content);

    final children = <Widget>[clipped];

    // The border is painted as an overlay on top of the clipped image so the
    // rounded corners are never broken by the border.
    if (border != null) {
      children.add(
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: shape,
                borderRadius: isCircle ? null : resolvedRadius,
                border: border,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      // The shadow follows the frame shape; the fill and border are handled by
      // the clipped content + border overlay above.
      decoration: boxShadow != null
          ? BoxDecoration(
              shape: shape,
              borderRadius: isCircle ? null : resolvedRadius,
              boxShadow: boxShadow,
            )
          : null,
      child: children.length == 1
          ? children.first
          : Stack(fit: StackFit.expand, children: children),
    );
  }
}

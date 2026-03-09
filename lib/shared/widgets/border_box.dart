import 'package:flutter/material.dart';

class BorderBox extends StatelessWidget {
  final Widget child;
  final BoxConstraints? constraints;
  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final Color? color;
  final Color? borderColor;
  const BorderBox({
    super.key,
    required this.child,
    this.constraints,
    this.height,
    this.width = double.infinity,
    this.color,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: constraints,
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ??
              Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      padding: padding,
      child: child,
    );
  }
}

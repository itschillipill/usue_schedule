import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final BorderSide border;
  final Color? mainColor;
  final IconData? leadingIcon;
  final String title;
  final String? subTitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsets cardPadding;

  const CustomListTile(
      {super.key,
      this.border = BorderSide.none,
      this.mainColor,
      this.leadingIcon,
      required this.title,
      this.subTitle,
      this.trailing,
      this.onLongPress,
      this.onTap,
      this.cardPadding =
          const EdgeInsets.symmetric(vertical: 8, horizontal: 16)});

  @override
  Widget build(BuildContext context) {
    final color = mainColor ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: cardPadding,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: border != BorderSide.none
                ? Border.all(color: border.color, width: border.width)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              spacing: 12,
              children: [
                if (leadingIcon != null)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      leadingIcon,
                      color: color,
                      size: 20,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subTitle != null)
                        Text(subTitle!,
                            style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    Color baseColor = backgroundColor ?? theme.colorScheme.primary;

    if (isDark && !isOutlined && backgroundColor == null) {
      baseColor = theme.colorScheme.primaryContainer;
    }

    final Color contentColor = textColor ??
        (isOutlined
            ? baseColor
            : (isDark ? theme.colorScheme.onPrimaryContainer : Colors.white));

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: isOutlined ? Colors.transparent : baseColor,
      foregroundColor: contentColor,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: isOutlined ? BorderSide(color: baseColor, width: 2) : null,
      enabledMouseCursor: SystemMouseCursors.click,
    ).copyWith(
      overlayColor: WidgetStateProperty.all(contentColor.withValues(alpha: 0.1)),
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 56,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: _buildContent(context, contentColor),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: _buildContent(context, contentColor),
            ),
    );
  }

  Widget _buildContent(BuildContext context, Color contentColor) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(contentColor),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: contentColor),
          const SizedBox(width: 10),
        ],
        Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: contentColor,
              ),
        ),
      ],
    );
  }
}
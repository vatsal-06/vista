import 'package:flutter/material.dart';

class LargeActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;
  final double? height;
  final double borderRadius;
  final double fontSize;
  final double letterSpacing;
  final Widget? child;

  const LargeActionButton({
    super.key,
    required this.label,
    this.icon,
    required this.backgroundColor,
    this.textColor = Colors.white,
    required this.onTap,
    this.height = 100,
    this.borderRadius = 24,
    this.fontSize = 22,
    this.letterSpacing = 2.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child ??
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor, size: 28),
                  const SizedBox(height: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: letterSpacing,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

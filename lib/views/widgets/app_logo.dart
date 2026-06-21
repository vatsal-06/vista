import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SaathChaloLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const SaathChaloLogo({
    super.key,
    this.size = 28,
    this.showText = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? AppColors.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.shield_rounded, color: logoColor, size: size),
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            'Saath Chalo',
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.w800,
              color: logoColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ],
    );
  }
}

class SaathChaloShieldIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const SaathChaloShieldIcon({super.key, this.size = 28, this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.shield_rounded,
      color: color ?? AppColors.primary,
      size: size,
    );
  }
}

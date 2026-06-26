import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_routes.dart';
import '../widgets/app_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.vertical,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),

                // ── Logo ────────────────────────────────────────────
                const SaathChaloLogo(size: 30),

                const SizedBox(height: 36),

                // ── Ripple/Ear Illustration ──────────────────────────
                const _RippleEarIllustration(),

                const SizedBox(height: 40),

                // ── Headline ─────────────────────────────────────────
                Text(
                  'Walk with\nConfidence',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Your AI companion for safe,\nindependent navigation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // ── START Button ─────────────────────────────────────
                _StartButton(
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.home),
                ),

                const SizedBox(height: 14),

                // ── Voice Setup secondary button ──────────────────────
                _VoiceSetupButton(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.speakMode),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Ripple + Ear Icon ──────────────────────────────────────────────────────────
class _RippleEarIllustration extends StatelessWidget {
  const _RippleEarIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ripple
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryPale.withOpacity(0.25),
            ),
          ),
          // Middle ripple
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryPale.withOpacity(0.45),
            ),
          ),
          // Inner circle with icon
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
            ),
            child: const Icon(
              Icons.hearing_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
        ],
      ),
    );
  }
}

// ── START Button ───────────────────────────────────────────────────────────────
class _StartButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(32),
        ),
        alignment: Alignment.center,
        child: const Text(
          'START',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
          ),
        ),
      ),
    );
  }
}

// ── Voice Setup Button ──────────────────────────────────────────────────────────
class _VoiceSetupButton extends StatelessWidget {
  final VoidCallback onTap;
  const _VoiceSetupButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.divider),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.mic_rounded, color: AppColors.primaryMuted, size: 22),
            SizedBox(width: 10),
            Text(
              'Voice Setup',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

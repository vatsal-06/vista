import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_routes.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../widgets/app_logo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const SaathChaloLogo(size: 26),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.textPrimary, size: 26),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 28),

              // ── Ready Status Circle ──────────────────────────────
              _ReadyStatusIndicator(),

              const SizedBox(height: 28),

              // ── Status Text ──────────────────────────────────────
              Text(
                vm.statusText,
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                vm.statusSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(),

              // ── START WALK Button ────────────────────────────────
              _StartWalkButton(
                onTap: () {
                  vm.startWalk();
                  Navigator.pushNamed(context, AppRoutes.activeWalk);
                },
              ),

              const SizedBox(height: 16),

              // ── SPEAK Button ─────────────────────────────────────
              _SpeakButton(
                onTap: () {
                  vm.activateSpeakMode();
                  Navigator.pushNamed(context, AppRoutes.speakMode);
                },
              ),

              const SizedBox(height: 16),

              // ── SOS Button ───────────────────────────────────────
              _SOSButton(
                onTap: () {
                  vm.activateSOS();
                  Navigator.pushNamed(context, AppRoutes.sos);
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Ready Status Indicator ──────────────────────────────────────────────────────
class _ReadyStatusIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 32,
            spreadRadius: 8,
          ),
        ],
      ),
      child: const Icon(
        Icons.check_circle_outline_rounded,
        color: Colors.white,
        size: 52,
      ),
    );
  }
}

// ── START WALK Button ──────────────────────────────────────────────────────────
class _StartWalkButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StartWalkButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.directions_walk_rounded,
                color: AppColors.primary, size: 30),
            SizedBox(height: 6),
            Text(
              'START WALK',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SPEAK Button ───────────────────────────────────────────────────────────────
class _SpeakButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SpeakButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.darkButton,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.mic_rounded, color: AppColors.primaryLight, size: 30),
            SizedBox(height: 6),
            Text(
              'SPEAK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SOS Button ─────────────────────────────────────────────────────────────────
class _SOSButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SOSButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              '*',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'SOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

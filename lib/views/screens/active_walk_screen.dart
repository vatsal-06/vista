import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_routes.dart';
import '../../viewmodels/active_walk_viewmodel.dart';
import '../widgets/app_logo.dart';

class ActiveWalkScreen extends StatelessWidget {
  const ActiveWalkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ActiveWalkViewModel(),
      child: const _ActiveWalkContent(),
    );
  }
}

class _ActiveWalkContent extends StatelessWidget {
  const _ActiveWalkContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ActiveWalkViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const SaathChaloLogo(size: 22),
            const Spacer(),
            _ActiveModeBadge(),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ── Direction Arrow + Stay Centered ──────────────────
              _DirectionIndicator(instruction: vm.stayInstruction),

              const SizedBox(height: 24),

              // ── Alert Card ───────────────────────────────────────
              Expanded(
                child: vm.currentAlert != null
                    ? _AlertCard(alert: vm.currentAlert!)
                    : _ClearPathCard(),
              ),

              const SizedBox(height: 20),

              // ── Speak to AI Button ───────────────────────────────
              _SpeakToAIButton(
                onTap: () => Navigator.pushNamed(context, AppRoutes.speakMode),
              ),

              const SizedBox(height: 12),

              // ── Voice command hint ────────────────────────────────
              Text(
                '"Stop Navigation" or "What\'s around me?"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Active Mode Badge ──────────────────────────────────────────────────────────
class _ActiveModeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.dangerPale,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.circle, color: AppColors.danger, size: 10),
          SizedBox(width: 6),
          Text(
            'ACTIVE MODE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.danger,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Direction Indicator ────────────────────────────────────────────────────────
class _DirectionIndicator extends StatelessWidget {
  final String instruction;
  const _DirectionIndicator({required this.instruction});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Arrow cluster
        SizedBox(
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Left diagonal arrow
              Positioned(
                left: MediaQuery.of(context).size.width * 0.27,
                child: Transform.rotate(
                  angle: -0.4,
                  child: const Icon(Icons.arrow_upward_rounded,
                      color: AppColors.primary, size: 32),
                ),
              ),
              // Center main arrow
              const Icon(Icons.arrow_upward_rounded,
                  color: AppColors.primary, size: 48),
              // Right diagonal arrow
              Positioned(
                right: MediaQuery.of(context).size.width * 0.27,
                child: Transform.rotate(
                  angle: 0.4,
                  child: const Icon(Icons.arrow_upward_rounded,
                      color: AppColors.primary, size: 32),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          instruction,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}

// ── Alert Card ─────────────────────────────────────────────────────────────────
class _AlertCard extends StatelessWidget {
  final dynamic alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Warning triangle icon
          Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 60,
            ),
          ),

          const SizedBox(height: 20),

          // Alert title — big bold text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              alert.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.05,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Distance badge
          if (alert.distance != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.dangerPale,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined,
                      color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    alert.distance,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Clear Path Card ────────────────────────────────────────────────────────────
class _ClearPathCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded,
              color: AppColors.primary, size: 64),
          const SizedBox(height: 16),
          const Text(
            'PATH\nCLEAR',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Speak to AI Button ─────────────────────────────────────────────────────────
class _SpeakToAIButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SpeakToAIButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ripple circle behind mic
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.18),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.mic_rounded, color: Colors.white, size: 32),
                SizedBox(height: 4),
                Text(
                  'SPEAK TO AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

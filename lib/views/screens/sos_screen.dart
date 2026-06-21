import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/sos_viewmodel.dart';

class SOSScreen extends StatelessWidget {
  const SOSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SOSViewModel(),
      child: const _SOSContent(),
    );
  }
}

class _SOSContent extends StatelessWidget {
  const _SOSContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SOSViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded,
              color: AppColors.textPrimary, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Saath Chalo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.shield_rounded,
              color: AppColors.danger,
              size: 26,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── Big SOS Button ───────────────────────────────────
              _SOSCircleButton(onTap: vm.triggerSOS),

              const SizedBox(height: 20),

              // ── Press to Alert Label ─────────────────────────────
              Text(
                'PRESS TO ALERT EMERGENCY SERVICES',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.danger,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 36),

              // ── Call Trusted Contact ─────────────────────────────
              _ContactActionCard(
                icon: Icons.phone_rounded,
                iconBgColor: AppColors.primary,
                iconColor: Colors.white,
                title: 'Call Trusted Contact',
                subtitle:
                    '${vm.primaryContact?.name.toUpperCase() ?? "RAHUL"} (PRIMARY)',
                subtitleColor: AppColors.primary,
                onTap: vm.callPrimaryContact,
              ),

              const SizedBox(height: 14),

              // ── Share Location ───────────────────────────────────
              _ContactActionCard(
                icon: Icons.my_location_rounded,
                iconBgColor: AppColors.locationPurple,
                iconColor: Colors.white,
                title: 'Share Location',
                subtitle: 'LIVE TRACKING ACTIVE',
                subtitleColor: AppColors.textSecondary,
                onTap: vm.shareLocation,
              ),

              const Spacer(),

              // ── GPS Status ───────────────────────────────────────
              _GPSStatusBadge(status: vm.gpsStatus),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Big SOS Circle Button ──────────────────────────────────────────────────────
class _SOSCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SOSCircleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow ring
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.dangerLight.withOpacity(0.25),
            ),
          ),
          // Main circle
          Container(
            width: 190,
            height: 190,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.danger,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  '*',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
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

// ── Contact Action Card ────────────────────────────────────────────────────────
class _ContactActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final VoidCallback onTap;

  const _ContactActionCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBgColor,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: subtitleColor,
                    letterSpacing: 0.8,
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

// ── GPS Status Badge ───────────────────────────────────────────────────────────
class _GPSStatusBadge extends StatelessWidget {
  final String status;
  const _GPSStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, color: AppColors.activeGreen, size: 10),
          const SizedBox(width: 8),
          Text(
            'GPS SIGNAL: $status',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

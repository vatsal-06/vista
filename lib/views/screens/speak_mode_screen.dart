import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_routes.dart';
import '../../viewmodels/speak_viewmodel.dart';
import '../../models/models.dart';
import '../widgets/app_logo.dart';
import '../widgets/bottom_nav.dart';

class SpeakModeScreen extends StatelessWidget {
  const SpeakModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SpeakViewModel()..startListening(),
      child: const _SpeakModeContent(),
    );
  }
}

class _SpeakModeContent extends StatelessWidget {
  const _SpeakModeContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SpeakViewModel>();

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
            child: const SaathChaloShieldIcon(size: 26),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // ── Listening Ripple + Mic ───────────────────────────
            _ListeningMicWidget(),

            const SizedBox(height: 36),

            // ── Status Text ──────────────────────────────────────
            Text(
              vm.statusText,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              vm.statusSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),

            const Spacer(),

            // ── Voice Suggestions ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: vm.suggestions
                    .map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SuggestionCard(
                            suggestion: s,
                            onTap: () => vm.onSuggestionTap(s),
                          ),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 16),

            // ── Audio waveform hint ──────────────────────────────
            _WaveformIndicator(),

            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: SaathChaloBottomNav(
        currentIndex: vm.selectedNavIndex,
        onTap: (i) {
          vm.setNavIndex(i);
          switch (i) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.home, (r) => false);
              break;
            case 2:
              break; // routes
            case 3:
              break; // community
          }
        },
        items: const [
          BottomNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home'),
          BottomNavItem(
              icon: Icons.directions_walk_rounded,
              activeIcon: Icons.directions_walk_rounded,
              label: 'Active'),
          BottomNavItem(
              icon: Icons.map_outlined,
              activeIcon: Icons.map_rounded,
              label: 'Routes'),
          BottomNavItem(
              icon: Icons.people_outline_rounded,
              activeIcon: Icons.people_rounded,
              label: 'Community'),
        ],
      ),
    );
  }
}

// ── Listening Mic with Ripple ──────────────────────────────────────────────────
class _ListeningMicWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ripple ring
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryPale.withOpacity(0.3),
            ),
          ),
          // Middle ripple ring
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryPale.withOpacity(0.5),
            ),
          ),
          // Inner mic circle
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(
              Icons.mic_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Suggestion Card ────────────────────────────────────────────────────────────
class _SuggestionCard extends StatelessWidget {
  final VoiceSuggestion suggestion;
  final VoidCallback onTap;

  const _SuggestionCard({required this.suggestion, required this.onTap});

  IconData _iconForType(String type) {
    switch (type) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'direction':
        return Icons.navigation_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _iconColorForType(String type) {
    switch (type) {
      case 'warning':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(
              _iconForType(suggestion.iconType),
              color: _iconColorForType(suggestion.iconType),
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                suggestion.query,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Waveform Indicator (static mock) ──────────────────────────────────────────
class _WaveformIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final heights = [6.0, 12.0, 20.0, 14.0, 24.0, 10.0, 18.0, 8.0, 16.0];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: heights
          .map(
            (h) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 4,
              height: h,
              decoration: BoxDecoration(
                color: AppColors.primaryMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )
          .toList(),
    );
  }
}

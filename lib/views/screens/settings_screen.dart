import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../widgets/app_logo.dart';
import '../widgets/bottom_nav.dart';
import '../../utils/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: const _SettingsContent(),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: const SaathChaloShieldIcon(color: AppColors.primary, size: 26),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Subtitle ────────────────────────────────────────
              const Text(
                'Configure your assistive experience. Each option is designed for high-contrast visibility and ease of touch.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // ── Language ─────────────────────────────────────────
              _SettingsCard(
                title: 'Language',
                subtitle: vm.languageDisplayName,
                subtitleColor: AppColors.primary,
                isHighlighted: false,
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
                onTap: () => _showLanguagePicker(context, vm),
              ),

              const SizedBox(height: 14),

              // ── Voice Selection ───────────────────────────────────
              _SettingsCard(
                title: 'Voice Selection',
                subtitle: vm.voiceDisplayName,
                subtitleColor: AppColors.primary,
                isHighlighted: true,
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
                onTap: () {},
              ),

              const SizedBox(height: 14),

              // ── Haptic Intensity Slider ───────────────────────────
              _HapticCard(vm: vm),

              const SizedBox(height: 14),

              // ── Emergency Contacts (red) ──────────────────────────
              _SettingsCard(
                title: 'Emergency Contacts',
                subtitle: vm.contactCountLabel,
                titleColor: AppColors.danger,
                isHighlighted: false,
                trailing: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.dangerPale,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_outline_rounded,
                      color: AppColors.danger, size: 22),
                ),
                hasDangerBorder: true,
                onTap: () {},
              ),

              const SizedBox(height: 14),

              // ── Screen Reader Mode ────────────────────────────────
              _ToggleCard(
                title: 'Screen Reader Mode',
                subtitle: 'OPTIMIZED FOR TALKBACK',
                value: vm.settings.screenReaderMode,
                onChanged: vm.toggleScreenReader,
              ),

              const SizedBox(height: 14),

              // ── Sign Out ─────────────────────────────────────────
              _SettingsCard(
                title: 'Sign Out',
                isHighlighted: false,
                trailing: null,
                onTap: () {},
                titleColor: AppColors.textSecondary,
              ),

              const SizedBox(height: 24),

              // ── Version ──────────────────────────────────────────
              Center(
                child: Text(
                  'Saath Chalo v1.0.0 • Accessibility First',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SaathChaloBottomNav(
        currentIndex: 3,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.home, (r) => false);
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
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings_rounded,
              label: 'Settings'),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, SettingsViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _LanguageTile(label: 'ENGLISH (US)', onTap: () {
              vm.updateLanguage(AppLanguage.english);
              Navigator.pop(context);
            }),
            _LanguageTile(label: 'HINDI', onTap: () {
              vm.updateLanguage(AppLanguage.hindi);
              Navigator.pop(context);
            }),
            _LanguageTile(label: 'HINGLISH', onTap: () {
              vm.updateLanguage(AppLanguage.hinglish);
              Navigator.pop(context);
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Settings Card ──────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color titleColor;
  final Color subtitleColor;
  final bool isHighlighted;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool hasDangerBorder;

  const _SettingsCard({
    required this.title,
    this.subtitle,
    this.titleColor = AppColors.textPrimary,
    this.subtitleColor = AppColors.primary,
    required this.isHighlighted,
    required this.trailing,
    required this.onTap,
    this.hasDangerBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted
                ? AppColors.primary
                : hasDangerBorder
                    ? AppColors.dangerPale
                    : Colors.transparent,
            width: isHighlighted || hasDangerBorder ? 1.5 : 0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: subtitleColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

// ── Haptic Intensity Card ──────────────────────────────────────────────────────
class _HapticCard extends StatelessWidget {
  final SettingsViewModel vm;
  const _HapticCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Haptic Intensity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                vm.hapticPercentage,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceGrey,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 14,
                elevation: 2,
              ),
              overlayColor: AppColors.primary.withOpacity(0.12),
              trackHeight: 8,
            ),
            child: Slider(
              value: vm.settings.hapticIntensity,
              onChanged: vm.updateHapticIntensity,
              min: 0,
              max: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Toggle Card ────────────────────────────────────────────────────────────────
class _ToggleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
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
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }
}

// ── Language Tile ──────────────────────────────────────────────────────────────
class _LanguageTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LanguageTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textSecondary),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../utils/app_routes.dart';
import '../../viewmodels/routes_viewmodel.dart';
import '../widgets/bottom_nav.dart';

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoutesViewModel()..loadDashboard(),
      child: const _RoutesContent(),
    );
  }
}

class _RoutesContent extends StatefulWidget {
  const _RoutesContent();

  @override
  State<_RoutesContent> createState() => _RoutesContentState();
}

class _RoutesContentState extends State<_RoutesContent> {
  final TextEditingController _sessionController = TextEditingController();

  @override
  void dispose() {
    _sessionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RoutesViewModel>();

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceGrey,
        elevation: 0,
        title: const Text(
          'Routes',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: vm.loadDashboard,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: SafeArea(
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Memory Intelligence',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Saved routes, landmarks, and walk history from your backend memory layer.',
                      style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Saved Routes',
                      icon: Icons.map_rounded,
                      children: vm.savedRoutes
                          .map((route) => _KeyValueRow(
                                primary: (route['name'] ?? 'Unnamed route').toString(),
                                secondary: '${route['source'] ?? '-'} -> ${route['destination'] ?? '-'} • ${route['frequency'] ?? 0} walks',
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Landmarks',
                      icon: Icons.place_rounded,
                      children: vm.landmarks
                          .map((landmark) => _KeyValueRow(
                                primary: (landmark['name'] ?? 'Unknown landmark').toString(),
                                secondary: '${landmark['category'] ?? 'general'} • ${landmark['latitude'] ?? '-'}, ${landmark['longitude'] ?? '-'}',
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Walk History',
                      icon: Icons.history_rounded,
                      children: vm.walkHistory
                          .map((walk) => _KeyValueRow(
                                primary: 'Session ${walk['id'] ?? 'unknown'}',
                                secondary: '${walk['distance'] ?? 0} km • Start ${walk['started_at'] ?? '-'}',
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Walk Session Status',
                      icon: Icons.directions_walk_rounded,
                      children: [
                        TextField(
                          controller: _sessionController,
                          decoration: InputDecoration(
                            hintText: 'Enter session ID',
                            filled: true,
                            fillColor: AppColors.surfaceGrey,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.divider),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.divider),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: vm.isStatusLoading
                                ? null
                                : () => vm.loadWalkStatus(_sessionController.text),
                            child: vm.isStatusLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'CHECK STATUS',
                                    style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.0),
                                  ),
                          ),
                        ),
                        if (vm.walkStatus != null) ...[
                          const SizedBox(height: 12),
                          _KeyValueRow(
                            primary: 'User ${vm.walkStatus!['user_id'] ?? '-'}',
                            secondary: 'Active: ${vm.walkStatus!['is_active'] ?? false} • Distance: ${vm.walkStatus!['distance_walked'] ?? 0}',
                          ),
                        ],
                      ],
                    ),
                    if (vm.errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        vm.errorMessage!,
                        style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: SaathChaloBottomNav(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
          } else if (i == 1) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.activeWalk, (r) => false);
          } else if (i == 3) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.community, (r) => false);
          }
        },
        items: const [
          BottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
          ),
          BottomNavItem(
            icon: Icons.directions_walk_rounded,
            activeIcon: Icons.directions_walk_rounded,
            label: 'Active',
          ),
          BottomNavItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map_rounded,
            label: 'Routes',
          ),
          BottomNavItem(
            icon: Icons.people_outline_rounded,
            activeIcon: Icons.people_rounded,
            label: 'Community',
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (children.isEmpty)
            const Text('No data available.', style: TextStyle(color: AppColors.textSecondary))
          else
            ...children,
        ],
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String primary;
  final String secondary;

  const _KeyValueRow({required this.primary, required this.secondary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            primary,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            secondary,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

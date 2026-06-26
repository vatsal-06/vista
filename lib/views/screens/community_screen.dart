import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../utils/app_routes.dart';
import '../../viewmodels/community_viewmodel.dart';
import '../widgets/bottom_nav.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CommunityViewModel()..loadNearbyHazards(),
      child: const _CommunityContent(),
    );
  }
}

class _CommunityContent extends StatefulWidget {
  const _CommunityContent();

  @override
  State<_CommunityContent> createState() => _CommunityContentState();
}

class _CommunityContentState extends State<_CommunityContent> {
  final TextEditingController _descriptionController = TextEditingController();
  String _hazardType = 'pothole';

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CommunityViewModel>();

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceGrey,
        elevation: 0,
        title: const Text(
          'Community',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: vm.loadNearbyHazards,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Live hazard feed and rapid reporting from nearby users.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 14),
              Container(
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
                    const Text(
                      'Report Hazard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _hazardType,
                      decoration: InputDecoration(
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
                      items: const [
                        DropdownMenuItem(value: 'pothole', child: Text('Pothole')),
                        DropdownMenuItem(value: 'open drain', child: Text('Open Drain')),
                        DropdownMenuItem(value: 'roadblock', child: Text('Roadblock')),
                        DropdownMenuItem(value: 'construction', child: Text('Construction')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _hazardType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add context (optional)',
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
                        onPressed: vm.isReporting
                            ? null
                            : () async {
                                await vm.reportHazard(
                                  hazardType: _hazardType,
                                  description: _descriptionController.text,
                                );
                                if (!mounted) return;
                                _descriptionController.clear();
                              },
                        child: vm.isReporting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'REPORT HAZARD',
                                style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.0),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
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
                    const Text(
                      'Nearby Hazards',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (vm.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      )
                    else if (vm.nearbyHazards.isEmpty)
                      Text(
                        vm.statusMessage ?? 'No hazards reported nearby.',
                        style: const TextStyle(color: AppColors.textSecondary),
                      )
                    else
                      ...vm.nearbyHazards.map(
                        (hazard) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.warning,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${hazard['hazard_type'] ?? 'hazard'} • ${hazard['description'] ?? 'no description'}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (vm.statusMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  vm.statusMessage!,
                  style: TextStyle(
                    color: vm.statusMessage!.toLowerCase().contains('failed')
                        ? AppColors.danger
                        : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SaathChaloBottomNav(
        currentIndex: 3,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
          } else if (i == 1) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.activeWalk, (r) => false);
          } else if (i == 2) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.routes, (r) => false);
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

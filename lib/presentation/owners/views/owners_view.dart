import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:apartmate/core/constants/app_colors.dart';
import 'package:apartmate/core/constants/app_dimens.dart';
import 'package:apartmate/core/constants/app_text_styles.dart';
import 'package:apartmate/core/widgets/app_bottom_nav.dart';
import 'package:apartmate/core/widgets/app_responsive_container.dart';
import 'package:apartmate/core/widgets/app_skeletons.dart';
import 'package:apartmate/core/widgets/send_update_sheet.dart';
import 'package:apartmate/core/utils/app_snackbar.dart';
import 'package:apartmate/data/models/owner_model.dart';
import 'package:apartmate/presentation/owners/controllers/owners_controller.dart';
import 'package:apartmate/routes/app_routes.dart';

class OwnersView extends GetView<OwnersController> {
  const OwnersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AppAddFab(
        onPressed: showSendUpdateSheet,
      ),
      bottomNavigationBar: AppBottomNav(
        activeTab: AppNavTab.home,
        onHome: () => Get.offNamed(AppRoutes.dashboard),
        onUpdates: () => Get.offNamed(AppRoutes.updates),
        onRequests: () => Get.offNamed(AppRoutes.requests),
        onProfile: () => Get.toNamed(AppRoutes.profile),
      ),
      body: Column(
        children: [
          // ── Header (same style as Updates) ──────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppDimens.headerRadius),
                bottomRight: Radius.circular(AppDimens.headerRadius),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  // Back
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.textOnDark.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textOnDark,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title
                  Expanded(
                    child: Text(
                      'Owners',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ),

                  // Logo
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen,
                          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                        ),
                        child: const Icon(
                          Icons.villa_rounded,
                          size: 22,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.owners.isEmpty) {
                return const AppSkeletonList(
                  itemBuilder: StaffTileSkeleton.new,
                );
              }

              if (controller.owners.isEmpty) {
                return _EmptyOwnersState(onRefresh: controller.refresh);
              }

              return RefreshIndicator(
                color: AppColors.primaryDark,
                onRefresh: controller.refresh,
                child: AppResponsiveContainer(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: controller.owners.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _OwnerTile(owner: controller.owners[index]);
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _EmptyOwnersState extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _EmptyOwnersState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryDark,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/lottie/persons.json',
                      width: 220,
                      height: 180,
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                    const SizedBox(height: 20),
                    Text('No owners yet', style: AppTextStyles.h4),
                    const SizedBox(height: 8),
                    Text(
                      'Owners will appear here once they are added!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerTile extends StatelessWidget {
  final OwnerModel owner;
  const _OwnerTile({required this.owner});

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: owner.phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      AppSnackbar.error('Unable to open dialer', 'No phone app available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.ownerDetail, arguments: owner),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                owner.initials,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(owner.name, style: AppTextStyles.h4),
                      ),
                      IconButton(
                        onPressed: _call,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        icon: const Icon(
                          Icons.call_rounded,
                          size: 20,
                          color: AppColors.successGreenDark,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              AppColors.successGreen.withValues(alpha: 0.12),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${owner.buildingName} · Flat ${owner.flatNumber}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    owner.phone,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
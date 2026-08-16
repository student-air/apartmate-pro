import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:apartmate/core/constants/app_colors.dart';
import 'package:apartmate/core/constants/app_dimens.dart';
import 'package:apartmate/core/constants/app_text_styles.dart';
import 'package:apartmate/core/widgets/app_skeletons.dart';
import 'package:apartmate/data/models/committee_model.dart';
import 'package:apartmate/core/widgets/app_bottom_nav.dart';
import 'package:apartmate/core/widgets/send_update_sheet.dart';
import 'package:apartmate/routes/app_routes.dart';
// import 'package:apartmate/core/widgets/app_responsive_container.dart';
import 'package:apartmate/presentation/committee/controllers/committee_controller.dart';

class CommitteeView extends GetView<CommitteeController> {
  const CommitteeView({super.key});

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
        // ── Header ────────────────────────────────────────────────
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
                    'Committee',
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

        // ── Body ──────────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.members.isEmpty) {
              return const AppSkeletonList(
                itemBuilder: StaffTileSkeleton.new,
              );
            }

            if (controller.members.isEmpty) {
              return RefreshIndicator(
                color: AppColors.primaryDark,
                onRefresh: controller.refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(
                        child: _EmptyCommitteeState(),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primaryDark,
              onRefresh: controller.refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                itemCount: controller.members.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _MemberTile(member: controller.members[i]),
              ),
            );
          }),
        ),
      ],
    ),
  );
}
}

class _EmptyCommitteeState extends StatelessWidget {
  const _EmptyCommitteeState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/lottie/committee.json',
            width: 220,
            height: 180,
            fit: BoxFit.contain,
            repeat: true,
          ),
          const SizedBox(height: 20),
          Text('No committee members yet', style: AppTextStyles.h4),
          const SizedBox(height: 8),
          Text(
            'Committee members will appear here once they are added !',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final CommitteeMemberModel member;
  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 3)),
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
              member.initials,
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryDark),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: AppTextStyles.h4),
                const SizedBox(height: 2),
                Text(
                  member.role,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  member.phone,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
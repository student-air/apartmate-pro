import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:apartmate/core/constants/app_colors.dart';
import 'package:apartmate/core/constants/app_dimens.dart';
import 'package:apartmate/core/constants/app_text_styles.dart';
import 'package:apartmate/core/widgets/app_bottom_nav.dart';
import 'package:apartmate/core/widgets/app_responsive_container.dart';
import 'package:apartmate/core/widgets/app_skeletons.dart';
import 'package:apartmate/core/widgets/send_update_sheet.dart';
import 'package:apartmate/presentation/dashboard/controllers/dashboard_controller.dart';
import 'package:apartmate/presentation/updates/controllers/updates_badge_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshRequestCounts();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _DashboardDrawer(controller: controller),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AppAddFab(onPressed: showSendUpdateSheet),
      bottomNavigationBar: AppBottomNav(
        activeTab: AppNavTab.home,
        onHome: () {},
        onUpdates: controller.goToUpdates,
        onRequests: controller.goToRequests,
        onProfile: controller.goToProfile,
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const AppSkeletonList(itemBuilder: StaffTileSkeleton.new);
          }
          return RefreshIndicator(
            color: AppColors.primaryDark,
            onRefresh: controller.refreshAll,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              child: AppResponsiveContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TopBar(controller: controller),
                    const SizedBox(height: 20),
                    _GreetingRow(controller: controller),
                    const SizedBox(height: 18),
                    _MetricsRow(controller: controller),
                    const SizedBox(height: 16),
                    _PendingApprovalsCard(controller: controller),
                    const SizedBox(height: 16),
                    _QuickActions(controller: controller),
                    const SizedBox(height: 16),
                    _ResidentsOverviewCard(controller: controller),
                    const SizedBox(height: 16),
                    _RecentActivityCard(controller: controller),
                    const SizedBox(height: 16),
                    _OccupancyOverview(controller: controller),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Side drawer ──────────────────────────────────────────
class _DashboardDrawer extends StatelessWidget {
  final DashboardController controller;
  const _DashboardDrawer({required this.controller});

  void _closeAnd(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.primaryDark,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 16,
              bottom: 20,
            ),
            child: Obx(() {
              final name = controller.societyNameText.isEmpty
                  ? 'ApartMate'
                  : controller.societyNameText;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h4.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.roleDisplay,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.accentGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              );
            }),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _DrawerTile(
                  icon: LucideIcons.building_2,
                  label: 'Buildings',
                  onTap: () => _closeAnd(context, controller.goToBuildings),
                ),
                _DrawerTile(
                  icon: Icons.groups_rounded,
                  label: 'Residents',
                  onTap: () => _closeAnd(context, controller.goToResidents),
                ),
                _DrawerTile(
                  icon: LucideIcons.crown,
                  label: 'Owners',
                  onTap: () => _closeAnd(context, controller.goToOwners),
                ),
                _DrawerTile(
                  icon: Icons.groups_2_rounded,
                  label: 'Committee',
                  onTap: () => _closeAnd(context, controller.goToCommittee),
                ),
                _DrawerTile(
                  icon: Icons.badge_rounded,
                  label: 'Staff',
                  onTap: () => _closeAnd(context, controller.goToAddStaff),
                ),
                _DrawerTile(
                  icon: Icons.inbox_rounded,
                  label: 'Requests',
                  onTap: () => _closeAnd(context, controller.goToRequests),
                ),
                _DrawerTile(
                  icon: Icons.campaign_rounded,
                  label: 'Updates',
                  onTap: () => _closeAnd(context, controller.goToUpdates),
                ),
                _DrawerTile(
                  icon: Icons.report_problem_rounded,
                  label: 'Complaints',
                  onTap: () => _closeAnd(context, controller.goToComplaints),
                ),
                _DrawerTile(
                  icon: Icons.edit_rounded,
                  label: 'Edit Society',
                  onTap: () => _closeAnd(context, controller.goToEditSociety),
                ),
                _DrawerTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  onTap: () => _closeAnd(context, controller.goToProfile),
                ),
                const SizedBox(height: 8),
                const Divider(color: AppColors.borderLight),
                _DrawerTile(
                  icon: Icons.logout_rounded,
                  label: 'Log out',
                  color: AppColors.danger,
                  onTap: () => _closeAnd(context, controller.confirmLogout),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: c, size: 22),
      title: Text(label, style: AppTextStyles.labelLarge.copyWith(color: c)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textMuted, size: 20),
      onTap: onTap,
    );
  }
}

// ── Top bar ──────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final DashboardController controller;
  const _TopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconCircle(
          icon: Icons.menu_rounded,
          onTap: () => Scaffold.of(context).openDrawer(),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Obx(() {
            final name = controller.societyNameText.isEmpty
                ? 'SOCIETY'
                : controller.societyNameText.toUpperCase();
            return Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge.copyWith(
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              ],
            );
          }),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            _IconCircle(
              icon: Icons.notifications_none_rounded,
              onTap: controller.goToUpdates,
            ),
            if (Get.isRegistered<UpdatesBadgeController>())
              Obx(() {
                final n = Get.find<UpdatesBadgeController>().unreadCount.value;
                if (n <= 0) return const SizedBox.shrink();
                return Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      n > 9 ? '9+' : '$n',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: controller.goToProfile,
          child: Obx(() {
            final photo = controller.society.value?.ownerPhotoPath;
            final has = photo != null && photo.isNotEmpty;
            final initial = controller.ownerInitials.isEmpty
                ? 'A'
                : controller.ownerInitials[0];
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.roleAdminText,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              alignment: Alignment.center,
              child: has
                  ? ClipOval(
                      child: Image.file(
                        File(photo),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Greeting + date + join code ──────────────────────────
class _GreetingRow extends StatelessWidget {
  final DashboardController controller;
  const _GreetingRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM yyyy, EEE').format(DateTime.now());
    final isNight = DashboardController.greeting == 'Good Evening' ||
        DashboardController.greeting == 'Good Night';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${DashboardController.greeting},',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary),
              ),
              Obx(
                () => Text(
                  '${controller.ownerFirstName}.',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.accentGreenDark,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Society\nOwner',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded,
                            size: 12, color: AppColors.accentGreenDark),
                        const SizedBox(width: 4),
                        Text(
                          'Admin',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentGreenDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            "Today's Date",
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: AppTextStyles.labelMedium
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                    color:
                        isNight ? AppColors.roleAdminText : AppColors.warning,
                    size: 22,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _JoinCodeExpandButton(onCopy: controller.copyJoinCode),
          ],
        ),
      ],
    );
  }
}

// ── Metrics ──────────────────────────────────────────────
class _MetricsRow extends StatelessWidget {
  final DashboardController controller;
  const _MetricsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final buildings = controller.stats.value?.buildings ?? 0;

      return Row(
        children: [
          Expanded(
            child: _MetricCard(
              icon: Icons.home,
              iconBg: AppColors.rolePlumberBg,
              iconColor: AppColors.accentGreenDark,
              value: '$buildings',
              label: 'Buildings',
              subtitle: 'Active',
              subtitleColor: AppColors.accentGreenDark,
              onTap: controller.goToBuildings,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetricCard(
              icon: LucideIcons.crown,
              iconBg: AppColors.dangerBg,
              iconColor: Colors.red,
              value: '${controller.ownersCount.value}',
              label: 'Owners',
              subtitle: 'Total',
              subtitleColor: Colors.red,
              onTap: controller.goToOwners,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetricCard(
              icon: LucideIcons.user,
              iconBg: const Color(0xFFEEE8FF),
              iconColor: const Color(0xFF7C3AED),
              value: '${controller.residentsCount.value}',
              label: 'Residents',
              subtitle: 'Total',
              subtitleColor: const Color(0xFF7C3AED),
              onTap: controller.goToResidents,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetricCard(
              icon: Icons.groups_2_rounded,
              iconBg: AppColors.pendingBg,
              iconColor: AppColors.pending,
              value: '${controller.committeeCount.value}',
              label: 'Committee',
              subtitle: 'Members',
              subtitleColor: AppColors.pending,
              onTap: controller.goToCommittee,
            ),
          ),
        ],
      );
    });
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final String subtitle;
  final Color subtitleColor;
  final VoidCallback onTap;

  const _MetricCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.subtitle,
    required this.subtitleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 14, color: iconColor),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      size: 14, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: AppTextStyles.h4
                    .copyWith(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary, fontSize: 10),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: subtitleColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pending Requests ─────────────────────────────────────
class _PendingApprovalsCard extends StatelessWidget {
  final DashboardController controller;
  const _PendingApprovalsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Pending Requests',
                style: AppTextStyles.labelLarge
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              TextButton(
                onPressed: controller.goToRequests,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accentGreenDark,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Obx(() {
            return Column(
              children: [
                _PendingCategoryRow(
                  icon: Icons.person_rounded,
                  iconBg: AppColors.dangerBg,
                  iconColor: AppColors.danger,
                  label: 'Owner Approvals',
                  count: controller.pendingOwnerRequestsCount.value,
                  onTap: controller.goToRequests,
                ),
                const Divider(height: 1, color: AppColors.borderLight),
                _PendingCategoryRow(
                  icon: Icons.home_work_rounded,
                  iconBg: const Color(0xFFEEE8FF),
                  iconColor: const Color(0xFF7C3AED),
                  label: 'Tenancy Approvals',
                  count: controller.pendingTenantRequestsCount.value,
                  onTap: controller.goToResidents,
                ),
                const Divider(height: 1, color: AppColors.borderLight),
                _PendingCategoryRow(
                  icon: Icons.description_outlined,
                  iconBg: const Color(0xFFE0F2FE),
                  iconColor: const Color(0xFF0284C7),
                  label: 'Property Updates',
                  count: controller.pendingPropertyUpdatesCount.value,
                  onTap: controller.goToUpdates,
                ),
              ],
            );
          }),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: controller.goToRequests,
              icon: const Icon(Icons.checklist_rounded,
                  size: 18, color: Colors.white),
              label: Text(
                'Review All Requests',
                style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingCategoryRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _PendingCategoryRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.labelLarge)),
            Text(
              '$count',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ── Quick Actions ────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final DashboardController controller;
  const _QuickActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style:
                AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickChip(
                  icon: Icons.home_work_rounded,
                  color: AppColors.accentGreenDark,
                  label: 'Edit Society',
                  onTap: controller.goToEditSociety,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickChip(
                  icon: Icons.person_add_alt_1_rounded,
                  color: AppColors.roleAdminText,
                  label: 'Add Staff',
                  onTap: controller.goToAddStaff,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickChip(
                  icon: Icons.campaign_rounded,
                  color: const Color(0xFF8B5CF6),
                  label: 'Post Update',
                  onTap: showSendUpdateSheet,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(
                  () => _QuickChip(
                    icon: Icons.chat_bubble_outline_rounded,
                    color: AppColors.warning,
                    label: 'Complaints',
                    badgeCount: controller.complaintsCount.value,
                    onTap: controller.goToComplaints,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final int? badgeCount;

  const _QuickChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final showBadge = badgeCount != null && badgeCount! > 0;

    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: color, size: 20),
                  if (showBadge)
                    Positioned(
                      right: -10,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badgeCount! > 9 ? '9+' : '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Residents Overview (overall Owners + Tenants) ────────
class _ResidentsOverviewCard extends StatelessWidget {
  final DashboardController controller;
  const _ResidentsOverviewCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final owners = controller.ownersCount.value;
      final tenants = controller.residentsCount.value;
      final total = owners + tenants;
      final oFrac = total == 0 ? 0.0 : owners / total;
      final tFrac = total == 0 ? 0.0 : tenants / total;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Residents Overview',
              style: AppTextStyles.labelLarge
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      segments: [
                        (oFrac, AppColors.accentGreen),
                        (tFrac, const Color(0xFF3B82F6)),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: AppTextStyles.h3
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'Total',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      _LegendRow(
                        color: AppColors.accentGreen,
                        label: 'Owners',
                        value: '$owners',
                      ),
                      const SizedBox(height: 14),
                      _LegendRow(
                        color: const Color(0xFF3B82F6),
                        label: 'Tenants',
                        value: '$tenants',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppTextStyles.bodySmall)),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<(double, Color)> segments;
  _DonutPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    paint.color = AppColors.surfaceMuted;
    canvas.drawArc(rect.deflate(8), 0, 2 * math.pi, false, paint);

    var start = -math.pi / 2;
    for (final (frac, color) in segments) {
      if (frac <= 0) continue;
      final sweep = frac * 2 * math.pi;
      paint.color = color;
      canvas.drawArc(rect.deflate(8), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.segments != segments;
}

// ── Recent activity ──────────────────────────────────────
class _RecentActivityCard extends StatelessWidget {
  final DashboardController controller;
  const _RecentActivityCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Recent Activity',
                style: AppTextStyles.labelLarge
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              TextButton(
                onPressed: controller.goToUpdates,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accentGreenDark,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('View All'),
              ),
            ],
          ),
          Obx(() {
            final items = controller.recentActivity;
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No recent activity yet',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted),
                ),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: AppColors.borderLight),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: items[i].iconColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(items[i].icon,
                          size: 18, color: items[i].iconColor),
                    ),
                    title: Text(
                      items[i].title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMedium
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      items[i].timeLabel,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Occupancy ────────────────────────────────────────────
class _OccupancyOverview extends StatelessWidget {
  final DashboardController controller;
  const _OccupancyOverview({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'OCCUPANCY OVERVIEW',
          style: AppTextStyles.overline.copyWith(color: AppColors.primaryDark),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final list = controller.buildingOccupancy;
          if (list.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                'No buildings yet',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            );
          }
          return Column(
            children: [
              for (var i = 0; i < list.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _OccupancyCard(item: list[i]),
              ],
            ],
          );
        }),
      ],
    );
  }
}

class _OccupancyCard extends StatelessWidget {
  final BuildingOccupancy item;
  const _OccupancyCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final pct = item.percent;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.buildingName,
            style: AppTextStyles.labelLarge
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${item.occupiedFlats}/${item.totalFlats} flats',
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
              const Spacer(),
              Text(
                '${(pct * 100).round()}%',
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.accentGreenDark),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: AppColors.surfaceMuted,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ── Join code key ────────────────────────────────────────
class _JoinCodeExpandButton extends StatefulWidget {
  final VoidCallback onCopy;
  const _JoinCodeExpandButton({required this.onCopy});

  @override
  State<_JoinCodeExpandButton> createState() => _JoinCodeExpandButtonState();
}

class _JoinCodeExpandButtonState extends State<_JoinCodeExpandButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _t;
  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _t = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 2200));
      if (!mounted) return;
      setState(() => _expanded = false);
      await _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_expanded) {
      widget.onCopy();
      return;
    }
    setState(() => _expanded = true);
    _controller.reverse().then((_) async {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      setState(() => _expanded = false);
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final code = Get.find<DashboardController>().joinCode;

    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        final t = _t.value;
        final width = 40 + (120 * (1 - t));
        final radius = 20 + (12 * (1 - t));

        return GestureDetector(
          onTap: _onTap,
          child: Container(
            width: width,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: t < 0.5
                ? Opacity(
                    opacity: (1 - t * 2).clamp(0.0, 1.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              code.isEmpty ? '————' : code,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.accentGreen,
                                fontFamily: 'monospace',
                                letterSpacing: 1.5,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.copy_rounded,
                            size: 16,
                            color: AppColors.accentGreen,
                          ),
                        ],
                      ),
                    ),
                  )
                : Opacity(
                    opacity: ((t - 0.5) * 2).clamp(0.0, 1.0),
                    child: const Icon(
                      Icons.key_rounded,
                      size: 20,
                      color: AppColors.accentGreen,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
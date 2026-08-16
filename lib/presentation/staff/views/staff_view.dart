
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:apartmate/core/constants/app_colors.dart';
import 'package:apartmate/core/constants/app_dimens.dart';
import 'package:apartmate/core/constants/app_strings.dart';
import 'package:apartmate/core/constants/app_text_styles.dart';
import 'package:apartmate/core/widgets/app_animations.dart';
import 'package:apartmate/core/widgets/app_button.dart';
import 'package:apartmate/core/widgets/app_card.dart';
import 'package:apartmate/core/widgets/app_confirm_delete_dialog.dart';
import 'package:apartmate/core/widgets/app_dropdown_field.dart';
import 'package:apartmate/core/widgets/app_responsive_container.dart';
import 'package:apartmate/core/widgets/app_text_field.dart';
import 'package:apartmate/data/models/staff_model.dart';
import 'package:apartmate/presentation/staff/controllers/staff_controller.dart';
import 'package:apartmate/core/widgets/app_skeletons.dart';

class StaffView extends GetView<StaffController> {
  const StaffView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.managementStaff,
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnDark),
        ),
        iconTheme: const IconThemeData(color: AppColors.textOnDark),
        actions: [
          IconButton(
            onPressed: () {
              controller.resetForm();
              _showStaffFormSheet(context);
            },
            icon: const Icon(Icons.add, color: AppColors.textOnDark),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppSkeletonList(itemBuilder: StaffTileSkeleton.new);
        }

        return Stack(
          children: [
            // Background character
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '合',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 260,
                      color: AppColors.primaryDark.withValues(alpha: 0.04),
                    ),
                  ),
                ),
              ),
            ),

            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: AppResponsiveContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (controller.staff.isEmpty)
                            const _EmptyStaffState()
                          else
                            ...controller.staff.map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _StaffTile(
                                  staff: s,
                                  onEdit: () {
                                    controller.startEditing(s);
                                    _showStaffFormSheet(context);
                                  },
                                  onDelete: () => _confirmDelete(context, s),
                                  justSaved:
                                      controller.justSavedStaffId.value == s.id,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              controller.resetForm();
                              _showStaffFormSheet(context);
                            },
                            icon: const Icon(
                              Icons.add,
                              size: 20,
                              color: AppColors.primaryDark,
                            ),
                            label: Text(
                              AppStrings.addStaff,
                              style: AppTextStyles.labelLarge,
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              side: BorderSide(
                                color: AppColors.primaryDark
                                    .withValues(alpha: 0.3),
                                width: 1.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radius2xl,
                                ),
                              ),
                              backgroundColor: AppColors.surface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        top: BorderSide(color: AppColors.borderLight),
                      ),
                    ),
                    child: AppPrimaryButton(
                      label: AppStrings.saveAndGoToDashboard,
                      icon: Icons.check,
                      onPressed: controller.goToDashboard,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  void _showStaffFormSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Dark header (same style as File a complaint) ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textOnDark.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.badge_rounded,
                            color: AppColors.accentGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.isEditing
                                    ? 'Edit Staff Member'
                                    : AppStrings.addStaffMember,
                                style: AppTextStyles.h4.copyWith(
                                  color: AppColors.textOnDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Add staff details for your society',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textOnDarkMuted,
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

              // ── Form body ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Obx(
                  () => AppShakeOnTrigger(
                    trigger: controller.staffShakeTrigger.value,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Full Name
                        AppTextField(
                          label: AppStrings.fullName,
                          hint: AppStrings.fullNameHint,
                          controller: controller.nameCtrl,
                        ),
                        const SizedBox(height: 16),

                        // Phone Number
                        AppTextField(
                          label: AppStrings.phoneNumber,
                          hint: AppStrings.phoneHint,
                          controller: controller.phoneCtrl,
                          keyboardType: TextInputType.phone,
                        ),
                        Obx(() {
                          final error = controller.phoneError.value;
                          if (error == null) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 14,
                                  color: AppColors.danger,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    error,
                                    style: AppTextStyles.bodySmall
                                        .copyWith(color: AppColors.danger),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 16),

                        // Role
                        Obx(
                          () => AppDropdownField<StaffRole>(
                            label: AppStrings.role,
                            value: controller.selectedRole.value,
                            items: StaffRole.values,
                            labelBuilder: (r) => r.label,
                            onChanged: controller.setRole,
                          ),
                        ),
                        Obx(() {
                          if (controller.selectedRole.value != StaffRole.other) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: AppTextField(
                              label: 'Role Name',
                              hint: 'e.g. Gardener',
                              controller: controller.customRoleCtrl,
                            ),
                          );
                        }),
                        const SizedBox(height: 16),

                        // Info banner
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusMd),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: AppColors.roleAdminText,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Staff will appear as Pending until they join using the society code in the user app.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.roleAdminText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Submit button
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: controller.saveStaff,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppDimens.radiusFull),
                              ),
                            ),
                            child: Text(
                              controller.isEditing
                                  ? 'Save Staff Member'
                                  : AppStrings.saveStaffMember,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.accentGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Cancel
                        TextButton(
                          onPressed: Get.back,
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      enterBottomSheetDuration: const Duration(milliseconds: 400),
    );
  }

  void _confirmDelete(BuildContext context, StaffModel member) {
    showAppDeleteConfirmation(
      context: context,
      title: 'Delete staff member?',
      message:
          'This will permanently remove "${member.name}" from your staff list.',
      confirmLabel: 'Delete Staff Member',
      onConfirm: () => controller.deleteStaff(member.id),
    );
  }
}

class _EmptyStaffState extends StatelessWidget {
  const _EmptyStaffState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Lottie.asset(
            'assets/lottie/staff.json',
            width: 320,
            height: 280,
            fit: BoxFit.contain,
            repeat: true,
          ),
          const SizedBox(height: 20),
          Text(AppStrings.noStaffAdded, style: AppTextStyles.h4),
          const SizedBox(height: 6),
          Text(
            AppStrings.noStaffHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Staff Tile (Pending = blur + slide delete | Active = normal + delete button)
// ────────────────────────────────────────────────
class _StaffTile extends StatefulWidget {
  final StaffModel staff;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool justSaved;

  const _StaffTile({
    required this.staff,
    required this.onEdit,
    required this.onDelete,
    this.justSaved = false,
  });

  @override
  State<_StaffTile> createState() => _StaffTileState();
}

class _StaffTileState extends State<_StaffTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scale;
  late final Animation<double> _badgeOpacity;

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.03), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.03, end: 1.0), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));
    _badgeOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    ]).animate(_pulseController);

    if (widget.justSaved) _pulseController.forward();
  }

  @override
  void didUpdateWidget(covariant _StaffTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.justSaved && !oldWidget.justSaved) {
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  ({Color bg, Color fg, Color border}) get _roleColors {
    switch (widget.staff.role) {
      case StaffRole.admin:
        return (
          bg: AppColors.roleAdminBg,
          fg: AppColors.roleAdminText,
          border: AppColors.roleAdminBorder
        );
      case StaffRole.reception:
        return (
          bg: AppColors.roleReceptionBg,
          fg: AppColors.roleReceptionText,
          border: AppColors.roleReceptionBorder
        );
      case StaffRole.electrician:
        return (
          bg: AppColors.roleElectricianBg,
          fg: AppColors.roleElectricianText,
          border: AppColors.roleElectricianBorder
        );
      case StaffRole.plumber:
        return (
          bg: AppColors.rolePlumberBg,
          fg: AppColors.rolePlumberText,
          border: AppColors.rolePlumberBorder
        );
      case StaffRole.securityGuard:
        return (
          bg: AppColors.roleSecurityBg,
          fg: AppColors.roleSecurityText,
          border: AppColors.roleSecurityBorder
        );
      case StaffRole.other:
        return (
          bg: AppColors.surfaceMuted,
          fg: AppColors.textSecondary,
          border: AppColors.borderLight
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final staff = widget.staff;
    final colors = _roleColors;
    final isPending = staff.status == StaffStatus.active; // ← fixed

    final cardContent = AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Opacity(
              opacity: isPending ? 0.85 : 1.0,
              child: Stack(
                children: [
                  child!,
                  if (isPending)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusLg),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 1.2, sigmaY: 1.2),
                          child: Container(
                            color: AppColors.surface.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Just Saved pulse badge
            Positioned(
              top: -8,
              right: -8,
              child: Opacity(
                opacity: _badgeOpacity.value,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: AppColors.successGreenDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      child: AppCard(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colors.bg,
            shape: BoxShape.circle,
            border: Border.all(color: colors.border),
          ),
          alignment: Alignment.center,
          child: staff.photoPath != null && staff.photoPath!.isNotEmpty
              ? ClipOval(
                  child: Image.network(          // will come from other app
                    staff.photoPath!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Text(
                      staff.initials,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: colors.fg,
                        fontSize: 15,
                      ),
                    ),
                  ),
                )
              : Text(
                  staff.initials,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: colors.fg,
                    fontSize: 25,
                  ),
                ),
        ),
        const SizedBox(width: 18),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                staff.name,
                style: AppTextStyles.h4,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                staff.phone,
                style: AppTextStyles.bodyMedium
                .copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _Badge(
                    label: staff.roleDisplayLabel,
                    bg: colors.bg,
                    fg: colors.fg,
                    border: colors.border,
                  ),
                  _Badge(
                    label: isPending ? 'PENDING' : 'ACTIVE',
                    bg: isPending
                        ? AppColors.pendingBg
                        : AppColors.successGreen.withValues(alpha: 0.15),
                    fg: isPending
                        ? AppColors.pending
                        : AppColors.successGreenDark,
                    border: isPending
                        ? AppColors.pendingBorder
                        : AppColors.successGreen,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Buttons
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: widget.onEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
              icon: const Icon(Icons.edit_rounded, size: 17, color: AppColors.textSecondary),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceMuted,
                shape: const CircleBorder(),
              ),
            ),
            if (!isPending) ...[
              const SizedBox(height: 0),
              IconButton(
                onPressed: widget.onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                icon: const Icon(Icons.delete_rounded, size: 17, color: AppColors.danger),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.dangerBg,
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  ),
)
    );

    // Slide-to-delete only when Pending
    if (isPending) {
      return Dismissible(
        key: Key(staff.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          bool confirmed = false;
          await showAppDeleteConfirmation(
            context: context,
            title: 'Delete staff member?',
            message:
                'This will permanently remove "${staff.name}" from your staff list.',
            confirmLabel: 'Delete Staff Member',
            onConfirm: () {
              confirmed = true;
            },
          );
          return confirmed;
        },
        onDismissed: (_) => widget.onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
          child: const Icon(
            Icons.delete_rounded,
            color: AppColors.textOnDark,
            size: 28,
          ),
        ),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final Color? border;

  const _Badge({
    required this.label,
    required this.bg,
    required this.fg,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: border != null ? Border.all(color: border!) : null,
      ),
      child: Text(label, style: AppTextStyles.labelMedium.copyWith(color: fg)),
    );
  }
}
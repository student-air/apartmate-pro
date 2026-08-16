import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:apartmate/core/constants/app_colors.dart';
import 'package:apartmate/core/constants/app_dimens.dart';
import 'package:apartmate/core/constants/app_strings.dart';
import 'package:apartmate/core/constants/app_text_styles.dart';
import 'package:apartmate/core/utils/app_snackbar.dart';
import 'package:apartmate/core/widgets/app_responsive_container.dart';
import 'package:apartmate/presentation/profile/controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryDark,
          onRefresh: controller.refreshSociety,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: AppResponsiveContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ──
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 72),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(AppDimens.headerRadius),
                        bottomRight: Radius.circular(AppDimens.headerRadius),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('My Profile', style: AppTextStyles.h1.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),

                  // ── Overlapping content ──
                  Transform.translate(
                    offset: const Offset(0, -48),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Profile card
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppDimens.radius2xl),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 14,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Column(
                                  children: [
                                    Obx(() {
                                      final path = controller.ownerPhotoPath.value;
                                      return Container(
                                        width: 88,
                                        height: 88,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryDark,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: path != null && path.isNotEmpty
                                            ? ClipOval(
                                                child: Image.file(
                                                  File(path),
                                                  width: 88,
                                                  height: 88,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Text(
                                                controller.initials,
                                                style: AppTextStyles.h1.copyWith(color: AppColors.accentGreen),
                                              ),
                                      );
                                    }),
                                    const SizedBox(height: 14),
                                    Obx(
                                      () => Text(
                                        controller.fullName,
                                        style: AppTextStyles.h3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentGreen
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(
                                          AppDimens.radiusFull,
                                        ),
                                      ),
                                      child: Text(
                                        controller.role.toUpperCase(),
                                        style: AppTextStyles.labelMedium
                                            .copyWith(
                                          color: AppColors.accentGreenDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 0,
                                  right: 8,
                                  child: IconButton(
                                    onPressed: controller.goToEditProfile,
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: AppColors.textSecondary,
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.surfaceMuted,
                                      shape: const CircleBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Obx(() {
                            final code = controller.joinCode.value;
                            if (code.isEmpty) return const SizedBox.shrink();
                            return Column(
                              children: [
                                SizedBox(
                      height: 140,
                      width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
        Positioned.fill(
                    child: Lottie.asset(
                      'assets/lottie/code.json',
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 60,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'SOCIETY JOIN CODE',
                                                    style: AppTextStyles.overline
                                                        .copyWith(
                                                      color: Colors.white,
                                                      letterSpacing: 1,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  SelectableText(
                                                    code,
                                                    style: AppTextStyles.h4
                                                        .copyWith(
                                                      color: Colors.white,
                                                      fontFamily: 'monospace',
                                                      letterSpacing: 2,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Clipboard.setData(
                                                  ClipboardData(text: code),
                                                );
                                                AppSnackbar.info(
                                                  'Copied',
                                                  'Society code copied to clipboard',
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.copy_rounded,
                                                size: 32,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),

                
const SizedBox(height: 0),
                          // Contact
                          _SectionCard(
                            title: 'Contact Information',
                            children: [
                              _InfoRow(
                                icon: Icons.phone_rounded,
                                label: 'Phone Number',
                                value: controller.phone,
                                onCopy: () => _copy(controller.phone, 'Phone'),
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                icon: Icons.email_rounded,
                                label: 'Email Address',
                                value: controller.email,
                                onCopy: () => _copy(controller.email, 'Email'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Society
                          Obx(
                            () => _SectionCard(
                              title: 'Society Assignment',
                              children: [
                                _InfoRow(
                                  icon: Icons.location_on_rounded,
                                  label: controller.societyName.value.isEmpty
                                      ? 'No society yet'
                                      : controller.societyName.value,
                                  value: controller.societyAddress.value,
                                  labelIsTitle: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Settings group
                          Text(
                            'SETTINGS',
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              children: [
                                _MenuTile(
                                  icon: Icons.notifications_rounded,
                                  iconColor: const Color(0xFF3B82F6),
                                  label: 'Notification Preferences',
                                  onTap: controller.openNotificationPreferences,
                                  showDivider: true,
                                ),
                                _MenuTile(
                                  icon: Icons.shield_rounded,
                                  iconColor: AppColors.danger,
                                  label: 'Privacy & Security',
                                  onTap: controller.openPrivacyAndSecurity,
                                  showDivider: true,
                                ),
                                _MenuTile(
                                  icon: Icons.help_rounded,
                                  iconColor: AppColors.accentGreenDark,
                                  label: 'Help & Support',
                                  onTap: controller.openHelpAndSupport,
                                  showDivider: true,
                                ),
                                _MenuTile(
                                  icon: Icons.description_rounded,
                                  iconColor: AppColors.textSecondary,
                                  label: 'Terms of Service',
                                  onTap: controller.openTermsOfService,
                                  showDivider: false,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Logout
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: controller.confirmLogout,
                              borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.danger.withValues(alpha: 0.12),
                                      AppColors.danger.withValues(alpha: 0.06),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.danger.withValues(alpha: 0.35),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.danger.withValues(alpha: 0.12),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.danger,
                                          borderRadius: BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.danger.withValues(alpha: 0.35),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.logout_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Log Out',
                                              style: AppTextStyles.labelLarge.copyWith(
                                                color: AppColors.danger,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Sign out of your ApartMate account',
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.danger.withValues(alpha: 0.75),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: AppColors.danger.withValues(alpha: 0.7),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Version footer
                          Center(
                            child: Text(
                              '${AppStrings.appName} ${AppStrings.appVersion}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _copy(String value, String label) {
    if (value.trim().isEmpty || value == AppStrings.emailHint || value == AppStrings.phoneHint) {
      AppSnackbar.error('Nothing to copy', '$label is not available yet');
      return;
    }
    Clipboard.setData(ClipboardData(text: value));
    AppSnackbar.success('Copied', '$label copied to clipboard');
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: AppTextStyles.overline),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool labelIsTitle;
  final VoidCallback? onCopy;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.labelIsTitle = false,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryDark.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: AppColors.primaryDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!labelIsTitle)
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              if (!labelIsTitle) const SizedBox(height: 2),
              Text(
                labelIsTitle ? label : (value.isEmpty ? '—' : value),
                style: AppTextStyles.labelLarge,
              ),
              if (labelIsTitle && value.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(
            onPressed: onCopy,
            tooltip: 'Copy',
            icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.textMuted),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceMuted,
              shape: const CircleBorder(),
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 17, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: AppTextStyles.labelLarge)),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),
      ],
    );
  }
}
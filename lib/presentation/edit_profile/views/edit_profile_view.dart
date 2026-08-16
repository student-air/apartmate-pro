//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apartmate/core/constants/app_colors.dart';
import 'package:apartmate/core/constants/app_dimens.dart';
import 'package:apartmate/core/constants/app_text_styles.dart';
import 'package:apartmate/core/widgets/app_button.dart';
import 'package:apartmate/core/widgets/app_responsive_container.dart';
import 'package:apartmate/core/widgets/app_text_field.dart';
import 'package:apartmate/presentation/edit_profile/controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
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
                    'Edit Profile',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: AppResponsiveContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Obx(() {
                      final file = controller.photo.value;
                      return GestureDetector(
                        onTap: controller.pickPhoto,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryDark.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: file != null
                                  ? ClipOval(
                                      child: Image.file(
                                        file,
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.camera_alt_outlined,
                                          size: 28,
                                          color: AppColors.primaryDark.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.camera_alt_outlined,
                                      size: 28,
                                      color: AppColors.primaryDark.withValues(alpha: 0.5),
                                    ),
                            ),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryDark,
                                  shape: BoxShape.circle,
                                  border: Border.fromBorderSide(
                                    BorderSide(color: Colors.white, width: 2),
                                  ),
                                ),
                                child: const Icon(Icons.edit, size: 13, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Change Photo',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  AppTextField(
                    label: 'Full Name',
                    controller: controller.fullNameCtrl,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Owner Name',
                    controller: controller.ownerNameCtrl,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Email Address',
                    controller: controller.emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Phone Number',
                    controller: controller.phoneCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                            ),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: Text('Cancel', style: AppTextStyles.labelLarge),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => AppPrimaryButton(
                            label: 'Save',
                            isLoading: controller.isSaving.value,
                            onPressed: controller.save,
                          ),
                        ),
                      ),
                    ],
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
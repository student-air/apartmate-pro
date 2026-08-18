import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apartmate/core/constants/app_colors.dart';
import 'package:apartmate/core/constants/app_dimens.dart';
import 'package:apartmate/core/constants/app_strings.dart';
import 'package:apartmate/core/constants/app_text_styles.dart';
import 'package:apartmate/core/widgets/app_animations.dart';
import 'package:apartmate/core/widgets/app_button.dart';
import 'package:apartmate/core/widgets/app_card.dart';
import 'package:apartmate/core/widgets/app_responsive_container.dart';
import 'package:apartmate/core/widgets/app_text_field.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:apartmate/presentation/society_register/controllers/society_register_controller.dart';

class SocietyRegisterView extends GetView<SocietyRegisterController> {
  const SocietyRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 28),
            const SizedBox(width: 8),
            Text(
              AppStrings.registerSociety,
              style: AppTextStyles.h4.copyWith(color: Colors.white),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: AppResponsiveContainer(
                child: Obx(
                  () => AppShakeOnTrigger(
                    trigger: controller.registerShakeTrigger.value,
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _OwnerPhotoPicker(controller: controller),
                          const SizedBox(height: AppDimens.space20),
                          AppTextField(
                            label: AppStrings.societyName,
                            hint: AppStrings.societyNameHint,
                            controller: controller.societyNameCtrl,
                          ),
                          const SizedBox(height: AppDimens.space16),
                          AppTextField(
                            label: AppStrings.ownerName,
                            hint: AppStrings.ownerNameHint,
                            controller: controller.ownerNameCtrl,
                          ),
                          const SizedBox(height: AppDimens.space16),
                          AppTextField(
                            label: AppStrings.address,
                            hint: AppStrings.addressHint,
                            controller: controller.addressCtrl,
                            maxLines: 2,
                          ),
                          const SizedBox(height: AppDimens.space16),
                          Text(
                            'Country, State & City',
                            style: AppTextStyles.labelLarge,
                          ),
                          const SizedBox(height: AppDimens.space6),
                          SizedBox(
                            width: double.infinity,
                            child: SelectState(
                              showFlag: true,
                              showSearch: true,
                              countryHint: 'Select Country',
                              stateHint: 'Select State',
                              cityHint: 'Select City',
                              onCountryChanged: (value) =>
                                  controller.setCountry(value),
                              onStateChanged: (value) =>
                                  controller.setState(value),
                              onCityChanged: (value) =>
                                  controller.setCity(value),
                            ),
                          ),
                          const SizedBox(height: AppDimens.space16),
                          AppTextField(
                            label: AppStrings.contactNumber,
                            hint: AppStrings.contactNumberHint,
                            controller: controller.contactCtrl,
                            keyboardType: TextInputType.phone,
                          ),
                          Obx(() {
                            final error = controller.phoneError.value;
                            if (error == null) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: AppDimens.space8,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 14,
                                    color: AppColors.danger,
                                  ),
                                  const SizedBox(width: AppDimens.space4),
                                  Expanded(
                                    child: Text(
                                      error,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          // ── Maintenance (before description) ──
                          const SizedBox(height: AppDimens.space16),
                          Text(
                            'Do you take maintenance payment?',
                            style: AppTextStyles.labelLarge,
                          ),
                          const SizedBox(height: AppDimens.space8),
                          Obx(() {
                            final yes = controller.takesMaintenance.value;
                            return Row(
                              children: [
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Text('Yes'),
                                    selected: yes,
                                    onSelected: (_) =>
                                        controller.setTakesMaintenance(true),
                                    selectedColor: AppColors.primaryDark
                                        .withValues(alpha: 0.15),
                                    labelStyle: AppTextStyles.labelLarge.copyWith(
                                      color: yes
                                          ? AppColors.primaryDark
                                          : AppColors.textSecondary,
                                      fontWeight: yes
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                    side: BorderSide(
                                      color: yes
                                          ? AppColors.primaryDark
                                          : AppColors.borderLight,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Text('No'),
                                    selected: !yes,
                                    onSelected: (_) =>
                                        controller.setTakesMaintenance(false),
                                    selectedColor: AppColors.primaryDark
                                        .withValues(alpha: 0.15),
                                    labelStyle: AppTextStyles.labelLarge.copyWith(
                                      color: !yes
                                          ? AppColors.primaryDark
                                          : AppColors.textSecondary,
                                      fontWeight: !yes
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                    side: BorderSide(
                                      color: !yes
                                          ? AppColors.primaryDark
                                          : AppColors.borderLight,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          Obx(() {
                            if (!controller.takesMaintenance.value) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: AppDimens.space16,
                              ),
                              child: AppTextField(
                                label: 'Maintenance amount (Rs)',
                                hint: 'e.g. 5000',
                                controller: controller.maintenanceAmountCtrl,
                                keyboardType: TextInputType.number,
                              ),
                            );
                          }),

                          // ── Description ──
                          const SizedBox(height: AppDimens.space16),
                          AppTextField(
                            label: AppStrings.descriptionOptional,
                            hint: AppStrings.descriptionHint,
                            controller: controller.descriptionCtrl,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
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
              child: Obx(
                () => AppPrimaryButton(
                  label: AppStrings.submitRegistration,
                  isLoading: controller.isSubmitting.value,
                  onPressed: controller.submit,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerPhotoPicker extends StatelessWidget {
  final SocietyRegisterController controller;
  const _OwnerPhotoPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          final file = controller.ownerPhoto.value;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () => _showPhotoSourceSheet(context, controller),
                child: Container(
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
                  child: file != null
                      ? ClipOval(
                          child: Image.file(file, fit: BoxFit.cover),
                        )
                      : Icon(
                          Icons.camera_alt_outlined,
                          size: 28,
                          color: AppColors.primaryDark.withValues(alpha: 0.5),
                        ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: GestureDetector(
                  onTap: () => _showPhotoSourceSheet(context, controller),
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
                    child: const Icon(
                      Icons.edit,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: AppDimens.space8),
        Text('Add Owner Photo', style: AppTextStyles.labelLarge),
        const SizedBox(height: 2),
        Text(
          'PNG or JPG, up to 3MB',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

void _showPhotoSourceSheet(
  BuildContext context,
  SocietyRegisterController controller,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Open Camera'),
              onTap: () {
                Navigator.pop(sheetContext);
                controller.pickOwnerPhotoFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Upload from Device'),
              onTap: () {
                Navigator.pop(sheetContext);
                controller.pickOwnerPhotoFromGallery();
              },
            ),
          ],
        ),
      );
    },
  );
}
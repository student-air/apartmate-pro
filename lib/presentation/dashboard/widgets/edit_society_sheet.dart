import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apartmate/core/constants/app_colors.dart';
import 'package:apartmate/core/constants/app_dimens.dart';
import 'package:apartmate/core/constants/app_strings.dart';
import 'package:apartmate/core/constants/app_text_styles.dart';
import 'package:apartmate/core/widgets/app_animations.dart';
import 'package:apartmate/core/widgets/app_button.dart';
import 'package:apartmate/core/widgets/app_loading.dart';
import 'package:apartmate/core/widgets/app_text_field.dart';
import 'package:apartmate/domain/repositories/i_society_repository.dart';
import 'package:apartmate/presentation/dashboard/controllers/edit_society_controller.dart';

/// Opens the "Edit Society" form as a bottom sheet over whatever screen is
/// currently showing, instead of pushing a full new route. Call this from
/// DashboardController.goToEditSociety().
Future<void> showEditSocietySheet() {
  Get.put(
    EditSocietyController(Get.find<ISocietyRepository>()),
    tag: 'editSociety',
  );
  return Get.bottomSheet(
    const EditSocietySheet(),
    isScrollControlled: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
  ).whenComplete(() {
  FocusManager.instance.primaryFocus?.unfocus();
  Future.delayed(const Duration(milliseconds: 300), () {
    if (Get.isRegistered<EditSocietyController>(tag: 'editSociety')) {
      Get.delete<EditSocietyController>(tag: 'editSociety');
    }
  });
});
}

class EditSocietySheet extends StatelessWidget {
  const EditSocietySheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditSocietyController>(tag: 'editSociety');
    final maxHeight = MediaQuery.of(context).size.height * 0.88;
    // Keyboard height. This is applied further down as extra bottom padding
    // *inside* the scrollview, not as a Padding wrapping the whole sheet.
    // Wrapping the whole (opaque) card in an outer Padding pushes the card
    // up but leaves the padding's own space transparent/unpainted — that
    // transparent gap between the card and the keyboard is exactly what was
    // showing the dashboard bleeding through in the recording.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    void closeSheet() {
      FocusManager.instance.primaryFocus?.unfocus();
      Get.back();
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
          // This Container now sits at the outermost layer, so its white
          // background fills the entire height of the sheet — including
          // the strip that used to be transparent padding.
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimens.radius2xl),
              topRight: Radius.circular(AppDimens.radius2xl),
            ),
          ),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const SizedBox(height: 240, child: AppLoading());
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                  child: Row(
                    children: [
                      Expanded(child: Text('Edit Society', style: AppTextStyles.h4)),
                      IconButton(
                        onPressed: closeSheet,
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    // The keyboard inset is added here instead of on an
                    // outer Padding, so scrolling — not an invisible gap —
                    // is what makes room for the keyboard. The card's
                    // background keeps covering the full sheet height.
                    padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + bottomInset),
                    child: AppShakeOnTrigger(
                      trigger: controller.shakeTrigger.value,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                          AppTextField(
                            label: AppStrings.contactNumber,
                            hint: AppStrings.contactNumberHint,
                            controller: controller.contactCtrl,
                            keyboardType: TextInputType.phone,
                          ),
                          Obx(() {
                            final error = controller.phoneError.value;
                            if (error == null) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: AppDimens.space8),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, size: 14, color: AppColors.danger),
                                  const SizedBox(width: AppDimens.space4),
                                  Expanded(
                                    child: Text(
                                      error,
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
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
          onSelected: (_) => controller.setTakesMaintenance(true),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ChoiceChip(
          label: const Text('No'),
          selected: !yes,
          onSelected: (_) => controller.setTakesMaintenance(false),
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
    padding: const EdgeInsets.only(top: AppDimens.space16),
    child: AppTextField(
      label: 'Maintenance amount (Rs)',
      hint: 'e.g. 5000',
      controller: controller.maintenanceAmountCtrl,
      keyboardType: TextInputType.number,
    ),
  );
}),

                          const SizedBox(height: AppDimens.space16),
                          AppTextField(
                            label: AppStrings.descriptionOptional,
                            hint: AppStrings.descriptionHint,
                            controller: controller.descriptionCtrl,
                            maxLines: 3,
                          ),
                          const SizedBox(height: AppDimens.space24),
                          Obx(() => AppPrimaryButton(
                                label: 'Save Changes',
                                isLoading: controller.isSaving.value,
                                onPressed: controller.save,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      );
  }
}
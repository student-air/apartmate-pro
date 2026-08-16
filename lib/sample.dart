// void _showStaffFormSheet(BuildContext context) {
//     Get.bottomSheet(
//       Container(
//         decoration: const BoxDecoration(
//           color: AppColors.surface,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//         ),
//         child: SafeArea(
//           top: false,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // ── Dark header (same style as File a complaint) ──
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
//                 decoration: const BoxDecoration(
//                   color: AppColors.primaryDark,
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//                 ),
//                 child: Column(
//                   children: [
//                     // Handle bar
//                     Container(
//                       width: 40,
//                       height: 4,
//                       decoration: BoxDecoration(
//                         color: AppColors.textOnDark.withValues(alpha: 0.35),
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Container(
//                           width: 44,
//                           height: 44,
//                           decoration: BoxDecoration(
//                             color: AppColors.accentGreen.withValues(alpha: 0.15),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: const Icon(
//                             Icons.badge_rounded,
//                             color: AppColors.accentGreen,
//                             size: 22,
//                           ),
//                         ),
//                         const SizedBox(width: 14),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 controller.isEditing
//                                     ? 'Edit Staff Member'
//                                     : AppStrings.addStaffMember,
//                                 style: AppTextStyles.h4.copyWith(
//                                   color: AppColors.textOnDark,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               Text(
//                                 'Add staff details for your society',
//                                 style: AppTextStyles.bodySmall.copyWith(
//                                   color: AppColors.textOnDarkMuted,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // ── Form body ──
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
//                 child: Obx(
//                   () => AppShakeOnTrigger(
//                     trigger: controller.staffShakeTrigger.value,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         // Full Name
//                         AppTextField(
//                           label: AppStrings.fullName,
//                           hint: AppStrings.fullNameHint,
//                           controller: controller.nameCtrl,
//                         ),
//                         const SizedBox(height: 16),

//                         // Phone Number
//                         AppTextField(
//                           label: AppStrings.phoneNumber,
//                           hint: AppStrings.phoneHint,
//                           controller: controller.phoneCtrl,
//                           keyboardType: TextInputType.phone,
//                         ),
//                         Obx(() {
//                           final error = controller.phoneError.value;
//                           if (error == null) return const SizedBox.shrink();
//                           return Padding(
//                             padding: const EdgeInsets.only(top: 8),
//                             child: Row(
//                               children: [
//                                 const Icon(
//                                   Icons.error_outline,
//                                   size: 14,
//                                   color: AppColors.danger,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Expanded(
//                                   child: Text(
//                                     error,
//                                     style: AppTextStyles.bodySmall
//                                         .copyWith(color: AppColors.danger),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }),
//                         const SizedBox(height: 16),

//                         // Role
//                         Obx(
//                           () => AppDropdownField<StaffRole>(
//                             label: AppStrings.role,
//                             value: controller.selectedRole.value,
//                             items: StaffRole.values,
//                             labelBuilder: (r) => r.label,
//                             onChanged: controller.setRole,
//                           ),
//                         ),
//                         Obx(() {
//                           if (controller.selectedRole.value != StaffRole.other) {
//                             return const SizedBox.shrink();
//                           }
//                           return Padding(
//                             padding: const EdgeInsets.only(top: 16),
//                             child: AppTextField(
//                               label: 'Role Name',
//                               hint: 'e.g. Gardener',
//                               controller: controller.customRoleCtrl,
//                             ),
//                           );
//                         }),
//                         const SizedBox(height: 16),

//                         // Info banner
//                         // Container(
//                         //   padding: const EdgeInsets.all(12),
//                         //   decoration: BoxDecoration(
//                         //     color: const Color(0xFFEFF6FF),
//                         //     borderRadius:
//                         //         BorderRadius.circular(AppDimens.radiusMd),
//                         //   ),
//                         //   child: Row(
//                         //     crossAxisAlignment: CrossAxisAlignment.start,
//                         //     children: [
//                         //       Icon(
//                         //         Icons.info_outline_rounded,
//                         //         size: 18,
//                         //         color: AppColors.roleAdminText,
//                         //       ),
//                         //       const SizedBox(width: 10),
//                         //       Expanded(
//                         //         child: Text(
//                         //           'Staff will appear as Pending until they join using the society code in the user app.',
//                         //           style: AppTextStyles.bodySmall.copyWith(
//                         //             color: AppColors.roleAdminText,
//                         //           ),
//                         //         ),
//                         //       ),
//                         //     ],
//                         //   ),
//                         // ),
//                         const SizedBox(height: 20),

//                         // Submit button
//                         SizedBox(
//                           height: 52,
//                           child: ElevatedButton(
//                             onPressed: controller.saveStaff,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.primaryDark,
//                               elevation: 0,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius:
//                                     BorderRadius.circular(AppDimens.radiusFull),
//                               ),
//                             ),
//                             child: Text(
//                               controller.isEditing
//                                   ? 'Save Staff Member'
//                                   : AppStrings.saveStaffMember,
//                               style: AppTextStyles.labelLarge.copyWith(
//                                 color: AppColors.accentGreen,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 8),

//                         // Cancel
//                         TextButton(
//                           onPressed: Get.back,
//                           child: Text(
//                             'Cancel',
//                             style: AppTextStyles.labelLarge.copyWith(
//                               color: AppColors.textSecondary,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       isScrollControlled: true,
//       enterBottomSheetDuration: const Duration(milliseconds: 400),
//     );
//   }

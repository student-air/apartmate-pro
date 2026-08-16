import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apartmate/data/models/staff_model.dart';
import 'package:apartmate/domain/repositories/i_staff_repository.dart';
import 'package:apartmate/routes/app_routes.dart';
import 'package:apartmate/core/utils/validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:apartmate/core/utils/app_snackbar.dart';

class StaffController extends GetxController {
  final IStaffRepository _staffRepository;
  StaffController(this._staffRepository);

  final staff = <StaffModel>[].obs;
  final isLoading = false.obs;

  // Add/Edit staff form state
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final cnicCtrl = TextEditingController();
  final customRoleCtrl = TextEditingController();
  final selectedRole = StaffRole.securityGuard.obs;

  final photo = Rxn<File>();
  static const int maxPhotoSizeBytes = 3 * 1024 * 1024; // 3MB

  final justSavedStaffId = RxnString();

  final staffShakeTrigger = 0.obs;
  final phoneError = RxnString();
  final cnicError = RxnString();

  /// Non-null while editing an existing staff member; null while adding new.
  String? _editingStaffId;
  bool get isEditing => _editingStaffId != null;

  @override
  void onInit() {
    super.onInit();
    _loadStaff();
    phoneCtrl.addListener(() => phoneError.value = null);
    cnicCtrl.addListener(() => cnicError.value = null);
  }

  Future<void> _loadStaff() async {
    isLoading.value = true;
    try {
      final result = await _staffRepository.getStaff();
      staff.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  void setRole(StaffRole? role) {
    if (role != null) selectedRole.value = role;
    if (role != StaffRole.other) customRoleCtrl.clear();
  }

  void resetForm() {
    _editingStaffId = null;
    nameCtrl.clear();
    phoneCtrl.clear();
    cnicCtrl.clear();
    customRoleCtrl.clear();
    selectedRole.value = StaffRole.securityGuard;
    photo.value = null;
    phoneError.value = null;
    cnicError.value = null;
  }

  /// Pre-fills the form with an existing staff member's data, ready for editing.
  void startEditing(StaffModel member) {
    _editingStaffId = member.id;
    nameCtrl.text = member.name;
    phoneCtrl.text = member.phone;
    cnicCtrl.text = member.cnic;
    selectedRole.value = member.role;
    customRoleCtrl.text = member.customRoleLabel ?? '';
    photo.value = member.photoPath != null ? File(member.photoPath!) : null;
    phoneError.value = null;
    cnicError.value = null;
  }

  Future<void> saveStaff() async {
  if (nameCtrl.text.trim().isEmpty ||
      phoneCtrl.text.trim().isEmpty) {
    staffShakeTrigger.value++;
    AppSnackbar.error('Missing info', 'Please fill in name and phone number');
    return;
  }

  if (selectedRole.value == StaffRole.other &&
      customRoleCtrl.text.trim().isEmpty) {
    staffShakeTrigger.value++;
    AppSnackbar.error('Missing info', 'Please enter the role name');
    return;
  }

  if (!Validators.isValidPhone(phoneCtrl.text)) {
    phoneError.value = 'Use format 03XXXXXXXXX or +92 3XX XXXXXXX';
    return;
  }

  // CNIC is optional — no required or format check

  String savedId;

  if (isEditing) {
    final index = staff.indexWhere((s) => s.id == _editingStaffId);
    final updated = staff[index].copyWith(
      name: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      cnic: cnicCtrl.text.trim(),
      role: selectedRole.value,
      customRoleLabel:
          selectedRole.value == StaffRole.other ? customRoleCtrl.text.trim() : null,
      photoPath: photo.value?.path,
      // Keep the existing status when editing
    );
    final saved = await _staffRepository.updateStaff(updated);
    staff[index] = saved;
    savedId = saved.id;
  } else {
    // New staff added by Admin → always starts as Pending
    final newStaff = StaffModel(
      id: 's-${DateTime.now().millisecondsSinceEpoch}',
      name: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      cnic: cnicCtrl.text.trim(),
      role: selectedRole.value,
      customRoleLabel:
          selectedRole.value == StaffRole.other ? customRoleCtrl.text.trim() : null,
      photoPath: photo.value?.path,
      status: StaffStatus.pending, // ← important
    );
    final saved = await _staffRepository.addStaff(newStaff);
    staff.add(saved);
    savedId = saved.id;
  }

  resetForm();
  Get.back();

  justSavedStaffId.value = savedId;
  Future.delayed(const Duration(milliseconds: 1200), () {
    if (justSavedStaffId.value == savedId) justSavedStaffId.value = null;
  });
}
  Future<void> deleteStaff(String staffId) async {
    await _staffRepository.deleteStaff(staffId);
    staff.removeWhere((s) => s.id == staffId);
  }

  void goToDashboard() => Get.offAllNamed(AppRoutes.dashboard);

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    cnicCtrl.dispose();
    customRoleCtrl.dispose();
    super.onClose();
  }

  Future<void> pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final file = File(picked.path);
    final sizeInBytes = await file.length();
    if (sizeInBytes > maxPhotoSizeBytes) {
      Get.snackbar('File too large', 'Photo must be under 3MB');
      return;
    }
    photo.value = file;
  }
}
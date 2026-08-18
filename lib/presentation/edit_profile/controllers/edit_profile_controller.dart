import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:apartmate/core/constants/app_colors.dart';
import 'package:apartmate/core/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apartmate/core/utils/validators.dart';
import 'package:apartmate/data/models/user_model.dart';
import 'package:apartmate/domain/repositories/i_auth_repository.dart';
import 'package:apartmate/domain/repositories/i_society_repository.dart';
import 'package:apartmate/presentation/profile/controllers/profile_controller.dart';

class EditProfileController extends GetxController {
  final IAuthRepository _authRepository;
  final ISocietyRepository _societyRepository;
  EditProfileController(this._authRepository, this._societyRepository);

  static const int maxPhotoSizeBytes = 3 * 1024 * 1024; // 3MB

  final ownerNameCtrl = TextEditingController();
  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final photo = Rxn<File>();
  final isSaving = false.obs;
  final isLoading = false.obs;
  final shakeTrigger = 0.obs;

  UserModel? get _current => _authRepository.currentUser;

  @override
  void onInit() {
    super.onInit();
    _prefill();
  }

  Future<void> _prefill() async {
  final user = _current;
  if (user != null) {
    fullNameCtrl.text = user.fullName;
    emailCtrl.text = user.email;
    phoneCtrl.text = user.phone;
  }

  isLoading.value = true;
  try {
    final society = await _societyRepository.getCurrentSociety();
    ownerNameCtrl.text = society?.ownerName ?? '';

    // Prefer photo from society registration
    final societyPath = society?.ownerPhotoPath;
    if (societyPath != null && societyPath.isNotEmpty) {
      final file = File(societyPath);
      if (await file.exists()) {
        photo.value = file;
      }
    }

    // Fallback: user profile photo
    if (photo.value == null) {
      final userPath = user?.photoPath;
      if (userPath != null && userPath.isNotEmpty) {
        final file = File(userPath);
        if (await file.exists()) {
          photo.value = file;
        }
      }
    }
  } finally {
    isLoading.value = false;
  }
}

  Future<void> pickPhoto() async {
  final picked = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: 95, // crop first; compress after if needed
  );
  if (picked == null) return;

  final cropped = await ImageCropper().cropImage(
    sourcePath: picked.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // square avatar
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop photo',
        toolbarColor: AppColors.primaryDark,
        toolbarWidgetColor: AppColors.textOnDark,
        activeControlsWidgetColor: AppColors.accentGreen,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
      IOSUiSettings(
        title: 'Crop photo',
        aspectRatioLockEnabled: true,
      ),
    ],
  );

  if (cropped == null) return; // user cancelled crop

  final file = File(cropped.path);
  final sizeInBytes = await file.length();
  if (sizeInBytes > maxPhotoSizeBytes) {
    AppSnackbar.error('File too large', 'Photo must be under 3MB');
    return;
  }

  photo.value = file;
}
  Future<void> save() async {
    if (ownerNameCtrl.text.trim().isEmpty ||
        fullNameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        phoneCtrl.text.trim().isEmpty) {
      shakeTrigger.value++;
      AppSnackbar.error('Missing info', 'Please fill in all fields');
      return;
    }
    final emailError = Validators.emailErrorMessage(emailCtrl.text);
    if (emailError != null) {
      shakeTrigger.value++;
      AppSnackbar.error('Invalid email', emailError);
      return;
    }
    final phoneError = Validators.phoneErrorMessage(phoneCtrl.text);
    if (phoneError != null) {
      shakeTrigger.value++;
      AppSnackbar.error('Invalid phone', phoneError);
      return;
    }

    final current = _current;
    if (current == null) return;

    isSaving.value = true;
    try {
      await _authRepository.updateProfile(
        current.copyWith(
          fullName: fullNameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
          photoPath: photo.value?.path,
        ),
      );

      await _societyRepository.updateOwnerProfile(
        ownerName: ownerNameCtrl.text.trim(),
        ownerPhotoPath: photo.value?.path,
      );

      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().refreshSociety();
      }

      Get.back();
      AppSnackbar.success('Saved', 'Profile updated successfully');
    } catch (e, st) {
      debugPrint('EditProfileController.save() failed: $e\n$st');
      AppSnackbar.error('Save failed', e.toString());
    } finally {
      isSaving.value = false;
    }
  }
  @override
  void onClose() {
    ownerNameCtrl.dispose();
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }
}
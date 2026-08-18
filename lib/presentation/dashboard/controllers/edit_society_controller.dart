import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apartmate/data/models/society_model.dart';
import 'package:apartmate/domain/repositories/i_society_repository.dart';
import 'package:apartmate/core/utils/app_snackbar.dart';
import 'package:apartmate/core/utils/validators.dart';
import 'package:apartmate/presentation/dashboard/controllers/dashboard_controller.dart';
import 'package:apartmate/presentation/profile/controllers/profile_controller.dart';

/// Backs the "Edit Society" bottom sheet opened from the Dashboard.
/// Unlike [SocietyRegisterController] (full-screen, used for the initial
/// registration), this one never navigates — it just saves and closes,
/// then tells the Dashboard to refresh so the header updates immediately.
class EditSocietyController extends GetxController {
  final ISocietyRepository _societyRepository;
  EditSocietyController(this._societyRepository);

  final societyNameCtrl = TextEditingController();
  final ownerNameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final contactCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final maintenanceAmountCtrl = TextEditingController();

  final selectedCountry = ''.obs;
  final selectedState = ''.obs;
  final selectedCity = ''.obs;

  final takesMaintenance = false.obs;

  final isLoading = true.obs;
  final isSaving = false.obs;
  final shakeTrigger = 0.obs;
  final phoneError = RxnString();

  SocietyModel? _original;

  void setCountry(String value) => selectedCountry.value = value;
  void setState(String value) => selectedState.value = value;
  void setCity(String value) => selectedCity.value = value;

  void setTakesMaintenance(bool value) {
    takesMaintenance.value = value;
    if (!value) maintenanceAmountCtrl.clear();
  }

  String get currentLocationLabel {
    final city = selectedCity.value.isNotEmpty
        ? selectedCity.value
        : (_original?.city ?? '');
    final country = selectedCountry.value.isNotEmpty
        ? selectedCountry.value
        : (_original?.country ?? '');
    final parts = [city, country].where((s) => s.isNotEmpty);
    return parts.isEmpty ? 'Not set' : parts.join(', ');
  }

  @override
  void onInit() {
    super.onInit();
    _prefill();
    contactCtrl.addListener(() => phoneError.value = null);
  }

  Future<void> _prefill() async {
    isLoading.value = true;
    try {
      final existing = await _societyRepository.getCurrentSociety();
      _original = existing;
      if (existing != null) {
        societyNameCtrl.text = existing.name;
        ownerNameCtrl.text = existing.ownerName;
        addressCtrl.text = existing.address;
        contactCtrl.text = existing.contactNumber;
        descriptionCtrl.text = existing.description ?? '';
        takesMaintenance.value = existing.takesMaintenancePayment;
        if (existing.maintenanceAmountRs != null) {
          maintenanceAmountCtrl.text =
              existing.maintenanceAmountRs!.toStringAsFixed(0);
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> save() async {
    if (societyNameCtrl.text.trim().isEmpty ||
        ownerNameCtrl.text.trim().isEmpty ||
        addressCtrl.text.trim().isEmpty ||
        contactCtrl.text.trim().isEmpty) {
      shakeTrigger.value++;
      AppSnackbar.info('Missing info', 'Please fill in all required fields');
      return;
    }
    if (!Validators.isValidPhone(contactCtrl.text)) {
      phoneError.value = 'Use format 03XXXXXXXXX or +92 3XX XXXXXXX';
      return;
    }

    double? maintenanceAmount;
    if (takesMaintenance.value) {
      maintenanceAmount =
          double.tryParse(maintenanceAmountCtrl.text.trim());
      if (maintenanceAmount == null || maintenanceAmount <= 0) {
        AppSnackbar.info(
          'Maintenance amount',
          'Enter a valid amount in Rs',
        );
        return;
      }
    }

    isSaving.value = true;
    try {
      await _societyRepository.registerSociety(
        SocietyModel(
          id: _original?.id ??
              'society-${DateTime.now().millisecondsSinceEpoch}',
          name: societyNameCtrl.text.trim(),
          ownerName: ownerNameCtrl.text.trim(),
          address: addressCtrl.text.trim(),
          city: selectedCity.value.isNotEmpty
              ? selectedCity.value
              : (_original?.city ?? ''),
          country: selectedCountry.value.isNotEmpty
              ? selectedCountry.value
              : (_original?.country ?? ''),
          contactNumber: contactCtrl.text.trim(),
          description: descriptionCtrl.text.trim().isEmpty
              ? null
              : descriptionCtrl.text.trim(),
          ownerPhotoPath: _original?.ownerPhotoPath,
          joinCode: _original?.joinCode ?? '',
          registrationStatus: _original?.registrationStatus ??
              SocietyRegistrationStatus.approved,
          submittedAt: _original?.submittedAt ?? DateTime.now(),
          takesMaintenancePayment: takesMaintenance.value,
          maintenanceAmountRs:
              takesMaintenance.value ? maintenanceAmount : null,
        ),
      );

      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().refreshSociety();
      }
      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().refreshSociety();
      }

      FocusManager.instance.primaryFocus?.unfocus();
      Get.back();
      AppSnackbar.success('Saved', 'Society details updated');
    } catch (e) {
      AppSnackbar.error('Failed', e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    societyNameCtrl.dispose();
    ownerNameCtrl.dispose();
    addressCtrl.dispose();
    contactCtrl.dispose();
    descriptionCtrl.dispose();
    maintenanceAmountCtrl.dispose();
    super.onClose();
  }
}
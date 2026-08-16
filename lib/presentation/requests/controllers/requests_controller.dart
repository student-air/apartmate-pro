import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apartmate/data/models/request_model.dart';
import 'package:apartmate/data/models/resident_model.dart';
import 'package:apartmate/data/models/owner_model.dart';
import 'package:apartmate/domain/repositories/i_request_repository.dart';
import 'package:apartmate/domain/repositories/i_resident_repository.dart';
import 'package:apartmate/domain/repositories/i_owner_repository.dart';
import 'package:apartmate/core/utils/app_snackbar.dart';
import 'package:apartmate/core/constants/app_colors.dart';
import 'package:apartmate/core/constants/app_dimens.dart';
import 'package:apartmate/core/constants/app_text_styles.dart';
import 'package:apartmate/core/services/app_notification_service.dart';
import 'package:apartmate/presentation/dashboard/controllers/dashboard_controller.dart';

class RequestsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final IRequestRepository _requestRepository;
  final IResidentRepository _residentRepository;
  final IOwnerRepository _ownerRepository;

  RequestsController(
    this._requestRepository,
    this._residentRepository,
    this._ownerRepository,
  );

  late final TabController tabController;

  final ownerRequests = <RequestModel>[].obs;
  final staffRequests = <RequestModel>[].obs;
  final isLoading = false.obs;
  final selectedTab = 0.obs;
  final expandedRequestId = Rxn<String>();

  void toggleExpanded(String requestId) {
    expandedRequestId.value =
        expandedRequestId.value == requestId ? null : requestId;
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        selectedTab.value = tabController.index;
        expandedRequestId.value = null;
      }
    });
    loadRequests();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> loadRequests() async {
  isLoading.value = true;
  try {
    final result = await _requestRepository.getRequests();
    final pending =
        result.where((r) => r.status == RequestStatus.pending).toList();

    ownerRequests.assignAll(
      pending.where((r) => r.applicantType == RequestApplicantType.owner),
    );

    staffRequests.assignAll(
      pending.where((r) => r.applicantType == RequestApplicantType.staff),
    );
  } finally {
    isLoading.value = false;
  }
}

  Future<void> refresh() => loadRequests();

  Future<void> accept(RequestModel request) async {
    try {
      await _requestRepository.updateStatus(request.id, RequestStatus.accepted);

      if (request.applicantType == RequestApplicantType.owner) {
        await _ownerRepository.addOwner(
          OwnerModel(
            id: 'own-${DateTime.now().millisecondsSinceEpoch}',
            name: request.tenantName,
            phone: request.phone,
            email: request.email,
            cnic: request.cnic,
            buildingName: request.buildingName,
            flatNumber: request.flatNumber,
          ),
        );
        AppSnackbar.success(
          'Accepted',
          '${request.tenantName} registered as an owner',
        );
      } else {
        await _residentRepository.addResident(
          ResidentModel(
            id: 'res-${DateTime.now().millisecondsSinceEpoch}',
            buildingId: request.buildingId,
            buildingName: request.buildingName,
            floor: request.floor,
            flatNumber: request.flatNumber,
            flatType: request.flatType,
            name: request.tenantName,
            cnic: request.cnic,
            phone: request.phone,
            email: request.email,
            residentsCount: request.residentsCount,
            allotmentDate: request.allotmentDate,
            leaseDurationMonths: request.leaseDurationMonths,
            rent: request.rent,
            profession: request.profession,
            employerCompany: request.employerCompany,
            previousAddress: request.previousAddress,
            emergencyContact: request.emergencyContact,
          ),
        );
        AppSnackbar.success(
          'Accepted',
          '${request.tenantName} registered as a resident',
        );
      }

      _removeFromLists(request.id);
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().refreshRequestCounts();
      }
    } catch (e) {
      AppSnackbar.error('Failed', 'Could not accept request: $e');
    }
  }

  // Future<void> ignore(RequestModel request) async {
  //   try {
  //     await _requestRepository.deleteRequest(request.id);
  //     _removeFromLists(request.id);
  //     AppSnackbar.info('Removed', 'Request from ${request.tenantName} was removed');
  //   } catch (e) {
  //     AppSnackbar.error('Failed', 'Could not remove request: $e');
  //   }
  // }

  void confirmIgnore(RequestModel request) {
  final reasonCtrl = TextEditingController();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reject request?',
              style: AppTextStyles.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tell ${request.tenantName} why their request was declined. They can resubmit after fixing the issue.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Reason for rejection…',
                filled: true,
                fillColor: AppColors.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final reason = reasonCtrl.text.trim();
                  if (reason.isEmpty) {
                    AppSnackbar.error('Missing reason', 'Please enter a reason before continuing');
                    return;
                  }
                  Get.back();
                  ignore(request, reason: reason);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                ),
                child: Text(
                  'Done',
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    ),
  ).whenComplete(reasonCtrl.dispose);
}

Future<void> ignore(RequestModel request, {required String reason}) async {
  try {
    await _requestRepository.deleteRequest(request.id);
    // Optional: mark rejected instead of delete if you prefer history
    // await _requestRepository.updateStatus(request.id, RequestStatus.rejected);

    _removeFromLists(request.id);

    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().refreshRequestCounts();
    }

    final message =
        'Your join request was not approved.\n\n'
        'Reason: $reason\n\n'
        'You may correct the details and resubmit your application.';

    // Local stand-in until real push/email to the applicant exists
    await AppNotificationService.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Request declined — ${request.tenantName}',
      body: message,
      channelId: 'apartmate_requests',
      channelName: 'Requests',
    );

    AppSnackbar.success(
      'Sent',
      'Rejection reason sent to ${request.tenantName}. They can resubmit.',
    );
  } catch (e) {
    AppSnackbar.error('Failed', 'Could not remove request: $e');
  }
}
  void _removeFromLists(String id) {
    ownerRequests.removeWhere((r) => r.id == id);
    staffRequests.removeWhere((r) => r.id == id);
    if (expandedRequestId.value == id) expandedRequestId.value = null;
  }
}
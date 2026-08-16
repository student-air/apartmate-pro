import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:apartmate/core/utils/app_snackbar.dart';
import 'package:apartmate/data/models/dashboard_stats_model.dart';
import 'package:apartmate/data/models/society_model.dart';
import 'package:apartmate/domain/repositories/i_dashboard_repository.dart';
import 'package:apartmate/domain/repositories/i_society_repository.dart';
import 'package:apartmate/domain/repositories/i_complaint_repository.dart';
import 'package:apartmate/domain/repositories/i_request_repository.dart';
import 'package:apartmate/domain/repositories/i_auth_repository.dart';
import 'package:apartmate/domain/repositories/i_resident_repository.dart';
import 'package:apartmate/domain/repositories/i_update_repository.dart';
import 'package:apartmate/domain/repositories/i_owner_repository.dart';
import 'package:apartmate/domain/repositories/i_committee_repository.dart';
import 'package:apartmate/data/models/request_model.dart';
import 'package:apartmate/core/constants/app_colors.dart';
import 'package:apartmate/routes/app_routes.dart';
import 'package:apartmate/core/constants/app_dimens.dart';
import 'package:apartmate/core/constants/app_text_styles.dart';
import 'package:apartmate/presentation/dashboard/widgets/edit_society_sheet.dart';

class DashboardController extends GetxController {
  final IDashboardRepository _dashboardRepository;
  final ISocietyRepository _societyRepository;
  final IComplaintRepository _complaintRepository;
  final IRequestRepository _requestRepository;
  final IAuthRepository _authRepository;
  final IResidentRepository _residentRepository;
  final IUpdateRepository _updateRepository;
  final IOwnerRepository _ownerRepository;
  final ICommitteeRepository _committeeRepository;

  DashboardController(
    this._dashboardRepository,
    this._societyRepository,
    this._complaintRepository,
    this._requestRepository,
    this._authRepository,
    this._residentRepository,
    this._updateRepository,
    this._ownerRepository,
    this._committeeRepository,
  );

  final stats = Rxn<DashboardStatsModel>();
  final society = Rxn<SocietyModel>();
  final complaintsCount = 0.obs;
  final pendingRequestsCount = 0.obs;
  final pendingOwnerRequestsCount = 0.obs;
  /// Placeholder until property-update requests exist.
  final pendingPropertyUpdatesCount = 0.obs;
  /// Placeholder until staff-join requests exist.
  final pendingStaffJoinCount = 0.obs;
  final residentsCount = 0.obs;
  final isLoading = false.obs;
  final buildingOccupancy = <BuildingOccupancy>[].obs;
  final recentActivity = <ActivityItem>[].obs;
  final weeklyComplaintCounts = List<int>.filled(7, 0).obs;
  final ownersCount = 0.obs;
  final committeeCount = 0.obs;

  static String get greeting {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 6) return 'Early Morning';
    if (hour >= 6 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  static String get greetingAnimationAsset {
    if (greeting == 'Early Morning' ||
        greeting == 'Good Morning' ||
        greeting == 'Good Afternoon') {
      return 'assets/lottie/sun.json';
    }
    return 'assets/lottie/moon.json';
  }

  String get ownerFirstName {
    final name = society.value?.ownerName.trim() ?? '';
    if (name.isEmpty) return '';
    return name.split(' ').first;
  }

  String get ownerInitials {
    final name = society.value?.ownerName.trim() ?? '';
    if (name.isEmpty) return '';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  String get societyNameText => society.value?.name ?? '';

  String get roleDisplay {
    final role = _authRepository.currentUser?.role ?? '';
    if (role.trim().isEmpty) return 'Society Admin';
    return role[0].toUpperCase() + role.substring(1);
  }

  String get joinCode => society.value?.joinCode ?? '';

  @override
  void onInit() {
    super.onInit();
    _loadStats();
    _loadSociety();
    _loadComplaintsCount();
    _loadPendingRequestsCount();
    _loadResidentsCount();
    _loadOccupancy();
    _loadRecentActivity();
    _loadWeeklyComplaints();
    _loadOwnersCount();
    _loadCommitteeCount();
  }

  @override
  void onReady() {
    super.onReady();
    _loadComplaintsCount();
  }

  Future<void> _loadStats() async {
    isLoading.value = true;
    try {
      stats.value = await _dashboardRepository.getStats();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadOccupancy() async {
    final buildings = await _societyRepository.getBuildings();
    final residents = await _residentRepository.getResidents();

    residentsCount.value = residents.length;

    buildingOccupancy.value = buildings.map((b) {
      final total = b.details?.totalApartments ?? 0;
      final occupied = residents.where((r) {
        if (r.buildingId.isNotEmpty && r.buildingId == b.id) return true;
        return r.buildingName == b.name;
      }).length;

      return BuildingOccupancy(
        buildingId: b.id,
        buildingName: b.name,
        totalFlats: total,
        occupiedFlats: occupied,
      );
    }).toList();
  }

  Future<void> _loadRecentActivity() async {
    final complaints = await _complaintRepository.getComplaints();
    final updates = await _updateRepository.getUpdates();

    final items = <ActivityItem>[];

    for (final c in complaints) {
      items.add(
        ActivityItem(
          icon: Icons.report_problem_rounded,
          iconColor: AppColors.warning,
          title: 'New complaint: ${c.title}',
          timeLabel: _relativeTime(c.postedAt),
          at: c.postedAt,
        ),
      );
    }
    for (final u in updates) {
      items.add(
        ActivityItem(
          icon: Icons.campaign_rounded,
          iconColor: AppColors.accentGreenDark,
          title: 'Update posted: ${u.title}',
          timeLabel: _relativeTime(u.postedAt),
          at: u.postedAt,
        ),
      );
    }

    items.sort((a, b) => b.at.compareTo(a.at));
    recentActivity.value = items.take(5).toList();
  }

  Future<void> _loadWeeklyComplaints() async {
    final complaints = await _complaintRepository.getComplaints();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final counts = List<int>.filled(7, 0);

    for (final c in complaints) {
      final d = DateTime(c.postedAt.year, c.postedAt.month, c.postedAt.day);
      final diff = today.difference(d).inDays;
      if (diff >= 0 && diff < 7) {
        counts[6 - diff]++;
      }
    }
    weeklyComplaintCounts.value = counts;
  }

  String _relativeTime(DateTime at) {
    final diff = DateTime.now().difference(at);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  Future<void> _loadSociety() async {
    society.value = await _societyRepository.getCurrentSociety();
  }

  Future<void> _loadComplaintsCount() async {
    final list = await _complaintRepository.getComplaints();
    complaintsCount.value = list.length;
  }

  Future<void> _loadPendingRequestsCount() async {
  final requests = await _requestRepository.getRequests();
  final pending =
      requests.where((r) => r.status == RequestStatus.pending).toList();

  pendingRequestsCount.value = pending.length;
  pendingOwnerRequestsCount.value = pending
      .where((r) => r.applicantType == RequestApplicantType.owner)
      .length;
  pendingStaffJoinCount.value = pending
      .where((r) => r.applicantType == RequestApplicantType.staff)
      .length;

  // keep or drop the recent list — not needed for this UI
  //pendingRecentRequests.clear();
}

  Future<void> _loadResidentsCount() async {
    final residents = await _residentRepository.getResidents();
    residentsCount.value = residents.length;
  }

  Future<void> refreshSociety() => _loadSociety();

  Future<void> _loadOwnersCount() async {
    final list = await _ownerRepository.getOwners();
    ownersCount.value = list.length;
  }

  Future<void> _loadCommitteeCount() async {
    final list = await _committeeRepository.getMembers();
    committeeCount.value = list.length;
  }

  Future<void> refreshRequestCounts() async {
    await Future.wait([
      _loadPendingRequestsCount(),
      _loadResidentsCount(),
      _loadOccupancy(),
      _loadOwnersCount(),
      _loadCommitteeCount(),
    ]);
  }

  void goToEditSociety() => showEditSocietySheet();
  void goToAddStaff() => Get.toNamed(AppRoutes.managementStaff);
  void goToResidents() => Get.toNamed(AppRoutes.residents);
  void goToUpdates() => Get.toNamed(AppRoutes.updates);
  void goToProfile() => Get.toNamed(AppRoutes.profile);
  void goToBuildings() => Get.toNamed(AppRoutes.societyBuildings);
  void goToComplaints() => Get.toNamed(AppRoutes.complaints);
  void goToRequests() => Get.toNamed(AppRoutes.requests);
  void goToOwners() => Get.toNamed(AppRoutes.owners);
  void goToCommittee() => Get.toNamed(AppRoutes.committee);

  
  void copyJoinCode() {
    final code = joinCode;
    if (code.isEmpty) {
      AppSnackbar.error('No code', 'Society join code is not available yet');
      return;
    }
    Clipboard.setData(ClipboardData(text: code));
    AppSnackbar.info('Copied', 'Society join code $code copied');
  }

  Future<void> logout() async {
    await _authRepository.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  void confirmLogout() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 30,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Log out?',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You will need to sign in again to access your ApartMate account.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    logout();
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Log Out',
                    style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusFull),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> refreshComplaintsCount() => _loadComplaintsCount();

  Future<void> refreshAll() async {
    await Future.wait([
      _loadStats(),
      _loadSociety(),
      _loadComplaintsCount(),
      _loadPendingRequestsCount(),
      _loadResidentsCount(),
      _loadOccupancy(),
      _loadRecentActivity(),
      _loadWeeklyComplaints(),
      _loadOwnersCount(),
      _loadCommitteeCount(),
    ]);
  }
}

class BuildingOccupancy {
  final String buildingId;
  final String buildingName;
  final int totalFlats;
  final int occupiedFlats;

  const BuildingOccupancy({
    required this.buildingId,
    required this.buildingName,
    required this.totalFlats,
    required this.occupiedFlats,
  });

  double get percent {
    if (totalFlats <= 0) return 0;
    return (occupiedFlats / totalFlats).clamp(0.0, 1.0);
  }
}

class ActivityItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String timeLabel;
  final DateTime at;

  const ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.timeLabel,
    required this.at,
  });
}
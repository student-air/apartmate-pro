import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apartmate/core/constants/app_colors.dart';
import 'package:apartmate/core/constants/app_dimens.dart';
import 'package:apartmate/core/constants/app_text_styles.dart';
import 'package:apartmate/core/widgets/app_bottom_nav.dart';
import 'package:apartmate/core/widgets/app_responsive_container.dart';
import 'package:apartmate/core/widgets/app_skeletons.dart';
import 'package:apartmate/core/widgets/send_update_sheet.dart';
import 'package:apartmate/data/models/resident_model.dart';
import 'package:apartmate/presentation/residents/controllers/residents_controller.dart';
import 'package:apartmate/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'package:apartmate/core/utils/app_snackbar.dart';

class ResidentsView extends GetView<ResidentsController> {
  const ResidentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const _FilterDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AppAddFab(
        onPressed: showSendUpdateSheet,
      ),
      bottomNavigationBar: AppBottomNav(
        activeTab: AppNavTab.home,
        onHome: () => Get.offAllNamed(AppRoutes.dashboard),
        onUpdates: () => Get.toNamed(AppRoutes.updates),
        onRequests: () => Get.toNamed(AppRoutes.requests),
        onProfile: () => Get.toNamed(AppRoutes.profile),
      ),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          const _ResidentsHeader(),

          // ── Body ────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const AppSkeletonList(
                  itemBuilder: StaffTileSkeleton.new,
                );
              }

              final grouped = controller.groupedByBuilding;

              if (grouped.isEmpty) {
                return RefreshIndicator(
                  color: AppColors.primaryDark,
                  onRefresh: controller.refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      _EmptyResidentsState(),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryDark,
                onRefresh: controller.refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: AppResponsiveContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: grouped.entries.expand((entry) {
                        return [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10, top: 4),
                            child: Text(entry.key, style: AppTextStyles.h4),
                          ),
                          ...entry.value.map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ResidentTile(resident: r),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ];
                      }).toList(),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _ResidentsHeader extends StatefulWidget {
  const _ResidentsHeader();

  @override
  State<_ResidentsHeader> createState() => _ResidentsHeaderState();
}

class _ResidentsHeaderState extends State<_ResidentsHeader> {
  bool _isSearching = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResidentsController>();

    return Container(
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
            // Menu (opens drawer)
            Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.textOnDark.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: AppColors.textOnDark,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title or Search field
            Expanded(
              child: _isSearching
                  ? TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryDark,
                      ),
                      cursorColor: AppColors.primaryDark,
                      decoration: InputDecoration(
                        hintText: 'Search by name',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryDark.withValues(alpha: 0.6),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusFull),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusFull),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusFull),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: controller.setSearchQuery,
                    )
                  : Text(
                      'Residents',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textOnDark,
                      ),
                    ),
            ),

            // Search toggle
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_isSearching) {
                    _searchCtrl.clear();
                    controller.setSearchQuery('');
                  }
                  _isSearching = !_isSearching;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.textOnDark.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Icon(
                  _isSearching ? Icons.close_rounded : Icons.search_rounded,
                  color: AppColors.accentGreen,
                  size: 20,
                ),
              ),
            ),

            // Clear filters (only when active & not searching)
            Obx(() {
              if (!controller.hasActiveFilters || _isSearching) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: TextButton(
                  onPressed: controller.clearFilters,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accentGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Clear',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),

            // Logo
            const SizedBox(width: 8),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DRAWER + FILTERS
// ─────────────────────────────────────────────────────────────────────────────

class _FilterDrawer extends StatelessWidget {
  const _FilterDrawer();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResidentsController>();
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filters', style: AppTextStyles.h3),
              const SizedBox(height: 20),

              Text('Building', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Obx(() {
                final buildingNames =
                    controller.buildings.map((b) => b.name).toSet().toList();
                return DropdownButtonFormField<String?>(
                  initialValue: controller.selectedBuildingName.value,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Buildings'),
                    ),
                    ...buildingNames.map(
                      (name) => DropdownMenuItem<String?>(
                        value: name,
                        child: Text(name),
                      ),
                    ),
                  ],
                  onChanged: controller.setBuildingFilter,
                );
              }),
              const SizedBox(height: 20),

              Text('Floor', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Obx(() {
                final floors = controller.availableFloorsForFilter;
                final hasBuilding =
                    controller.selectedBuildingName.value != null;
                return DropdownButtonFormField<int?>(
                  initialValue: controller.selectedFloor.value,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(
                        hasBuilding ? 'All Floors' : 'Select a building first',
                      ),
                    ),
                    ...floors.map(
                      (f) => DropdownMenuItem<int?>(
                        value: f,
                        child: Text('Floor $f'),
                      ),
                    ),
                  ],
                  onChanged: !hasBuilding ? null : controller.setFloorFilter,
                );
              }),
              const SizedBox(height: 20),

              Text('Rent Status', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Obx(
                () => _FilterChips(
                  selected: controller.rentFilter.value,
                  onSelected: controller.setRentFilter,
                ),
              ),
              const SizedBox(height: 20),

              Text('Maintenance Status', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Obx(
                () => _FilterChips(
                  selected: controller.maintenanceFilter.value,
                  onSelected: controller.setMaintenanceFilter,
                ),
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.clearFilters,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: AppColors.accentGreen,
                  ),
                  label: const Text(
                    'Reset Filters',
                    style: TextStyle(color: AppColors.accentGreen),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusFull),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final PaymentFilter selected;
  final ValueChanged<PaymentFilter> onSelected;

  const _FilterChips({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: PaymentFilter.values.map((filter) {
        final isSelected = filter == selected;
        final label = switch (filter) {
          PaymentFilter.all => 'All',
          PaymentFilter.paid => 'Paid',
          PaymentFilter.unpaid => 'Unpaid',
        };
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onSelected(filter),
          selectedColor: AppColors.accentGreen,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyResidentsState extends StatelessWidget {
  const _EmptyResidentsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/persons.json',
              width: 220,
              height: 180,
              fit: BoxFit.contain,
              repeat: true,
            ),
            const SizedBox(height: 20),
            Text('No residents yet', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            Text(
              'Residents will appear here once they are added !',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESIDENT TILE
// ─────────────────────────────────────────────────────────────────────────────

class _ResidentTile extends StatelessWidget {
  final ResidentModel resident;
  const _ResidentTile({required this.resident});

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: resident.phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      AppSnackbar.error('Unable to open dialer', 'No phone app available');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResidentsController>();

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.residentDetail, arguments: resident),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    resident.initials,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primaryDark,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(resident.name, style: AppTextStyles.h4),
                      const SizedBox(height: 2),
                      Text(
                        '${resident.buildingName} · Floor ${resident.floor} · Flat ${resident.flatNumber}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _call,
                  icon: const Icon(
                    Icons.call_rounded,
                    size: 20,
                    color: AppColors.successGreenDark,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        AppColors.successGreen.withValues(alpha: 0.12),
                    shape: const CircleBorder(),
                  ),
                ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  offset: const Offset(0, 8),
                  color: AppColors.surface,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'rent':
                        controller.toggleRentPaid(resident.id);
                        break;
                      case 'maintenance':
                        controller.toggleMaintenancePaid(resident.id);
                        break;
                      case 'notify':
                        showSendUpdateSheet(
                          prefillBuildingName: resident.buildingName,
                          prefillFloor: resident.floor,
                          prefillFlatNumber: resident.flatNumber,
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'rent',
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: (resident.rentPaid
                                      ? AppColors.accentGreen
                                      : AppColors.warning)
                                  .withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              resident.rentPaid
                                  ? Icons.check_rounded
                                  : Icons.payments_outlined,
                              size: 16,
                              color: resident.rentPaid
                                  ? AppColors.accentGreenDark
                                  : AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              resident.rentPaid
                                  ? 'Rent paid'
                                  : 'Mark rent paid',
                              style: AppTextStyles.labelLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'maintenance',
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: (resident.maintenancePaid
                                      ? AppColors.accentGreen
                                      : AppColors.warning)
                                  .withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              resident.maintenancePaid
                                  ? Icons.check_rounded
                                  : Icons.build_outlined,
                              size: 16,
                              color: resident.maintenancePaid
                                  ? AppColors.accentGreenDark
                                  : AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              resident.maintenancePaid
                                  ? 'Maintenance paid'
                                  : 'Mark maintenance paid',
                              style: AppTextStyles.labelLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'notify',
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark
                                  .withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.campaign_rounded,
                              size: 16,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Send update',
                            style: AppTextStyles.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.more_horiz_rounded,
                      size: 20,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _PaymentChip(label: 'Rent', paid: resident.rentPaid),
                const SizedBox(width: 6),
                _PaymentChip(
                  label: 'Maint',
                  paid: resident.maintenancePaid,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final String label;
  final bool paid;
  const _PaymentChip({required this.label, required this.paid});

  @override
  Widget build(BuildContext context) {
    final color = paid ? AppColors.accentGreenDark : AppColors.warning;
    final bg = paid
        ? AppColors.accentGreen.withValues(alpha: 0.12)
        : AppColors.warning.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            '$label · ${paid ? 'Paid' : 'Due'}',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
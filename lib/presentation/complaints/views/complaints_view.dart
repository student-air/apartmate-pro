import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:apartmate/core/constants/app_colors.dart';
import 'package:apartmate/core/constants/app_dimens.dart';
import 'package:apartmate/core/constants/app_text_styles.dart';
import 'package:apartmate/core/widgets/app_responsive_container.dart';
import 'package:apartmate/core/widgets/app_skeletons.dart';
import 'package:apartmate/data/models/complaint_model.dart';
import 'package:apartmate/presentation/complaints/controllers/complaints_controller.dart';

class ComplaintsView extends GetView<ComplaintsController> {
  const ComplaintsView({super.key});

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
    // no appBar
    body: Column(
      children: [
        // ── Header + tabs ─────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          decoration: const BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppDimens.headerRadius),
              bottomRight: Radius.circular(AppDimens.headerRadius),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Title row
                Row(
                  children: [
                    // Back
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              AppColors.textOnDark.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusMd),
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
                        'Complaints',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textOnDark,
                        ),
                      ),
                    ),

                    // Clear All
                    Obx(() {
                      final hasItems = controller.selectedTab.value == 0
                          ? controller.complaints.isNotEmpty
                          : controller.resolved.isNotEmpty;
                      if (!hasItems) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: TextButton(
                          onPressed: controller.confirmClearAll,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.accentGreen,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Clear All',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.accentGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),

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
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusSm,
                            ),
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
                const SizedBox(height: 8),

                // Tabs
                TabBar(
                  controller: controller.tabController,
                  indicatorColor: AppColors.accentGreen,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: AppTextStyles.labelLarge,
                  tabs: const [
                    Tab(text: 'All Complaints'),
                    Tab(text: 'Resolved'),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Body ──────────────────────────────────────────────────────
        Expanded(
          child: AppResponsiveContainer(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.complaints.isEmpty &&
                  controller.resolved.isEmpty) {
                return const AppSkeletonList(
                  itemBuilder: UpdateCardSkeleton.new,
                );
              }
              return TabBarView(
                controller: controller.tabController,
                children: [
                  _ComplaintsList(
                    items: controller.complaints,
                    emptyTitle: 'No complaints yet',
                    emptySubtitle: 'All complaints will show up here',
                    onDelete: controller.deleteComplaint,
                    onMarkSeen: (id) =>
                        controller.setStatus(id, ComplaintStatus.pending),
                    onMarkReviewed: (id) => controller.setStatus(
                      id,
                      ComplaintStatus.underReview,
                    ),
                    onMarkResolved: controller.markResolved,
                    showActions: true,
                  ),
                  _ComplaintsList(
                    items: controller.resolved,
                    emptyTitle: 'No resolved complaints',
                    emptySubtitle: 'Resolved complaints will appear here',
                    onDelete: controller.deleteResolved,
                    onMarkSeen: null,
                    onMarkReviewed: null,
                    onMarkResolved: null,
                    showActions: false,
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    ),
  );
}
}

class _ComplaintsList extends StatelessWidget {
  final List<ComplaintModel> items;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function(String id) onDelete;
  final void Function(String id)? onMarkSeen;
  final void Function(String id)? onMarkReviewed;
  final void Function(String id)? onMarkResolved;
  final bool showActions;

  const _ComplaintsList({
    required this.items,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onDelete,
    required this.onMarkSeen,
    required this.onMarkReviewed,
    required this.onMarkResolved,
    required this.showActions,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyComplaintState(
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.danger,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) => onDelete(item.id),
          child: _ComplaintCard(
            complaint: item,
            showActions: showActions,
            onMarkSeen: onMarkSeen == null ? null : () => onMarkSeen!(item.id),
            onMarkReviewed:
                onMarkReviewed == null ? null : () => onMarkReviewed!(item.id),
            onMarkResolved:
                onMarkResolved == null ? null : () => onMarkResolved!(item.id),
            onDelete: () => onDelete(item.id),
          ),
        );
      },
    );
  }
}

class EmptyComplaintState extends StatelessWidget {
  final String title;
  final String subtitle;

  const EmptyComplaintState({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/complaint.json',
              width: 240,
              height: 200,
              fit: BoxFit.contain,
              repeat: true,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
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

class _ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final bool showActions;
  final VoidCallback? onMarkSeen;
  final VoidCallback? onMarkReviewed;
  final VoidCallback? onMarkResolved;
  final VoidCallback onDelete;

  const _ComplaintCard({
    required this.complaint,
    required this.showActions,
    required this.onMarkSeen,
    required this.onMarkReviewed,
    required this.onMarkResolved,
    required this.onDelete,
  });

  void _confirmDelete(BuildContext context) {
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
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 30,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete complaint?',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This will permanently remove "${complaint.title}" from the list.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      onDelete();
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Delete',
                      style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                      ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _statusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending:
        return AppColors.pending;
      case ComplaintStatus.underReview:
        return AppColors.warning;
      case ComplaintStatus.resolved:
        return AppColors.successGreen;
    }
  }

  String _statusLabel(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending:
        return 'Seen';
      case ComplaintStatus.underReview:
        return 'Reviewed';
      case ComplaintStatus.resolved:
        return 'Resolved';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(complaint.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.dangerBg,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  border: Border.all(color: AppColors.dangerBorder),
                ),
                child: Text(
                  complaint.category.isNotEmpty ? complaint.category : 'Complaint',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.danger),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  border: Border.all(color: statusColor.withOpacity(0.35)),
                ),
                child: Text(
                  _statusLabel(complaint.status),
                  style: AppTextStyles.labelSmall.copyWith(color: statusColor),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(complaint.postedAt),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              // Only on All Complaints tab — hidden on Resolved
              if (showActions)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textMuted),
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'seen':
                        onMarkSeen?.call();
                        break;
                      case 'resolved':
                        onMarkResolved?.call();
                        break;
                      case 'delete':
                        _confirmDelete(context);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'seen',
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.pending.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.visibility_rounded,
                              size: 16,
                              color: AppColors.pending,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('Mark as Seen', style: AppTextStyles.labelLarge),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'resolved',
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: AppColors.successGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('Mark as Resolved', style: AppTextStyles.labelLarge),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: AppColors.danger,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Delete',
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppColors.danger),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(complaint.title, style: AppTextStyles.h4),
          const SizedBox(height: 4),
          Text(
            complaint.description,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
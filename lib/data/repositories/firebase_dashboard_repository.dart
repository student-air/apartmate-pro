// lib/data/repositories/firebase_dashboard_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apartmate/data/models/dashboard_stats_model.dart';
import 'package:apartmate/domain/repositories/i_dashboard_repository.dart';
import 'package:apartmate/domain/repositories/i_society_repository.dart';
import 'package:apartmate/domain/repositories/i_staff_repository.dart';

class FirebaseDashboardRepository implements IDashboardRepository {
  final ISocietyRepository _societyRepository;
  final IStaffRepository _staffRepository;
  final FirebaseFirestore _db;

  FirebaseDashboardRepository(
    this._societyRepository,
    this._staffRepository, {
    FirebaseFirestore? db,
  }) : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<DashboardStatsModel> getStats() async {
    final buildings = await _societyRepository.getBuildings();
    final staff = await _staffRepository.getStaff();
    final totalFlats = buildings.fold<int>(
      0,
      (sum, b) => sum + (b.details?.totalApartments ?? 0),
    );

    int pendingRequests = 0;
    try {
      final snap = await _db
          .collection('joinRequests')
          .where('status', isEqualTo: 'pending')
          .get();
      pendingRequests = snap.docs.length;
    } catch (_) {
      pendingRequests = 0;
    }

    return DashboardStatsModel(
      buildings: buildings.length,
      totalFlats: totalFlats,
      mgmtStaff: staff.length,
      pendingRequests: pendingRequests,
    );
  }
}
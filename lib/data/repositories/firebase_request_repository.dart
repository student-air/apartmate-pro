import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:apartmate/data/models/request_model.dart';
import 'package:apartmate/domain/repositories/i_request_repository.dart';

class FirebaseRequestRepository implements IRequestRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('joinRequests');

  /// Pro society doc id = admin uid
  String get _societyId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('No signed-in admin user');
    return uid;
  }

  @override
  Future<List<RequestModel>> getRequests() async {
    final snap = await _col
        .where('societyId', isEqualTo: _societyId)
        .get();

    final list = snap.docs.map((d) => _fromMap(d.id, d.data())).toList();
    list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return list;
  }

  @override
  Future<RequestModel> addRequest(RequestModel request) async {
    final data = _toMap(request);
    data['societyId'] = _societyId;
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    final ref = await _col.add(data);
    final saved = await ref.get();
    return _fromMap(saved.id, saved.data()!);
  }

  @override
  Future<RequestModel> updateStatus(
    String requestId,
    RequestStatus status,
  ) async {
    // Firestore status used by regular app: pending | approved | rejected
    final firestoreStatus = switch (status) {
      RequestStatus.accepted => 'approved',
      RequestStatus.rejected => 'rejected',
      RequestStatus.pending => 'pending',
    };

    await _col.doc(requestId).set({
      'status': firestoreStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final doc = await _col.doc(requestId).get();
    if (!doc.exists || doc.data() == null) {
      throw StateError('Request not found: $requestId');
    }
    return _fromMap(doc.id, doc.data()!);
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    await _col.doc(requestId).delete();
  }

  // ── Mapping ──────────────────────────────────────────────

  Map<String, dynamic> _toMap(RequestModel r) {
    return {
      'userId': '', // filled by regular app on create
      'role': r.applicantType == RequestApplicantType.owner
          ? 'owner'
          : r.applicantType == RequestApplicantType.staff
              ? 'staff'
              : 'tenant',
      'status': switch (r.status) {
        RequestStatus.accepted => 'approved',
        RequestStatus.rejected => 'rejected',
        RequestStatus.pending => 'pending',
      },
      'fullName': r.tenantName,
      'email': r.email,
      'phone': r.phone,
      'cnic': r.cnic,
      'buildingId': r.buildingId,
      'buildingName': r.buildingName,
      'floor': r.floor,
      'flatNumber': r.flatNumber,
      'flatType': r.flatType,
      'residentsCount': r.residentsCount,
      'allotmentDate': Timestamp.fromDate(r.allotmentDate),
      'leaseDurationMonths': r.leaseDurationMonths,
      'rent': r.rent,
      'profession': r.profession,
      'employerCompany': r.employerCompany,
      'previousAddress': r.previousAddress,
      'emergencyContact': r.emergencyContact,
      'submittedAt': Timestamp.fromDate(r.submittedAt),
    };
  }

  RequestModel _fromMap(String id, Map<String, dynamic> d) {
    final statusStr = (d['status'] as String?)?.toLowerCase() ?? 'pending';
    final roleStr = (d['role'] as String?)?.toLowerCase() ?? 'tenant';

    return RequestModel(
      id: id,
      buildingId: (d['buildingId'] as String?) ?? '',
      buildingName: (d['buildingName'] as String?) ?? '—',
      floor: d['floor'] is int
          ? d['floor'] as int
          : int.tryParse('${d['floor'] ?? 0}') ?? 0,
      flatNumber: (d['flatNumber'] as String?) ?? '—',
      flatType: (d['flatType'] as String?) ?? '—',
      tenantName: (d['fullName'] as String?) ??
          (d['tenantName'] as String?) ??
          'Unknown',
      cnic: (d['cnic'] as String?) ?? '',
      phone: (d['phone'] as String?) ?? '',
      email: (d['email'] as String?) ?? '',
      residentsCount: d['residentsCount'] is int
          ? d['residentsCount'] as int
          : 1,
      allotmentDate: (d['allotmentDate'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      leaseDurationMonths: d['leaseDurationMonths'] is int
          ? d['leaseDurationMonths'] as int
          : 0,
      rent: (d['rent'] is num) ? (d['rent'] as num).toDouble() : 0,
      profession: (d['profession'] as String?) ?? '',
      employerCompany: (d['employerCompany'] as String?) ?? '',
      previousAddress: (d['previousAddress'] as String?) ?? '',
      emergencyContact: (d['emergencyContact'] as String?) ?? '',
      status: switch (statusStr) {
        'approved' || 'accepted' => RequestStatus.accepted,
        'rejected' => RequestStatus.rejected,
        _ => RequestStatus.pending,
      },
      submittedAt: (d['createdAt'] as Timestamp?)?.toDate() ??
          (d['submittedAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      applicantType: switch (roleStr) {
        'owner' => RequestApplicantType.owner,
        'staff' => RequestApplicantType.staff,
        _ => RequestApplicantType.tenant,
      },
    );
  }
}
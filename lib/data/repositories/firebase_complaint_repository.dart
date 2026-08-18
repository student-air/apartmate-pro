// lib/data/repositories/firebase_complaint_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apartmate/data/models/complaint_model.dart';
import 'package:apartmate/domain/repositories/i_complaint_repository.dart';

class FirebaseComplaintRepository implements IComplaintRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('complaints');

  @override
  Future<List<ComplaintModel>> getComplaints() async {
    final snap = await _col.get();
    return snap.docs
        .map((d) => _fromMap(d.id, d.data()))
        .where((c) => c.status != ComplaintStatus.resolved)
        .toList()
      ..sort((a, b) => b.postedAt.compareTo(a.postedAt));
  }

  @override
  Future<List<ComplaintModel>> getResolved() async {
    final snap = await _col.where('status', isEqualTo: 'resolved').get();
    return snap.docs.map((d) => _fromMap(d.id, d.data())).toList()
      ..sort((a, b) => b.postedAt.compareTo(a.postedAt));
  }

  @override
  Future<void> addComplaint(ComplaintModel complaint) async {
    final id = complaint.id.isEmpty ? _col.doc().id : complaint.id;
    await _col.doc(id).set({
      'category': complaint.category,
      'title': complaint.title,
      'description': complaint.description,
      'status': _statusToString(complaint.status),
      'createdAt': Timestamp.fromDate(complaint.postedAt),
      'postedAt': Timestamp.fromDate(complaint.postedAt),
      'updatedAt': FieldValue.serverTimestamp(),
      // mate-compatible defaults
      'raisedByUserId': '',
      'raisedByRole': 'society_admin',
      'raisedByName': '',
      'assignedTo': 'society_admin',
      'propertyId': '',
      'societyId': '',
      'propertyLabel': '',
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateComplaintStatus(String id, ComplaintStatus status) async {
    await _col.doc(id).set({
      'status': _statusToString(status),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> resolveComplaint(String id) async {
    await updateComplaintStatus(id, ComplaintStatus.resolved);
  }

  @override
  Future<void> deleteComplaint(String id) async {
    await _col.doc(id).delete();
  }

  @override
  Future<void> deleteResolved(String id) async {
    await _col.doc(id).delete();
  }

  @override
  Future<void> clearAll() async {
    final snap = await _col.where('status', isNotEqualTo: 'resolved').get();
    final batch = _db.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    if (snap.docs.isNotEmpty) await batch.commit();
  }

  @override
  Future<void> clearResolved() async {
    final snap = await _col.where('status', isEqualTo: 'resolved').get();
    final batch = _db.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    if (snap.docs.isNotEmpty) await batch.commit();
  }

  String _statusToString(ComplaintStatus s) => switch (s) {
        ComplaintStatus.pending => 'open',
        ComplaintStatus.underReview => 'reviewed',
        ComplaintStatus.resolved => 'resolved',
      };

  ComplaintStatus _statusFromString(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'resolved':
        return ComplaintStatus.resolved;
      case 'reviewed':
      case 'underreview':
        return ComplaintStatus.underReview;
      default:
        return ComplaintStatus.pending;
    }
  }

  ComplaintModel _fromMap(String id, Map<String, dynamic> d) {
    final ts = d['postedAt'] ?? d['createdAt'];
    return ComplaintModel(
      id: id,
      category: d['category'] ?? '',
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      postedAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
      status: _statusFromString(d['status'] as String?),
    );
  }
}
// lib/data/repositories/firebase_committee_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apartmate/data/models/committee_model.dart';
import 'package:apartmate/domain/repositories/i_committee_repository.dart';

class FirebaseCommitteeRepository implements ICommitteeRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('committeeMembers');

  @override
  Future<List<CommitteeMemberModel>> getMembers() async {
    final snap = await _col.get();
    return snap.docs.map((d) => _fromMap(d.id, d.data())).toList();
  }

  @override
  Future<CommitteeMemberModel> addMember(CommitteeMemberModel member) async {
    final id = member.id.isEmpty ? _col.doc().id : member.id;
    final toSave = CommitteeMemberModel(
      id: id,
      name: member.name,
      phone: member.phone,
      email: member.email,
      role: member.role,
    );
    await _col.doc(id).set({
      'name': toSave.name,
      'phone': toSave.phone,
      'email': toSave.email,
      'role': toSave.role,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return toSave;
  }

  @override
  Future<void> removeMember(String id) async {
    if (id.isEmpty) return;
    await _col.doc(id).delete();
  }

  CommitteeMemberModel _fromMap(String id, Map<String, dynamic> d) =>
      CommitteeMemberModel(
        id: id,
        name: d['name'] ?? '',
        phone: d['phone'] ?? '',
        email: d['email'] ?? '',
        role: d['role'] ?? '',
      );
}
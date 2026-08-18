// lib/data/repositories/firebase_owner_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apartmate/data/models/owner_model.dart';
import 'package:apartmate/domain/repositories/i_owner_repository.dart';

class FirebaseOwnerRepository implements IOwnerRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('owners');

  @override
  Future<List<OwnerModel>> getOwners() async {
    final snap = await _col.get();
    return snap.docs.map((d) => _fromMap(d.id, d.data())).toList();
  }

  @override
  Future<OwnerModel> addOwner(OwnerModel owner) async {
    final id = owner.id.isEmpty ? _col.doc().id : owner.id;
    final toSave = OwnerModel(
      id: id,
      name: owner.name,
      phone: owner.phone,
      email: owner.email,
      cnic: owner.cnic,
      buildingName: owner.buildingName,
      flatNumber: owner.flatNumber,
    );
    await _col.doc(id).set({
      'name': toSave.name,
      'phone': toSave.phone,
      'email': toSave.email,
      'cnic': toSave.cnic,
      'buildingName': toSave.buildingName,
      'flatNumber': toSave.flatNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return toSave;
  }

  @override
  Future<void> removeOwner(String id) async {
    if (id.isEmpty) return;
    await _col.doc(id).delete();
  }

  OwnerModel _fromMap(String id, Map<String, dynamic> d) => OwnerModel(
        id: id,
        name: d['name'] ?? '',
        phone: d['phone'] ?? '',
        email: d['email'] ?? '',
        cnic: d['cnic'] ?? '',
        buildingName: d['buildingName'] ?? '',
        flatNumber: d['flatNumber'] ?? '',
      );
}
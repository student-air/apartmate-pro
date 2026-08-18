// lib/data/repositories/firebase_resident_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apartmate/data/models/resident_model.dart';
import 'package:apartmate/domain/repositories/i_resident_repository.dart';

class FirebaseResidentRepository implements IResidentRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('residents');

  @override
  Future<List<ResidentModel>> getResidents() async {
    final snap = await _col.get();
    return snap.docs.map((d) => _fromMap(d.id, d.data())).toList();
  }

  @override
  Future<ResidentModel> addResident(ResidentModel resident) async {
    final id = resident.id.isEmpty ? _col.doc().id : resident.id;
    final toSave = ResidentModel(
      id: id,
      buildingId: resident.buildingId,
      buildingName: resident.buildingName,
      floor: resident.floor,
      flatNumber: resident.flatNumber,
      flatType: resident.flatType,
      name: resident.name,
      cnic: resident.cnic,
      phone: resident.phone,
      email: resident.email,
      residentsCount: resident.residentsCount,
      allotmentDate: resident.allotmentDate,
      leaseDurationMonths: resident.leaseDurationMonths,
      rent: resident.rent,
      profession: resident.profession,
      employerCompany: resident.employerCompany,
      previousAddress: resident.previousAddress,
      emergencyContact: resident.emergencyContact,
      rentPaid: resident.rentPaid,
      maintenancePaid: resident.maintenancePaid,
      occupiedBy: resident.occupiedBy,
    );
    await _col.doc(id).set(_toMap(toSave), SetOptions(merge: true));
    return toSave;
  }

  @override
  Future<void> removeResident(String residentId) async {
    if (residentId.isEmpty) return;
    await _col.doc(residentId).delete();
  }

  @override
  Future<ResidentModel> updatePaymentStatus(
    String residentId, {
    bool? rentPaid,
    bool? maintenancePaid,
  }) async {
    final doc = await _col.doc(residentId).get();
    if (!doc.exists || doc.data() == null) {
      throw StateError('Resident not found: $residentId');
    }
    final current = _fromMap(doc.id, doc.data()!);
    final updated = current.copyWith(
      rentPaid: rentPaid,
      maintenancePaid: maintenancePaid,
    );
    await _col.doc(residentId).set({
      if (rentPaid != null) 'rentPaid': rentPaid,
      if (maintenancePaid != null) 'maintenancePaid': maintenancePaid,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return updated;
  }

  Map<String, dynamic> _toMap(ResidentModel r) => {
        'buildingId': r.buildingId,
        'buildingName': r.buildingName,
        'floor': r.floor,
        'flatNumber': r.flatNumber,
        'flatType': r.flatType,
        'name': r.name,
        'cnic': r.cnic,
        'phone': r.phone,
        'email': r.email,
        'residentsCount': r.residentsCount,
        'allotmentDate': Timestamp.fromDate(r.allotmentDate),
        'leaseDurationMonths': r.leaseDurationMonths,
        'rent': r.rent,
        'profession': r.profession,
        'employerCompany': r.employerCompany,
        'previousAddress': r.previousAddress,
        'emergencyContact': r.emergencyContact,
        'rentPaid': r.rentPaid,
        'maintenancePaid': r.maintenancePaid,
        'occupiedBy': r.occupiedBy.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  ResidentModel _fromMap(String id, Map<String, dynamic> d) {
    final occ = (d['occupiedBy'] as String?)?.toLowerCase() == 'owner'
        ? OccupantType.owner
        : OccupantType.tenant;
    return ResidentModel(
      id: id,
      buildingId: d['buildingId'] ?? '',
      buildingName: d['buildingName'] ?? '',
      floor: (d['floor'] as num?)?.toInt() ?? 0,
      flatNumber: d['flatNumber'] ?? '',
      flatType: d['flatType'] ?? '',
      name: d['name'] ?? '',
      cnic: d['cnic'] ?? '',
      phone: d['phone'] ?? '',
      email: d['email'] ?? '',
      residentsCount: (d['residentsCount'] as num?)?.toInt() ?? 0,
      allotmentDate:
          (d['allotmentDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      leaseDurationMonths: (d['leaseDurationMonths'] as num?)?.toInt() ?? 0,
      rent: (d['rent'] as num?)?.toDouble() ?? 0,
      profession: d['profession'] ?? '',
      employerCompany: d['employerCompany'] ?? '',
      previousAddress: d['previousAddress'] ?? '',
      emergencyContact: d['emergencyContact'] ?? '',
      rentPaid: d['rentPaid'] == true,
      maintenancePaid: d['maintenancePaid'] == true,
      occupiedBy: occ,
    );
  }
}
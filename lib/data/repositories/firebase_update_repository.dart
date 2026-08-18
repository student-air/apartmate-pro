// lib/data/repositories/firebase_update_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apartmate/data/models/update_model.dart';
import 'package:apartmate/domain/repositories/i_update_repository.dart';

class FirebaseUpdateRepository implements IUpdateRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('updates');

  @override
  Future<List<UpdateModel>> getUpdates() async {
    final snap = await _col.get();
    final list = snap.docs.map((d) => _fromMap(d.id, d.data())).toList();
    list.sort((a, b) => b.postedAt.compareTo(a.postedAt));
    return List.unmodifiable(list);
  }

  @override
  Future<UpdateModel> addUpdate(UpdateModel update) async {
    final id = update.id.isEmpty ? _col.doc().id : update.id;
    final toSave = UpdateModel(
      id: id,
      type: update.type,
      title: update.title,
      description: update.description,
      postedAt: update.postedAt,
      category: update.category,
      sendTo: update.sendTo,
      buildingName: update.buildingName,
      floor: update.floor,
      flatNumber: update.flatNumber,
    );
    await _col.doc(id).set(_toMap(toSave), SetOptions(merge: true));
    return toSave;
  }

  @override
  Future<void> deleteUpdate(String id) async {
    if (id.isEmpty) return;
    await _col.doc(id).delete();
  }

  @override
  Future<void> clearAll() async {
    final snap = await _col.get();
    final batch = _db.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    if (snap.docs.isNotEmpty) await batch.commit();
  }

  Map<String, dynamic> _toMap(UpdateModel u) => {
        'type': u.type.name,
        'title': u.title,
        'description': u.description,
        'category': u.category,
        'sendTo': u.sendTo,
        'buildingName': u.buildingName,
        'floor': u.floor,
        'flatNumber': u.flatNumber,
        'postedAt': Timestamp.fromDate(u.postedAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  UpdateModel _fromMap(String id, Map<String, dynamic> d) {
    final typeStr = (d['type'] as String?)?.toLowerCase() ?? 'general';
    final type = UpdateType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => UpdateType.general,
    );
    return UpdateModel(
      id: id,
      type: type,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      postedAt: (d['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: d['category'] as String?,
      sendTo: d['sendTo'] ?? 'All',
      buildingName: d['buildingName'] as String?,
      floor: (d['floor'] as num?)?.toInt(),
      flatNumber: d['flatNumber'] as String?,
    );
  }
}
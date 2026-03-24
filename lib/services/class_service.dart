import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final classServiceProvider = Provider((ref) => ClassService());

class ClassService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ClassModel>> getClasses() {
    return _firestore.collection('classes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ClassModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addClass(ClassModel classModel) async {
    final docRef = _firestore.collection('classes').doc();
    final newClass = ClassModel(
      id: docRef.id,
      year: classModel.year,
      branch: classModel.branch,
      section: classModel.section,
    );
    await docRef.set(newClass.toMap());
  }

  Future<void> updateClass(ClassModel classModel) async {
    await _firestore.collection('classes').doc(classModel.id).update(classModel.toMap());
  }

  Future<void> deleteClass(String id) async {
    await _firestore.collection('classes').doc(id).delete();
  }
}

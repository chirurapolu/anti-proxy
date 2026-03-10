import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String studentUserId;
  final String status; // 'present' or 'absent'
  final DateTime? timestamp;
  final String? note;
  final String markedBy; // 'student', 'faculty', or 'auto'

  AttendanceRecord({
    required this.studentUserId,
    required this.status,
    this.timestamp,
    this.note,
    required this.markedBy,
  });

  factory AttendanceRecord.fromMap(String id, Map<String, dynamic> map) {
    return AttendanceRecord(
      studentUserId: id,
      status: map['status'] ?? 'absent',
      timestamp: map['timestamp'] != null ? (map['timestamp'] as Timestamp).toDate() : null,
      note: map['note'],
      markedBy: map['marked_by'] ?? 'auto',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'note': note,
      'marked_by': markedBy,
    };
  }
}

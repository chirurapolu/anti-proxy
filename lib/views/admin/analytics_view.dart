import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class StudentAnalytics {
  final String id;
  final String name;
  final String section;
  int presentCount = 0;
  int totalSessions = 0;

  StudentAnalytics({required this.id, required this.name, required this.section});

  double get attendancePercentage => totalSessions == 0 ? 0 : (presentCount / totalSessions) * 100;
}

class _AnalyticsViewState extends State<AnalyticsView> {
  bool _isLoading = true;
  bool _filterLowAttendance = false;
  List<StudentAnalytics> _analyticsData = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch all students
      final usersSnap = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'student').get();
      Map<String, StudentAnalytics> studentMap = {};
      for (var doc in usersSnap.docs) {
        final data = doc.data();
        studentMap[doc.id] = StudentAnalytics(
          id: doc.id,
          name: data['name'] ?? 'Unknown',
          section: data['section'] ?? 'Unassigned',
        );
      }

      // Fetch closed sessions and attendance
      final sessionsSnap = await FirebaseFirestore.instance.collection('class_sessions').where('status', isEqualTo: 'closed').get();
      for (var sessionDoc in sessionsSnap.docs) {
        final attendanceSnap = await sessionDoc.reference.collection('attendance').get();
        for (var attDoc in attendanceSnap.docs) {
          final studentId = attDoc.id;
          final status = attDoc.data()['status'];
          if (studentMap.containsKey(studentId)) {
            studentMap[studentId]!.totalSessions += 1;
            if (status == 'present') {
              studentMap[studentId]!.presentCount += 1;
            }
          }
        }
      }

      setState(() {
        _analyticsData = studentMap.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading analytics: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generatePdf(List<StudentAnalytics> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Attendance Analytics Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Generated on: ${DateTime.now().toIso8601String().split('T')[0]}'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Roll No', 'Name', 'Section', 'Total', 'Present', '%'],
                data: data.map((s) => [
                  s.id,
                  s.name,
                  s.section,
                  s.totalSessions.toString(),
                  s.presentCount.toString(),
                  '${s.attendancePercentage.toStringAsFixed(1)}%'
                ]).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _filterLowAttendance 
        ? _analyticsData.where((s) => s.attendancePercentage < 65.0).toList() 
        : _analyticsData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export as PDF',
            onPressed: () => _generatePdf(filteredData),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('< 65% Attendance'),
                      selected: _filterLowAttendance,
                      onSelected: (val) => setState(() => _filterLowAttendance = val),
                      selectedColor: Colors.red.withValues(alpha: 0.2),
                      checkmarkColor: Colors.red,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Roll No')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Section')),
                        DataColumn(label: Text('Total')),
                        DataColumn(label: Text('Present')),
                        DataColumn(label: Text('%')),
                      ],
                      rows: filteredData.map((s) {
                        final isLow = s.attendancePercentage < 65.0;
                        return DataRow(cells: [
                          DataCell(Text(s.id)),
                          DataCell(Text(s.name)),
                          DataCell(Text(s.section)),
                          DataCell(Text(s.totalSessions.toString())),
                          DataCell(Text(s.presentCount.toString())),
                          DataCell(Text(
                            '${s.attendancePercentage.toStringAsFixed(1)}%',
                            style: TextStyle(color: isLow ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generatePdf(filteredData),
        icon: const Icon(Icons.download),
        label: const Text('Download PDF'),
      ),
    );
  }
}

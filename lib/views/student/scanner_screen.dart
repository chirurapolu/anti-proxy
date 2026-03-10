import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'verification_view.dart';
import '../../models/session_model.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code == null) return;

      setState(() => _isProcessing = true);
      
      try {
        final Map<String, dynamic> payload = jsonDecode(code);
        final String sessionId = payload['s_id'];
        final int timestamp = payload['ts'];

        // Layer 1: Time validation (QR must be < 60s old)
        final diff = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (diff > 60000 || diff < -5000) {
          throw 'QR Expired. Please scan the current one.';
        }

        // Fetch session for GPS data
        final doc = await FirebaseFirestore.instance.collection('class_sessions').doc(sessionId).get();
        if (!doc.exists) throw 'Invalid Session';
        
        final session = SessionModel.fromMap(doc.id, doc.data()!);
        if (session.status != 'open') throw 'Session is closed';

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => VerificationView(session: session)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Faculty QR')),
      body: MobileScanner(
        controller: MobileScannerController(facing: CameraFacing.back),
        onDetect: _onDetect,
      ),
    );
  }
}

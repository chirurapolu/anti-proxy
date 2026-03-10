import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/session_model.dart';

class QrGeneratorScreen extends StatefulWidget {
  final SessionModel session;
  const QrGeneratorScreen({super.key, required this.session});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  String _qrData = '';
  int _countdown = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _generatePayload();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        setState(() {
          _countdown = 10;
          _generatePayload();
        });
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _generatePayload() {
    final payload = {
      's_id': widget.session.sessionId,
      'sec': widget.session.section,
      'ts': DateTime.now().millisecondsSinceEpoch,
      'f_id': widget.session.facultyUserId,
    };
    _qrData = jsonEncode(payload);
    
    // Also update in Firestore session doc for extra verification layer if needed
    FirebaseFirestore.instance.collection('class_sessions').doc(widget.session.sessionId).update({
      'qr_payload': _qrData,
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR: ${widget.session.subject}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Scan to mark presence', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Section: ${widget.session.section}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            QrImageView(
              data: _qrData,
              version: QrVersions.auto,
              size: 280.0,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 32),
            Text('Refreshes in: $_countdown seconds', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

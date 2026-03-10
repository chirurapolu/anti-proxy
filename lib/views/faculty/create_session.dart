import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/session_model.dart';
import '../../services/auth_service.dart';

class CreateSession extends ConsumerStatefulWidget {
  const CreateSession({super.key});

  @override
  ConsumerState<CreateSession> createState() => _CreateSessionState();
}

class _CreateSessionState extends ConsumerState<CreateSession> {
  final _subjectController = TextEditingController();
  final _sectionController = TextEditingController();
  final _radiusController = TextEditingController(text: '25');
  Position? _currentPosition;
  bool _isLoading = false;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() => _currentPosition = position);
  }

  Future<void> _submit() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please get current location first')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final session = SessionModel(
        sessionId: 'proto_${DateTime.now().millisecondsSinceEpoch}',
        subject: _subjectController.text,
        section: _sectionController.text,
        facultyUserId: 'faculty_demo',
        facultyAuthUid: 'demo_uid',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        radius: double.parse(_radiusController.text),
        status: 'open',
        createdAt: DateTime.now(),
      );

      if (AuthService.isPrototypeMode) {
        debugPrint("Firebase Session creation skipped in prototype mode");
      } else {
        await FirebaseFirestore.instance.collection('class_sessions').add(session.toMap());
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Prototype Success: Session created locally'),
          backgroundColor: Colors.blue,
        ));
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Class Session')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _subjectController, decoration: const InputDecoration(labelText: 'Subject (e.g. Mathematics)')),
            const SizedBox(height: 16),
            TextField(controller: _sectionController, decoration: const InputDecoration(labelText: 'Section (e.g. CSE-A)')),
            const SizedBox(height: 16),
            TextField(controller: _radiusController, decoration: const InputDecoration(labelText: 'Radius (meters)'), keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            ListTile(
              title: Text(_currentPosition == null ? 'Location not set' : 'Location Captured'),
              subtitle: Text(_currentPosition == null ? 'Tap button to get GPS' : 'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}'),
              trailing: IconButton(icon: const Icon(Icons.my_location), onPressed: _getCurrentLocation),
            ),
            const SizedBox(height: 32),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: _submit, child: const Text('Create Session')),
          ],
        ),
      ),
    );
  }
}

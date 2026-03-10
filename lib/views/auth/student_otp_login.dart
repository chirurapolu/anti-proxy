import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../student/student_home.dart';

class StudentOtpLogin extends StatefulWidget {
  const StudentOtpLogin({super.key});

  @override
  State<StudentOtpLogin> createState() => _StudentOtpLoginState();
}

class _StudentOtpLoginState extends State<StudentOtpLogin> {
  final _userIdController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpRequested = false;
  bool _isLoading = false;

  Future<void> _requestOtp() async {
    setState(() => _isLoading = true);
    bool success = await AuthService().requestOTP(_userIdController.text);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (success) _otpRequested = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? 'OTP Requested' : 'User not found')));
    }
  }

  Future<void> _verifyAndLogin() async {
    setState(() => _isLoading = true);
    bool success = await AuthService()
        .verifyOTP(_userIdController.text, _otpController.text);
    if (success) {
      // Anonymous join
      if (!AuthService.isPrototypeMode) {
        await AuthService().signInAnonymously();
      }
      // Note: In real app, we'd link this or store UID in Firestore linked to Student Roll No
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const StudentHome()));
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Invalid OTP')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student OTP Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _userIdController,
              decoration:
                  const InputDecoration(labelText: 'Student Roll No / User ID'),
              enabled: !_otpRequested,
            ),
            if (_otpRequested) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP (from Admin)',
                  hintText: 'Enter 6-digit OTP provided by Admin',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _otpRequested ? _verifyAndLogin : _requestOtp,
                    child:
                        Text(_otpRequested ? 'Verify & Login' : 'Request OTP'),
                  ),
          ],
        ),
      ),
    );
  }
}

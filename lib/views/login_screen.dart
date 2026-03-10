import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/large_button.dart';
import 'auth/admin_login_screen.dart';
import 'auth/faculty_login_screen.dart';
import 'auth/student_otp_login.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.security_rounded,
                size: 80,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(height: 24),
              Text(
                'Smart Attendance',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Text(
                'Anti-Proxy Verification System',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 60),
              LargeButton(
                title: 'Administrator',
                icon: Icons.admin_panel_settings_rounded,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                ),
              ),
              const SizedBox(height: 16),
              LargeButton(
                title: 'Faculty Member',
                icon: Icons.school_rounded,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FacultyLoginScreen()),
                ),
              ),
              const SizedBox(height: 16),
              LargeButton(
                title: 'Student',
                icon: Icons.person_rounded,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentOtpLogin()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

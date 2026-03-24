import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'user_registration.dart';
import 'otp_management.dart';
import 'create_class_view.dart';
import 'analytics_view.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildCard(
            context,
            'Register User',
            Icons.person_add,
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const UserRegistration())),
          ),
          _buildCard(
            context,
            'Manage OTPs',
            Icons.vpn_key_rounded,
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const OtpManagement())),
          ),
          _buildCard(
            context,
            'Analytics',
            Icons.analytics_outlined,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsView())),
          ),
          _buildCard(
            context,
            'Create Class',
            Icons.class_,
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CreateClassView())),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

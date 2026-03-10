import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'scanner_screen.dart';

class StudentHome extends ConsumerWidget {
  const StudentHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authServiceProvider).signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome, ${user?.name ?? "Student"}', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Section: ${user?.section ?? "N/A"}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 48),
              const Icon(Icons.qr_code_scanner_rounded, size: 100, color: Colors.blue),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen())),
                child: const Text('Scan & Mark Attendance'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Note: Ensure you are inside the classroom and have good lighting for facial verification.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

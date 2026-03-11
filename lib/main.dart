import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'views/login_screen.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';
import 'views/admin/admin_dashboard.dart';
import 'views/faculty/faculty_home.dart';
import 'views/student/student_home.dart';
import 'views/student/face_registration_view.dart';
import 'providers/auth_provider.dart';
import 'models/user_model.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Attempt Firebase initialization
    if (!AuthService.isPrototypeMode) {
      debugPrint('Main: Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Main: Firebase initialized successfully.');
    }
  } catch (e) {
    debugPrint('Main: Initialization error: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anti-Proxy Attendance',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        debugPrint('AuthWrapper: User is ${user?.uid}');
        if (user == null) {
          return const LoginSelectionScreen();
        }

        // Use userProvider to get role-based redirection
        final userModelAsync = ref.watch(userProvider);

        return userModelAsync.when(
          data: (userModel) {
            debugPrint(
                'AuthWrapper: UserModel is ${userModel?.userId}, Role: ${userModel?.role}');
            if (userModel == null) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_search,
                          size: 64, color: Colors.blue),
                      const SizedBox(height: 16),
                      const Text('Profile not found in database.',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'You are logged into Auth, but your student/admin record does not exist. \n\nPlease use the "Bootstrap" step I provided to register yourself as an ADMIN first.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(authServiceProvider).signOut(),
                        child: const Text('Sign Out & Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            switch (userModel.role) {
              case UserRole.admin:
                return const AdminDashboard();
              case UserRole.faculty:
                return const FacultyHome();
              case UserRole.student:
                if (!userModel.faceRegistered) {
                  return FaceRegistrationView(userId: userModel.userId);
                }
                return const StudentHome();
            }
          },
          loading: () {
            debugPrint('AuthWrapper: userProvider is loading...');
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    const Text('Fetching your profile...'),
                    const SizedBox(height: 32),
                    TextButton(
                      onPressed: () => ref.read(authServiceProvider).signOut(),
                      child: const Text('Stuck? Sign Out'),
                    ),
                  ],
                ),
              ),
            );
          },
          error: (e, stack) {
            debugPrint('AuthWrapper: userProvider error: $e');
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error loading profile: $e'),
                    ElevatedButton(
                      onPressed: () => ref.read(authServiceProvider).signOut(),
                      child: const Text('Refresh / Sign Out'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () {
        debugPrint('AuthWrapper: authStateProvider is loading...');
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
      error: (e, stack) {
        debugPrint('AuthWrapper: authStateProvider error: $e');
        return Scaffold(
          body: Center(child: Text('Authentication Error: $e')),
        );
      },
    );
  }
}

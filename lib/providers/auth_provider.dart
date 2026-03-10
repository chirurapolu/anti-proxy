import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return await ref.watch(authServiceProvider).getUserData(user.uid);
});

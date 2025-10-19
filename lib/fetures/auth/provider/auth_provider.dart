import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:memora/fetures/auth/service/auth_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

// Loading state provider for auth operations
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Error message provider
final authErrorProvider = StateProvider<String?>((ref) => null);

// Auth controller provider
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref ref;

  AuthController(this.ref);

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    final result = await ref
        .read(authServiceProvider)
        .signUpWithEmail(
          email: email,
          password: password,
          name: name,
        );

    ref.read(authLoadingProvider.notifier).state = false;

    if (!result.success) {
      ref.read(authErrorProvider.notifier).state = result.message;
    }

    return result.success;
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    final result = await ref
        .read(authServiceProvider)
        .signInWithEmail(
          email: email,
          password: password,
        );

    ref.read(authLoadingProvider.notifier).state = false;

    if (!result.success) {
      ref.read(authErrorProvider.notifier).state = result.message;
    }

    return result.success;
  }

  // Sign out
  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    final result = await ref.read(authServiceProvider).resetPassword(email);

    ref.read(authLoadingProvider.notifier).state = false;

    if (!result.success) {
      ref.read(authErrorProvider.notifier).state = result.message;
    } else {
      ref.read(authErrorProvider.notifier).state = result.message;
    }

    return result.success;
  }

  // Clear error
  void clearError() {
    ref.read(authErrorProvider.notifier).state = null;
  }
}

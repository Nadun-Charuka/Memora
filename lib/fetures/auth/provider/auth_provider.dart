import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:memora/fetures/auth/models/app_user.dart';

// ============================================
// Auth State Provider - Listens to Firebase Auth
// ============================================
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// ============================================
// Current User Provider - Gets full user data from Firestore
// ============================================
final currentUserProvider = StreamProvider<AppUser?>((ref) async* {
  final authState = ref.watch(authStateProvider);

  yield* authState.when(
    data: (firebaseUser) async* {
      if (firebaseUser == null) {
        yield null;
      } else {
        // Fetch user document from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          yield AppUser.fromMap(userDoc.data()!);
        } else {
          // User document doesn't exist, create basic user
          yield AppUser(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? 'User',
            coupleId: null,
            createdAt: DateTime.now(),
          );
        }
      }
    },
    loading: () async* {
      yield null;
    },
    error: (error, stack) async* {
      yield null;
    },
  );
});

// ============================================
// Auth Controller - Handles auth actions
// ============================================
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController() : super(const AsyncValue.data(null));

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      final user = AppUser(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        coupleId: null,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id).set(user.toMap());

      // Update display name
      await userCredential.user!.updateDisplayName(name);
    });
  }

  // Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  // Sign out
  Future<void> signOut() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _auth.signOut();
    });
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _auth.sendPasswordResetEmail(email: email);
    });
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      return AuthController();
    });

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user account
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);

        // Create user document
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'name': name,
          'email': email.trim(),
          'avatar': '',
          'coupleId': null,
          'createdAt': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
        });

        return AuthResult(success: true, user: credential.user);
      }

      return AuthResult(success: false, message: 'Failed to create account');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _handleAuthError(e));
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update last active
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).update({
          'lastActive': FieldValue.serverTimestamp(),
        });
      }

      return AuthResult(success: true, user: credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _handleAuthError(e));
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult(success: true, message: 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _handleAuthError(e));
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  // Check if user has a couple/village
  Future<bool> hasCouple() async {
    if (currentUser == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    return doc.data()?['coupleId'] != null;
  }

  // Handle Firebase Auth errors
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign in is not enabled.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

// Auth result class
class AuthResult {
  final bool success;
  final String? message;
  final User? user;

  AuthResult({
    required this.success,
    this.message,
    this.user,
  });
}

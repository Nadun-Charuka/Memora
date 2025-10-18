import 'package:memora/core/constants/app_constants.dart';

class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? memoContent(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please write something';
    }
    if (value.length > AppConstants.maxMemoLength) {
      return 'Memo is too long (max ${AppConstants.maxMemoLength} characters)';
    }
    return null;
  }

  static String? pairingCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter pairing code';
    }
    if (value.length != AppConstants.pairingCodeLength) {
      return 'Code must be ${AppConstants.pairingCodeLength} characters';
    }
    return null;
  }
}

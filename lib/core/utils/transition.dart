import 'package:flutter/material.dart';

/// 🌟 A collection of smooth, reusable page transitions for your app.
///
/// Usage example:
/// ```dart
/// Navigator.of(context).push(appFadeScaleRoute(const AddMemoryScreen()));
/// ```

/// Fade + scale transition (most commonly used)
Route<T> appFadeScaleRoute<T>(
  Widget page, {
  Duration duration = const Duration(milliseconds: 400),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Slide + fade transition (smooth horizontal motion)
Route<T> appSlideFadeRoute<T>(
  Widget page, {
  Duration duration = const Duration(milliseconds: 400),
  Offset beginOffset = const Offset(0.1, 0), // from right by default
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Pure scale transition (like zoom-in)
Route<T> appScaleRoute<T>(
  Widget page, {
  Duration duration = const Duration(milliseconds: 350),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInBack,
      );

      return ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
        child: child,
      );
    },
  );
}

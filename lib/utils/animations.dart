import 'package:flutter/material.dart';

class AppAnimations {
  // Standard durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }

  // Slide in from bottom animation
  static Widget slideInFromBottom({
    required Widget child,
    Duration duration = normal,
    Curve curve = Curves.easeOut,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(offset: value, child: child);
      },
      child: child,
    );
  }

  // Scale animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = fast,
    Curve curve = Curves.elasticOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }

  // Bounce animation for success feedback
  static Widget bounceIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.3, end: 1.0),
      duration: duration,
      curve: Curves.bounceOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }

  // Shimmer loading effect
  static Widget shimmer({required Widget child, required bool isLoading}) {
    if (!isLoading) return child;

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds);
      },
      child: child,
    );
  }

  // Pulse animation for attention
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 1.1),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }

  // Staggered animation for lists
  static Widget staggeredFadeIn({
    required Widget child,
    required int index,
    Duration duration = normal,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // FAB press animation
  static Widget fabPressAnimation({
    required Widget child,
    required bool isPressed,
  }) {
    return AnimatedScale(
      scale: isPressed ? 0.95 : 1.0,
      duration: fast,
      curve: Curves.easeInOut,
      child: child,
    );
  }

  // Card hover effect
  static Widget cardHoverEffect({
    required Widget child,
    required bool isHovered,
  }) {
    return AnimatedScale(
      scale: isHovered ? 1.02 : 1.0,
      duration: fast,
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: fast,
        decoration: BoxDecoration(
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: child,
      ),
    );
  }

  // Loading dots animation
  static Widget loadingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // Success checkmark animation
  static Widget successCheckmark({
    required bool show,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return AnimatedOpacity(
      opacity: show ? 1.0 : 0.0,
      duration: duration,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: duration,
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
          );
        },
      ),
    );
  }

  // Error shake animation
  static Widget shakeAnimation({required Widget child, required bool shake}) {
    if (!shake) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 4.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticIn,
      builder: (context, value, child) {
        return Transform.translate(offset: Offset(value * 2, 0), child: child);
      },
      child: child,
    );
  }
}

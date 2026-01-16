import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılacak animasyonlu route'lar
class AnimatedRoute {
  /// ➡️ Sağdan kayarak + fade (ana geçiş)
  static Route slide(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder:
          (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.15, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        final fadeAnimation = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(animation);

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// ⬆️ Aşağıdan yukarı (modal hissi)
  static Route bottom(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder:
          (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// 🌫️ Sadece fade (çok yumuşak geçiş)
  static Route fade(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder:
          (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}

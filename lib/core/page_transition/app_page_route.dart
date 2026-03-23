import 'package:flutter/material.dart';

part 'page_transition_type.dart';

class AppPageRoute {
  static PageRoute<T> build<T>({
    required Widget Function(BuildContext context) page,
    PageTransitionType transition = PageTransitionType.slideFromRight,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (ctx, __, ___) => page(ctx),
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        switch (transition) {
          case PageTransitionType.slideFromRight:
            return SlideTransition(
              position: Tween(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );

          case PageTransitionType.slideFromLeft:
            return SlideTransition(
              position: Tween(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );

          case PageTransitionType.slideFromBottom:
            return SlideTransition(
              position: Tween(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );

          case PageTransitionType.slideFromTop:
            return SlideTransition(
              position: Tween(
                begin: const Offset(0.0, -1.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );

          case PageTransitionType.fade:
            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );

          case PageTransitionType.scale:
            return ScaleTransition(
              scale: Tween(
                begin: 0.8,
                end: 1.0,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: curvedAnimation,
                child: child,
              ),
            );

          case PageTransitionType.rotate:
            return RotationTransition(
              turns: Tween(
                begin: 0.5,
                end: 0.0,
              ).animate(curvedAnimation),
              child: ScaleTransition(
                scale: Tween(
                  begin: 0.9,
                  end: 1.0,
                ).animate(curvedAnimation),
                child: child,
              ),
            );

          case PageTransitionType.zoom:
            return ScaleTransition(
              scale: Tween(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: curvedAnimation,
                curve: Curves.elasticOut,
              )),
              child: child,
            );

          case PageTransitionType.size:
            return SizeTransition(
              sizeFactor: curvedAnimation,
              axis: Axis.vertical,
              child: FadeTransition(
                opacity: curvedAnimation,
                child: child,
              ),
            );

          case PageTransitionType.slideFromRightWithFade:
            return SlideTransition(
              position: Tween(
                begin: const Offset(0.5, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: curvedAnimation,
                child: child,
              ),
            );

          case PageTransitionType.slideFromBottomWithScale:
            return SlideTransition(
              position: Tween(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: ScaleTransition(
                scale: Tween(
                  begin: 0.95,
                  end: 1.0,
                ).animate(curvedAnimation),
                child: child,
              ),
            );

          case PageTransitionType.flip:
            return AnimatedBuilder(
              animation: curvedAnimation,
              builder: (context, child) {
                final value = curvedAnimation.value;
                final angle = (1 - value) * 3.14159; // 180 градусов
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: child,
                );
              },
              child: child,
            );

          case PageTransitionType.bounce:
            return SlideTransition(
              position: Tween(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: curvedAnimation,
                curve: Curves.bounceOut,
              )),
              child: child,
            );
        }
      },
    );
  }

  // Метод для обратной анимации (при закрытии)
  static PageRoute<T> buildWithHero<T>({
    required Widget page,
    required String heroTag,
    PageTransitionType transition = PageTransitionType.scale,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => Hero(
        tag: heroTag,
        child: page,
      ),
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        switch (transition) {
          case PageTransitionType.scale:
            return ScaleTransition(
              scale: Tween(
                begin: 0.8,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          default:
            return child;
        }
      },
    );
  }

  // Метод для модальных окон
  static PageRoute<T> buildModal<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      opaque: false,
      barrierColor: Colors.black54,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0.0, 0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
    );
  }

  // Метод для кастомных анимаций с возможностью настройки
  static PageRoute<T> buildCustom<T>({
    required Widget page,
    required Widget Function(Animation<double>, Widget) transitionBuilder,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (_, animation, __, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        return transitionBuilder(curvedAnimation, child);
      },
    );
  }
}

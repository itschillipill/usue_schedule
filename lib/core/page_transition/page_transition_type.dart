part of 'app_page_route.dart';

enum PageTransitionType {
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  slideFromTop,
  fade,
  scale,
  rotate,
  zoom,
  size,
  slideFromRightWithFade,
  slideFromBottomWithScale,
  flip,
  bounce,
}

// Расширение для удобного использования
extension PageTransitionExtension on PageTransitionType {
  String get name {
    switch (this) {
      case PageTransitionType.slideFromRight:
        return 'Слайд справа';
      case PageTransitionType.slideFromLeft:
        return 'Слайд слева';
      case PageTransitionType.slideFromBottom:
        return 'Слайд снизу';
      case PageTransitionType.slideFromTop:
        return 'Слайд сверху';
      case PageTransitionType.fade:
        return 'Затухание';
      case PageTransitionType.scale:
        return 'Масштабирование';
      case PageTransitionType.rotate:
        return 'Вращение';
      case PageTransitionType.zoom:
        return 'Зум';
      case PageTransitionType.size:
        return 'Размер';
      case PageTransitionType.slideFromRightWithFade:
        return 'Слайд справа с затуханием';
      case PageTransitionType.slideFromBottomWithScale:
        return 'Слайд снизу с масштабом';
      case PageTransitionType.flip:
        return 'Переворот';
      case PageTransitionType.bounce:
        return 'Отскок';
    }
  }

  IconData get icon {
    switch (this) {
      case PageTransitionType.slideFromRight:
        return Icons.arrow_forward;
      case PageTransitionType.slideFromLeft:
        return Icons.arrow_back;
      case PageTransitionType.slideFromBottom:
        return Icons.arrow_upward;
      case PageTransitionType.slideFromTop:
        return Icons.arrow_downward;
      case PageTransitionType.fade:
        return Icons.blur_on;
      case PageTransitionType.scale:
        return Icons.aspect_ratio;
      case PageTransitionType.rotate:
        return Icons.rotate_right;
      case PageTransitionType.zoom:
        return Icons.zoom_in;
      case PageTransitionType.size:
        return Icons.straighten;
      case PageTransitionType.slideFromRightWithFade:
        return Icons.arrow_forward_ios;
      case PageTransitionType.slideFromBottomWithScale:
        return Icons.zoom_out_map;
      case PageTransitionType.flip:
        return Icons.flip;
      case PageTransitionType.bounce:
        return Icons.sports_basketball;
    }
  }
}

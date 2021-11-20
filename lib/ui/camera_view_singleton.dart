import 'dart:ui';

class CameraViewSingleton {
  static double ratio = 0.0;
  static Size inputImageSize = const Size(0.0, 0.0);
  static Size screenSize = const Size(0.0, 0.0);
  static Size get actualPreviewSize =>
      Size(screenSize.width, screenSize.width * ratio);
}

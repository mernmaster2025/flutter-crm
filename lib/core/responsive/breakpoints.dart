import 'package:flutter/widgets.dart';

enum DeviceClass { phone, tablet, desktop }

class Breakpoints {
  const Breakpoints._();

  static const tablet = 700.0;
  static const desktop = 1100.0;

  static DeviceClass of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktop) return DeviceClass.desktop;
    if (width >= tablet) return DeviceClass.tablet;
    return DeviceClass.phone;
  }

  static bool isTabletOrLarger(BuildContext context) {
    return of(context) != DeviceClass.phone;
  }

  static int dashboardColumns(BuildContext context) {
    return switch (of(context)) {
      DeviceClass.phone => 2,
      DeviceClass.tablet => 3,
      DeviceClass.desktop => 4,
    };
  }
}

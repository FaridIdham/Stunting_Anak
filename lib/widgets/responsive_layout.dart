import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileView;
  final Widget? webDesktopView;

  const ResponsiveLayout({
    super.key,
    required this.mobileView,
    this.webDesktopView,
  });

  static bool isWebOrDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 840;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 840 && webDesktopView != null) {
          return webDesktopView!;
        }
        return mobileView;
      },
    );
  }
}

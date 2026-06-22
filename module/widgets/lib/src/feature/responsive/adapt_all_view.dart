import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

final class AdaptAllView extends StatelessWidget {
  const AdaptAllView(
      {required this.mobile,
      required this.tablet,
      required this.desktop,
      super.key});

  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    if (ResponsiveBreakpoints.of(context).isMobile) return mobile;
    if (ResponsiveBreakpoints.of(context).isTablet) return tablet;
    if (ResponsiveBreakpoints.of(context).isDesktop) return desktop;
    return mobile;
  }
}

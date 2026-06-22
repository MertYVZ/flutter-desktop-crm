import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

final class AdaptMobileView extends StatelessWidget {
  const AdaptMobileView({
    required this.mobile,
    required this.tablet,
    super.key,
  });

  final Widget mobile;
  final Widget tablet;

  @override
  Widget build(BuildContext context) {
    if (ResponsiveBreakpoints.of(context).isMobile) return mobile;
    if (ResponsiveBreakpoints.of(context).isTablet) return tablet;
    return tablet;
  }
}

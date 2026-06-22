import 'package:flutter/material.dart';

/// Desktop pointer styles for clickable controls.
abstract final class AppInteractiveTheme {
  static MouseCursor cursorFor(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return SystemMouseCursors.basic;
    }
    return SystemMouseCursors.click;
  }

  static final WidgetStateProperty<MouseCursor> clickCursor =
      WidgetStateProperty.resolveWith(cursorFor);

  static ButtonStyle filledButtonStyle(ButtonStyle base) {
    return base.copyWith(mouseCursor: clickCursor);
  }

  static ButtonStyle outlinedButtonStyle(ButtonStyle base) {
    return base.copyWith(mouseCursor: clickCursor);
  }

  static ButtonStyle textButtonStyle(ButtonStyle base) {
    return base.copyWith(mouseCursor: clickCursor);
  }

  static ButtonStyle iconButtonStyle(ButtonStyle base) {
    return base.copyWith(mouseCursor: clickCursor);
  }
}

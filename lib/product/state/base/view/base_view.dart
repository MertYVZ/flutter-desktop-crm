// ignore_for_file: strict_raw_type, document_ignores

import 'package:flutter/material.dart';

class BaseView<T> extends StatefulWidget {
  const BaseView({
    required this.viewModel,
    required this.onPageBuilder,
    super.key,
    this.onModelReady,
    this.onDispose,
  });

  final Widget Function(BuildContext context, T value) onPageBuilder;
  final T viewModel;
  final void Function(T model)? onModelReady;
  final VoidCallback? onDispose;

  @override
  State<BaseView> createState() => _BaseViewState<T>();
}

class _BaseViewState<T> extends State<BaseView<T>> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onModelReady?.call(widget.viewModel);
    });
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.onPageBuilder(context, widget.viewModel);
    final platform = Theme.of(context).platform;
    final isMobilePlatform = platform == TargetPlatform.iOS ||
        platform == TargetPlatform.android;

    // Desktop/web: global tap-to-unfocus breaks TextField focus and typing.
    if (!isMobilePlatform) {
      return content;
    }

    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: content,
    );
  }
}

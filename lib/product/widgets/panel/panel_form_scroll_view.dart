import 'package:flutter/material.dart';

/// Desktop-friendly scroll container for long form pages inside the app shell.
///
/// Ensures mouse wheel / trackpad scrolling works reliably on Windows and macOS
/// by combining a visible scrollbar with always-scrollable physics.
class PanelFormScrollView extends StatefulWidget {
  const PanelFormScrollView({
    required this.child,
    this.padding,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  State<PanelFormScrollView> createState() => _PanelFormScrollViewState();
}

class _PanelFormScrollViewState extends State<PanelFormScrollView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: widget.padding,
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

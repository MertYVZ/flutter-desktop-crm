import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CachedImage extends StatefulWidget {
  const CachedImage({
    required this.imageUrl,
    required this.width,
    required this.height,
    super.key,
    this.errorWidget,
    this.borderRadius,
    this.border,
  });
  final String imageUrl;
  final double width;
  final double height;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  @override
  Widget build(BuildContext context) {
    final resolvedRadius =
        widget.borderRadius ?? BorderRadius.zero;

    // URL null veya boş string ise profil ikonu göster
    if (widget.imageUrl.isEmpty || widget.imageUrl.trim().isEmpty) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: widget.border ??
                Border.all(
                  color: Colors.grey,
                ),
            borderRadius: resolvedRadius,
          ),
          child: const Center(
            child: Icon(Icons.person),
          ),
        ),
      );
    }

    // SVG dosyası kontrolü
    final isSvg = widget.imageUrl.toLowerCase().endsWith('.svg');

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Container(
        decoration: widget.border != null
            ? BoxDecoration(
                border: widget.border,
                borderRadius: resolvedRadius,
              )
            : null,
        child: ClipRRect(
          borderRadius: resolvedRadius,
          child: isSvg
              ? _SvgNetworkImage(
                  imageUrl: widget.imageUrl,
                  width: widget.width,
                  height: widget.height,
                  errorWidget: widget.errorWidget,
                  border: widget.border,
                  borderRadius: widget.borderRadius,
                )
              : CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  width: widget.width,
                  height: widget.height,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      widget.errorWidget ??
                      Container(
                        width: widget.width,
                        height: widget.height,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: widget.border ??
                              Border.all(
                                color: Colors.grey,
                              ),
                          borderRadius:
                              widget.borderRadius ?? BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(Icons.error),
                        ),
                      ),
                ),
        ),
      ),
    );
  }
}

/// SVG network image widget with error handling
class _SvgNetworkImage extends StatefulWidget {
  const _SvgNetworkImage({
    required this.imageUrl,
    required this.width,
    required this.height,
    this.errorWidget,
    this.border,
    this.borderRadius,
  });

  final String imageUrl;
  final double width;
  final double height;
  final Widget? errorWidget;
  final BoxBorder? border;
  final BorderRadius? borderRadius;

  @override
  State<_SvgNetworkImage> createState() => _SvgNetworkImageState();
}

class _SvgNetworkImageState extends State<_SvgNetworkImage> {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.network(
      widget.imageUrl,
      width: widget.width,
      height: widget.height,
      placeholderBuilder: (context) => const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ),
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ??
            Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: widget.border ??
                    Border.all(
                      color: Colors.grey,
                    ),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.error),
              ),
            );
      },
    );
  }
}

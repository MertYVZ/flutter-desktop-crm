// ignore_for_file: lines_longer_than_80_chars, document_ignores

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Animasyonlu path oluşturma yardımcı sınıfı
///
/// CustomAnimateBorder tarafından kullanılır
class Utils {
  /// Verilen path'in belirtilen yüzdesini animasyonlu olarak oluşturur
  ///
  /// [originalPath] - Orijinal path
  /// [animationPercent] - 0.0 ile 1.0 arası animasyon yüzdesi
  static Path createAnimatedPath(
    Path originalPath,
    double animationPercent,
  ) {
    if (animationPercent <= 0) {
      return Path();
    }
    // ComputeMetrics sadece bir kez iterate edilebilir!
    final totalLength = originalPath
        .computeMetrics()
        .fold<double>(0, (prev, ui.PathMetric metric) => prev + metric.length);

    final currentLength = totalLength * animationPercent;

    if (currentLength <= 0) {
      return Path();
    }
    if (currentLength >= totalLength) {
      return originalPath;
    }

    return extractPathUntilLength(originalPath, currentLength);
  }

  /// Belirtilen uzunluğa kadar path'i çıkarır
  ///
  /// [originalPath] - Orijinal path
  /// [length] - Çıkarılacak uzunluk
  static Path extractPathUntilLength(
    Path originalPath,
    double length,
  ) {
    if (length <= 0) {
      return Path();
    }
    var currentLength = 0.0;

    final path = Path();

    final metricsIterator = originalPath.computeMetrics().iterator;

    while (metricsIterator.moveNext()) {
      final metric = metricsIterator.current;

      final nextLength = currentLength + metric.length;

      final isLastSegment = nextLength > length;
      if (isLastSegment) {
        final remainingLength = length - currentLength;
        final pathSegment = metric.extractPath(0, remainingLength);

        path.addPath(pathSegment, Offset.zero);
        break;
      } else {
        // Tüm path'i çıkarmanın daha verimli bir yolu olabilir
        final pathSegment = metric.extractPath(0, metric.length);
        path.addPath(pathSegment, Offset.zero);
      }

      currentLength = nextLength;
    }

    return path;
  }
}

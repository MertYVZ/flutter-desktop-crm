import 'dart:io';

/// Backend API header value for `os-id`.
int resolvePlatformOsId() {
  if (Platform.isAndroid) return 3;
  if (Platform.isIOS) return 4;
  if (Platform.isMacOS) return 5;
  if (Platform.isWindows) return 6;
  if (Platform.isLinux) return 7;
  return 4;
}

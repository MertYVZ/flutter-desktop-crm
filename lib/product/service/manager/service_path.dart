enum ServicePath {
  //* Auth
  login,

}

extension ServicePathExtension on ServicePath {
  String get path {
    switch (this) {
      case ServicePath.login:
        return '/user/login';
    }
  }
}

/// Supported CRM user roles.
enum UserRole {
  admin;

  String get value => name;

  static UserRole? fromValue(String value) {
    for (final role in UserRole.values) {
      if (role.value == value) {
        return role;
      }
    }
    return null;
  }
}

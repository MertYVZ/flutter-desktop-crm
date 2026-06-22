enum MeetingMethod {
  email,
  phone,
  meeting,
  whatsapp,
  faceToFace,
  online,
}

extension MeetingMethodX on MeetingMethod {
  String get value {
    switch (this) {
      case MeetingMethod.email:
        return 'email';
      case MeetingMethod.phone:
        return 'phone';
      case MeetingMethod.meeting:
        return 'meeting';
      case MeetingMethod.whatsapp:
        return 'whatsapp';
      case MeetingMethod.faceToFace:
        return 'faceToFace';
      case MeetingMethod.online:
        return 'online';
    }
  }

  String get label {
    switch (this) {
      case MeetingMethod.email:
        return 'E-posta';
      case MeetingMethod.phone:
        return 'Telefon';
      case MeetingMethod.meeting:
        return 'Toplantı';
      case MeetingMethod.whatsapp:
        return 'WhatsApp';
      case MeetingMethod.faceToFace:
        return 'Yüz Yüze';
      case MeetingMethod.online:
        return 'Online';
    }
  }

  static MeetingMethod? fromValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    for (final method in MeetingMethod.values) {
      if (method.value == value) {
        return method;
      }
    }

    return null;
  }
}

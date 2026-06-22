import 'package:Ok/feature/meetings/models/meeting_method.dart';
import 'package:Ok/feature/meetings/models/meeting_subject.dart';
import 'package:equatable/equatable.dart';

final class MeetingListItem extends Equatable {
  const MeetingListItem({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.date,
    required this.method,
    required this.subject,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String customerId;
  final String customerName;
  final DateTime date;
  final String method;
  final String subject;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MeetingMethod? get meetingMethod => MeetingMethodX.fromValue(method);

  MeetingSubject? get meetingSubject => MeetingSubjectX.fromValue(subject);

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        date,
        method,
        subject,
        notes,
        createdAt,
        updatedAt,
      ];
}

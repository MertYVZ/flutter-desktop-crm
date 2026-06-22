import 'package:equatable/equatable.dart';

final class NoteListItem extends Equatable {
  const NoteListItem({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? customerId;
  final String? customerName;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayCustomerName => customerName ?? 'Genel';

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        title,
        content,
        createdAt,
        updatedAt,
      ];
}
